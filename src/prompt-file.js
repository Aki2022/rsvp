import { constants } from "node:fs";
import { access, copyFile, mkdir } from "node:fs/promises";
import path from "node:path";

export async function ensureEditablePromptFile({
  applicationSupportDirectory,
  assetsDirectory,
  filename,
  assetFilename,
}) {
  const promptPath = path.join(applicationSupportDirectory, "RSVP Clipboard", filename);

  try {
    await access(promptPath);
    return promptPath;
  } catch (error) {
    if (error?.code !== "ENOENT") return promptPath;
  }

  try {
    await mkdir(path.dirname(promptPath), { recursive: true });
    await copyFile(
      path.join(assetsDirectory, assetFilename),
      promptPath,
      constants.COPYFILE_EXCL,
    );
  } catch (error) {
    // Preserve an existing file if two reader launches race to create it.
    if (error?.code !== "EEXIST") return promptPath;
  }

  return promptPath;
}
