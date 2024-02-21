import colors from "colors";
import { deployBlobert, deployDescriptorCustom, deployDescriptorRegular, deploySeeder } from "./libs/contract.js";
import {merkle} from "starknet";

const main = async () => {
  console.log(`   ____          _         `.red);
  console.log(`  |    \\ ___ ___| |___ _ _ `.red);
  console.log(`  |  |  | -_| . | | . | | |`.red);
  console.log(`  |____/|___|  _|_|___|_  |`.red);
  console.log(`            |_|       |___|`.red);

  let seeder = 0x592403d219ba2077760667c8244850a22a7e04f8f97af89c9d1c8df4678b79cn;
  let descriptor_regular = 0x7c82f2f8199551b5eb828de9d0a485c1dfbe8f4d05502a7e39d1379da398d7fn;
  let descriptor_custom = 0x63ab8702d967c25ad40c0c9bf76df50b9473ca57b282810463fe0ab6166751bn;

  await deployBlobert(seeder,descriptor_regular, descriptor_custom);
}


main();