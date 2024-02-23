import colors from "colors";
import { deployBlobert, deployDescriptorCustom, deployDescriptorRegular, deploySeeder } from "./libs/contract.js";


const main = async () => {
  console.log(`   ____          _         `.red);
  console.log(`  |    \\ ___ ___| |___ _ _ `.red);
  console.log(`  |  |  | -_| . | | . | | |`.red);
  console.log(`  |____/|___|  _|_|___|_  |`.red);
  console.log(`            |_|       |___|`.red);

  let seeder = await deploySeeder();
  let descriptor_regular = await deployDescriptorRegular();
  let descriptor_custom = await deployDescriptorCustom();

  await deployBlobert(seeder,descriptor_regular, descriptor_custom);
}

main();
