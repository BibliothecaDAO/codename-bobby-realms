import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { json } from "starknet";
import { getNetwork, getAccount } from "./network.js";
import { custom_nft_recipients } from "../custom_nft_assign.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const TARGET_PATH = path.join(__dirname, "..", "..", "target", "release");

const getContracts = () => {
  if (!fs.existsSync(TARGET_PATH)) {
    throw new Error(`Target directory not found at path: ${TARGET_PATH}`);
  }
  const contracts = fs
    .readdirSync(TARGET_PATH)
    .filter((contract) => contract.includes(".contract_class.json"));
  if (contracts.length === 0) {
    throw new Error("No build files found. Run `scarb build` first");
  }
  return contracts;
};

const getPath = (contract_name) => {
  const contracts = getContracts();
  const c = contracts.find((contract) =>
    contract.includes(contract_name),
  );
  if (!c) {
    throw new Error(`Contract not found: ${contract_name}`);
  }
  return path.join(TARGET_PATH, c);
};


const declare = async (filepath, contract_name) => {
  console.log(`\nDeclaring ${contract_name}...\n\n`.magenta);
  const compiledSierraCasm = filepath.replace(
    ".contract_class.json",
    ".compiled_contract_class.json",
  );
  const compiledFile = json.parse(fs.readFileSync(filepath).toString("ascii"));
  const compiledSierraCasmFile = json.parse(
    fs.readFileSync(compiledSierraCasm).toString("ascii"),
  );
  const account = getAccount();
  const contract = await account.declareIfNot({
    contract: compiledFile,
    casm: compiledSierraCasmFile,
  });

  const network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(`- Class Hash: `.magenta, `${contract.class_hash}`);
  if (contract.transaction_hash) {
    console.log(
      "- Tx Hash: ".magenta,
      `${network.explorer_url}/tx/${contract.transaction_hash})`,
    );
    await account.waitForTransaction(contract.transaction_hash);
  } else {
    console.log("- Tx Hash: ".magenta, "Already declared");
  }

  return contract;
};





export const deployBlobert = async (seeder,descriptor_regular, descriptor_custom ) => {

  ///////////////////////////////////////////
  ////////    BLOBERT         ///////////////
  ///////////////////////////////////////////

    // Load account
    const account = getAccount();


  // declare contract
  let name = "Blobert"
  const class_hash
    = (await declare(getPath(name), name)).class_hash;

  let token_name = "Blobert";
  let token_symbol = "BLOB";
  let owner = account.address

  let constructorCalldata = [
    token_name,
    token_symbol,
    owner,
    seeder,
    descriptor_regular,
    descriptor_custom,
  ]

  // merkle roots
  let merkle_roots = [
    1,2,3,4,5
  ]
  constructorCalldata.push(merkle_roots.length)
  for (let j =0 ; j < merkle_roots.length; j++) {
    constructorCalldata.push(merkle_roots[j]);
  }

  // mint start time
  constructorCalldata.push(1708283743)// regular mint start time
  constructorCalldata.push(1708282508)// whitelist mint start time


  // custom nft recipients
  // let custom_nft_recips = [];
  let custom_nft_recips = custom_nft_recipients();
  // console.log("\n\n Recips  \n\n",custom_nft_recips)
  constructorCalldata.push(custom_nft_recips.length)
  for (let j =0 ; j < custom_nft_recips.length; j++) {
    constructorCalldata.push(custom_nft_recips[j]);
  }
  
  // Deploy contract
  console.log(`\nDeploying ${name} ... \n\n`.green);
  let contract = await account.deployContract({
    classHash: class_hash,
    constructorCalldata: constructorCalldata
  });


  // Wait for transaction
  let network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");

}

export const deploySeeder = async () => {

  // Load account
  const account = getAccount();

  ///////////////////////////////////////////
  //////////    SEEDER         ///////////////
  ///////////////////////////////////////////

  // declare contract
  let name = "Seeder"
  const class_hash
    = (await declare(getPath(name), name)).class_hash;
  
    // Deploy contract
  console.log(`\nDeploying ${name} ... \n\n`.green);
  let contract = await account.deployContract({
    classHash: class_hash,
  });


  // Wait for transaction
  let network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");

}



export const deployDescriptorRegular = async () => {

  // Load account
  const account = getAccount();

  ///////////////////////////////////////////
  ///////////////////////////////////////////
  ///////////////////////////////////////////

  // deploy descriptor regular
  let descriptor_regular = "DescriptorRegular"
  const descriptor_regular_class_hash
    = (await declare(getPath(descriptor_regular), descriptor_regular)).class_hash;
  
    // Deploy contract
  console.log(`\nDeploying ${descriptor_regular} ... \n\n`.green);
  let contract = await account.deployContract({
    classHash: descriptor_regular_class_hash,
  });


  // Wait for transaction
  let network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");

}

