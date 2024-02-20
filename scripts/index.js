const fs = require("fs");
const path = require("path");

function convertImageToBase64(filePath) {
  // Read the file's contents into a buffer
  const buffer = fs.readFileSync(filePath);
  // Convert the buffer to a Base64 string
  return buffer.toString("base64");
}

function appendBase64ToFile(base64String, outputFilePath, functionName) {
  // Format the string as desired
  const formattedString = `fn ${functionName}() -> ByteArray {\n    "${base64String}"\n}\n`;

  // Append the formatted string to the output file
  fs.appendFileSync(outputFilePath, formattedString);
}

function findPngFiles(directory) {
  // Read all files in the directory
  const files = fs.readdirSync(directory);
  // Filter and return only PNG files
  return files.filter((file) => path.extname(file).toLowerCase() === ".png");
}

function generateBase64(directory, outputFilePath) {
  const imagePaths = findPngFiles(directory);

  // Clear the output file
  fs.writeFileSync(outputFilePath, "");

  imagePaths.forEach((imagePath) => {
    const fullPath = path.join(directory, imagePath);
    const base64String = convertImageToBase64(fullPath);
    const functionName = path.basename(imagePath, path.extname(imagePath));
    appendBase64ToFile(base64String, outputFilePath, functionName);
    console.log("Processed:", imagePath);
  });
}

generateBase64(
  "art/traits/armour",
  "contracts/src/generation/traits/data/armour.cairo"
);
generateBase64(
  "art/traits/backgrounds",
  "contracts/src/generation/traits/data/background.cairo"
);

generateBase64(
  "art/traits/jewelry",
  "contracts/src/generation/traits/data/jewelry.cairo"
);

generateBase64(
  "art/traits/masks",
  "contracts/src/generation/traits/data/mask.cairo"
);

generateBase64(
  "art/traits/weapons",
  "contracts/src/generation/traits/data/weapon.cairo"
);


generateBase64(
  "art/custom",
  "contracts/src/generation/custom/data/images.cairo"
);

console.log("All conversions complete");
