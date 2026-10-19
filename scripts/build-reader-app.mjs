import { spawnSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const assetsDirectory = path.join(repositoryRoot, "assets");
const appBundle = path.join(assetsDirectory, "RSVPReader.app");
const contentsDirectory = path.join(appBundle, "Contents");
const executableDirectory = path.join(contentsDirectory, "MacOS");
const executablePath = path.join(executableDirectory, "RSVPReader");
const bundleIdentifier = "com.rsvpclipboard.reader";

function run(command, args) {
  const result = spawnSync(command, args, { cwd: repositoryRoot, stdio: "inherit" });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`${command} exited with status ${result.status ?? "unknown"}.`);
}

if (process.platform !== "darwin") {
  throw new Error("RSVPReader.app must be built on macOS.");
}

const infoPlist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>RSVPReader</string>
  <key>CFBundleIdentifier</key><string>${bundleIdentifier}</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleDisplayName</key><string>RSVP Reader</string>
  <key>CFBundleName</key><string>RSVP Reader</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleSignature</key><string>????</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array>
  <key>LSMinimumSystemVersion</key><string>15.0</string>
  <key>LSUIElement</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
`;

const buildDirectory = mkdtempSync(path.join(tmpdir(), "rsvp-reader-build-"));
try {
  const sourceFiles = [
    "rsvp.swift",
    "RSVPKeyAction.swift",
    "RSVPTextCleaner.swift",
    "RSVPQuiz.swift",
    "RSVPQuizPresentation.swift",
    "RSVPCLIDiagnostics.swift",
    "RSVPDiagramHTML.swift",
    "RSVPDiagramStore.swift",
  ].map((filename) => path.join(assetsDirectory, filename));
  const combinedSource = sourceFiles
    .map((sourcePath) => {
      const sourceLabel = path.relative(repositoryRoot, sourcePath).replaceAll("\\", "/");
      return `#sourceLocation(file: "${sourceLabel}", line: 1)\n${readFileSync(sourcePath, "utf8")}\n#sourceLocation()\n`;
    })
    .join("\n");
  const sourcePath = path.join(buildDirectory, "main.swift");
  const builtExecutablePath = path.join(buildDirectory, "RSVPReader");
  writeFileSync(sourcePath, combinedSource, { mode: 0o600 });

  run("swiftc", [
    "-O",
    "-module-cache-path",
    path.join(buildDirectory, "module-cache"),
    sourcePath,
    "-o",
    builtExecutablePath,
  ]);

  rmSync(appBundle, { recursive: true, force: true });
  mkdirSync(executableDirectory, { recursive: true });
  copyFileSync(builtExecutablePath, executablePath);
  writeFileSync(path.join(contentsDirectory, "Info.plist"), infoPlist, { mode: 0o644 });
  writeFileSync(path.join(contentsDirectory, "PkgInfo"), "APPL????", { mode: 0o644 });

  run("codesign", [
    "--force",
    "--deep",
    "--sign",
    "-",
    "--identifier",
    bundleIdentifier,
    appBundle,
  ]);
  run("codesign", ["--verify", "--deep", "--strict", appBundle]);
} finally {
  rmSync(buildDirectory, { recursive: true, force: true });
}
