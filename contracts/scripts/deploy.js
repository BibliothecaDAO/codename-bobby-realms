import colors from "colors";
import { deployBlobert, deployDescriptorCustom, deployDescriptorRegular, deploySeeder } from "./libs/contract.js";


const main = async () => {
  console.log(`   ____          _         `.red);
  console.log(`  |    \\ ___ ___| |___ _ _ `.red);
  console.log(`  |  |  | -_| . | | . | | |`.red);
  console.log(`  |____/|___|  _|_|___|_  |`.red);
  console.log(`            |_|       |___|`.red);

  // await deploySeeder();
  // await deployDescriptorRegular();
  // await deployDescriptorCustom();

  let seeder = 0x5f6e91f184a502a7e2dcfcf10586000ae89ae9b48a7c1f39b4d15a3aa536676n;
  let descriptor_regular = 0x757b77fdc07f4b6282305919fecae6500ffefcadfa3741515a129a298bf0f80n
  let descriptor_custom = 0x4118b985b7f66a8012e3e3400767207a50e0bd90801c852c59b7895f2092063n
  await deployBlobert(seeder,descriptor_regular, descriptor_custom);
}

main();