export const deployDescriptorCustom = async () => {

  // Load account
  const account = getAccount();

  ///////////////////////////////////////////
  ///////////////////////////////////////////
  ///////////////////////////////////////////

  let descriptor_custom_data_addresses = [];

  // Declare custom data 1
  let descriptor_custom_data_1 = "DescriptorCustomData1"
  const descriptor_custom_data_1_class_hash 
    = (await declare(getPath(descriptor_custom_data_1), descriptor_custom_data_1)).class_hash;

  // Deploy contract
  console.log(`\nDeploying ${descriptor_custom_data_1} ... \n\n`.green);
  let contract = await account.deployContract({
    classHash: descriptor_custom_data_1_class_hash
  });

  // Wait for transaction
  let network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
      "Tx hash: ".green,
      `${network.explorer_url}/tx/${contract.transaction_hash})`,
    );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");
  descriptor_custom_data_addresses.push(contract.address)
  

  ///////////////////////////////////////////
  ///////////////////////////////////////////
  ///////////////////////////////////////////


  // Declare custom data 2
  let descriptor_custom_data_2 = "DescriptorCustomData2"
  const descriptor_custom_data_2_class_hash 
    = (await declare(getPath(descriptor_custom_data_2), descriptor_custom_data_2)).class_hash;

  // Deploy contract
  console.log(`\nDeploying ${descriptor_custom_data_2} ... \n\n`.green);
  contract = await account.deployContract({
    classHash: descriptor_custom_data_2_class_hash,
    constructorCalldata: [],
  });

  // Wait for transaction
  network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");
  descriptor_custom_data_addresses.push(contract.address)

  
  ///////////////////////////////////////////
  ///////////////////////////////////////////
  ///////////////////////////////////////////

    
  // // Declare custom data 3
  let descriptor_custom_data_3 = "DescriptorCustomData3"
  const descriptor_custom_data_3_class_hash 
    = (await declare(getPath(descriptor_custom_data_3), descriptor_custom_data_3)).class_hash;

  // Deploy contract
  console.log(`\nDeploying ${descriptor_custom_data_3} ... \n\n`.green);
  contract = await account.deployContract({
    classHash: descriptor_custom_data_3_class_hash,
    constructorCalldata: [],
  });


  // Wait for transaction
  network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");
  descriptor_custom_data_addresses.push(contract.address)


  ///////////////////////////////////////////
  ///////////////////////////////////////////
  ///////////////////////////////////////////

  // deploy descriptor custom
  let descriptor_custom = "DescriptorCustom"
  const descriptor_custom_class_hash
    = (await declare(getPath(descriptor_custom), descriptor_custom)).class_hash;
  
    // Deploy contract
  console.log(`\nDeploying ${descriptor_custom} ... \n\n`.green);
  contract = await account.deployContract({
    classHash: descriptor_custom_class_hash,
    constructorCalldata: [
      descriptor_custom_data_addresses.length,
      descriptor_custom_data_addresses[0],
      descriptor_custom_data_addresses[1],
      descriptor_custom_data_addresses[2],
    ],
  });


  // Wait for transaction
  network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${contract.transaction_hash})`,
  );
  await account.waitForTransaction(contract.transaction_hash);
  console.log("Contract Address: ".green, contract.address, "\n\n");
  descriptor_custom_data_addresses.push(contract.address)

}

// export const deployFactory = async () => {
//   // Load account
//   const account = getAccount();

//   // Declare contracts
//   const memecoin = await declare(
//     getUnruggableMemecoinPath(),
//     "UnruggableMemecoin",
//   );
//   const factory = await declare(getFactoryPath(), "Factory");

//   // Deploy factory
//   const exchanges = getExchanges(process.env.STARKNET_NETWORK);
//   console.log(`\nDeploying Factory...`.green);
//   console.log("Owner: ".green, process.env.STARKNET_ACCOUNT_ADDRESS);
//   console.log("Memecoin class hash: ".green, memecoin.class_hash);
//   console.log("Exchanges: ".green, exchanges);

//   const contract = await account.deployContract({
//     classHash: factory.class_hash,
//     constructorCalldata: [
//       process.env.STARKNET_ACCOUNT_ADDRESS,
//       memecoin.class_hash,
//       exchanges,
//     ],
//   });

//   // Wait for transaction
//   const network = getNetwork(process.env.STARKNET_NETWORK);
//   console.log(
//     "Tx hash: ".green,
//     `${network.explorer_url}/tx/${contract.transaction_hash})`,
//   );
//   await account.waitForTransaction(contract.transaction_hash);
// };


// console.log(deployDescriptors())