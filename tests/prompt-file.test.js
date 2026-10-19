import assert from "node:assert/strict";
import { mkdtemp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import { ensureEditablePromptFile } from "../src/prompt-file.js";

test("creates an editable prompt once and preserves later edits", async (context) => {
  const root = await mkdtemp(path.join(tmpdir(), "rsvp-prompt-test-"));
  context.after(() => rm(root, { recursive: true, force: true }));

  const applicationSupportDirectory = path.join(root, "Application Support");
  const assetsDirectory = path.join(root, "assets");
  await mkdir(assetsDirectory);
  await writeFile(path.join(assetsDirectory, "quiz-prompt.md"), "default prompt\n", "utf8");

  const promptPath = await ensureEditablePromptFile({
    applicationSupportDirectory,
    assetsDirectory,
    filename: "quiz.md",
    assetFilename: "quiz-prompt.md",
  });
  assert.equal(
    promptPath,
    path.join(applicationSupportDirectory, "RSVP Clipboard", "quiz.md"),
  );
  assert.equal(await readFile(promptPath, "utf8"), "default prompt\n");

  await writeFile(promptPath, "human edit\n", "utf8");
  const reopenedPath = await ensureEditablePromptFile({
    applicationSupportDirectory,
    assetsDirectory,
    filename: "quiz.md",
    assetFilename: "quiz-prompt.md",
  });
  assert.equal(reopenedPath, promptPath);
  assert.equal(await readFile(promptPath, "utf8"), "human edit\n");
});

test("concurrent prompt setup keeps one complete file", async (context) => {
  const root = await mkdtemp(path.join(tmpdir(), "rsvp-prompt-race-test-"));
  context.after(() => rm(root, { recursive: true, force: true }));

  const applicationSupportDirectory = path.join(root, "Application Support");
  const assetsDirectory = path.join(root, "assets");
  await mkdir(assetsDirectory);
  await writeFile(path.join(assetsDirectory, "quiz-prompt.md"), "complete prompt\n", "utf8");

  const arguments_ = {
    applicationSupportDirectory,
    assetsDirectory,
    filename: "quiz.md",
    assetFilename: "quiz-prompt.md",
  };
  const paths = await Promise.all([
    ensureEditablePromptFile(arguments_),
    ensureEditablePromptFile(arguments_),
  ]);
  assert.equal(paths[0], paths[1]);
  assert.equal(await readFile(paths[0], "utf8"), "complete prompt\n");
});
