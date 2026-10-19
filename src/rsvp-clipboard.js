import { spawn } from "node:child_process";
import { access, chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import path from "node:path";
import {
  Clipboard,
  closeMainWindow,
  environment,
  getPreferenceValues,
  showToast,
  Toast,
} from "@raycast/api";
import { ensureEditablePromptFile } from "./prompt-file.js";

const DEFAULT_WORDS_PER_MINUTE = 300;
const DEFAULT_LLM_COMMAND = "claude2";
const MINIMUM_WORDS_PER_MINUTE = 30;
const MAXIMUM_WORDS_PER_MINUTE = 1200;
const EMPTY_AFTER_URL_REMOVAL_MESSAGE = "RSVP: No readable text remains after URL removal.";
const STARTUP_TIMEOUT_MS = 30_000;
const OPEN_TIMEOUT_MS = 10_000;

async function ensureSummaryPromptFile() {
  return ensurePromptFile("summary.md", "summary-prompt.md");
}

async function ensureDiagramPromptFile() {
  return ensurePromptFile("diagram.md", "diagram-prompt.md");
}

async function ensureQuizPromptFile() {
  return ensurePromptFile("quiz.md", "quiz-prompt.md");
}

async function ensurePromptFile(filename, assetFilename) {
  return ensureEditablePromptFile({
    applicationSupportDirectory: path.join(homedir(), "Library", "Application Support"),
    assetsDirectory: environment.assetsPath,
    filename,
    assetFilename,
  });
}

function readWordsPerMinute() {
  const rawValue = getPreferenceValues().wordsPerMinute;
  const normalizedValue = String(rawValue ?? DEFAULT_WORDS_PER_MINUTE).trim();

  if (!/^\d+$/.test(normalizedValue)) {
    return undefined;
  }

  const value = Number(normalizedValue);
  if (value < MINIMUM_WORDS_PER_MINUTE || value > MAXIMUM_WORDS_PER_MINUTE) {
    return undefined;
  }

  return value;
}

function waitForProcessExit(childProcess, timeoutMs) {
  return new Promise((resolve, reject) => {
    let errorOutput = "";
    let settled = false;
    let timeout;

    const finish = (error) => {
      if (settled) return;
      settled = true;
      if (timeout) clearTimeout(timeout);
      if (error) reject(error);
      else resolve();
    };

    timeout = setTimeout(() => {
      childProcess.kill("SIGTERM");
      finish(new Error("RSVP Reader launch timed out."));
    }, timeoutMs);

    childProcess.stderr.setEncoding("utf8");
    childProcess.stderr.on("data", (chunk) => {
      errorOutput = (errorOutput + chunk).slice(-4096);
    });

    childProcess.once("error", (error) => {
      finish(error);
    });
    childProcess.once("close", (code, signal) => {
      if (code === 0) {
        finish();
        return;
      }
      const detail = errorOutput.trim();
      finish(new Error(detail || `Reader exited before opening (code ${code ?? signal ?? "unknown"}).`));
    });
  });
}

async function waitForReaderReady(statusPath, readerProcess) {
  const deadline = Date.now() + STARTUP_TIMEOUT_MS;
  while (Date.now() < deadline) {
    let status;
    try {
      status = (await readFile(statusPath, "utf8")).trim();
    } catch (error) {
      if (error?.code !== "ENOENT") throw error;
    }

    if (status === "ready") return;
    if (status?.startsWith("error:")) {
      const reason = status.slice("error:".length);
      if (reason === "empty_after_url_removal") throw new Error(EMPTY_AFTER_URL_REMOVAL_MESSAGE);
      throw new Error("RSVP Reader could not load its input.");
    }

    if (readerProcess.exitCode !== null && readerProcess.exitCode !== 0) {
      throw new Error("RSVP Reader launch failed.");
    }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  throw new Error("Reader startup timed out.");
}

export default async function main() {
  const wordsPerMinute = readWordsPerMinute();
  if (wordsPerMinute === undefined) {
    await showToast({
      style: Toast.Style.Failure,
      title: "読み上げ速度を確認してください",
      message: "30〜1200の整数を設定してください。",
    });
    return;
  }

  let clipboardText;
  try {
    clipboardText = await Clipboard.readText();
  } catch {
    await showToast({
      style: Toast.Style.Failure,
      title: "クリップボードを読み取れませんでした",
    });
    return;
  }

  if (!clipboardText?.trim()) {
    await showToast({
      style: Toast.Style.Failure,
      title: "クリップボードにテキストがありません",
      message: "読みたいテキストをコピーしてから実行してください。",
    });
    return;
  }

  const readerApp = path.join(environment.assetsPath, "RSVPReader.app");
  const readerExecutable = path.join(readerApp, "Contents", "MacOS", "RSVPReader");
  try {
    await access(readerExecutable);
  } catch {
    await showToast({
      style: Toast.Style.Failure,
      title: "RSVPの読み込みに失敗しました",
      message: "Extensionを npm run dev で再ビルドしてください。",
    });
    return;
  }

  const llmCommand = String(getPreferenceValues().llmCommand ?? DEFAULT_LLM_COMMAND).trim() || DEFAULT_LLM_COMMAND;
  const summaryPromptPath = await ensureSummaryPromptFile();
  const diagramPromptPath = await ensureDiagramPromptFile();
  const quizPromptPath = await ensureQuizPromptFile();
  let handoffDirectory;
  let readerProcess;

  try {
    handoffDirectory = await mkdtemp(path.join(tmpdir(), "rsvp-reader-"));
    await chmod(handoffDirectory, 0o700);
    const inputPath = path.join(handoffDirectory, "clipboard.txt");
    const statusPath = path.join(handoffDirectory, "status.txt");
    await writeFile(inputPath, clipboardText, { encoding: "utf8", flag: "wx", mode: 0o600 });

    readerProcess = spawn(
      "/usr/bin/open",
      ["-n", "-a", readerApp, "--args", String(wordsPerMinute), llmCommand, summaryPromptPath, inputPath, statusPath, diagramPromptPath, quizPromptPath],
      { stdio: ["ignore", "ignore", "pipe"] },
    );
    await waitForProcessExit(readerProcess, OPEN_TIMEOUT_MS);
    await waitForReaderReady(statusPath, readerProcess);
    await closeMainWindow();
  } catch (error) {
    const isEmptyAfterURLRemoval =
      error instanceof Error && error.message === EMPTY_AFTER_URL_REMOVAL_MESSAGE;
    await showToast({
      style: Toast.Style.Failure,
      title: isEmptyAfterURLRemoval ? "読み上げる本文がありません" : "RSVPウィンドウを開けませんでした",
      message: isEmptyAfterURLRemoval
        ? "URL以外の本文をコピーしてから実行してください。"
        : "Swiftが利用できることと、Extensionのファイルを確認してください。",
    });
  } finally {
    readerProcess?.stderr?.destroy();
    if (handoffDirectory) await rm(handoffDirectory, { recursive: true, force: true });
  }
}
