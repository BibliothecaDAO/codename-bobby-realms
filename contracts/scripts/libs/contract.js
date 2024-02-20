import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { json } from "starknet";
import { getNetwork, getAccount } from "./network.js";
import { initial_assigned_recipients } from "../assigned_custom.js";

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
  let owner = 0x0140809B710276e2e07c06278DD8f7D4a2528acE2764Fce32200852CB3893e5Cn 
  //todo change
  let fee_token_address = 0x4ef0e2993abf44178d3a40f2818828ed1c09cde9009677b7a3323570b4c0f2en
  let fee_token_amount = 100 * (10 ** 18)

  let constructorCalldata = [
    token_name,
    token_symbol,
    owner,
    seeder,
    descriptor_regular,
    descriptor_custom,
    fee_token_address,
    fee_token_amount, 0 // u256
  ]

  // merkle roots
  let merkle_roots = whitelist_merkle_roots()
  constructorCalldata.push(merkle_roots.length)
  for (let j =0 ; j < merkle_roots.length; j++) {
    constructorCalldata.push(merkle_roots[j]);
  }

  // todo update whitelist time

  // mint start time
  constructorCalldata.push(Math.round(new Date().getTime() / 1000) + 60 * 20) // regular mint start time // 12 minutes from now
  constructorCalldata.push(Math.round(new Date().getTime() / 1000) + 30 ) // whitelist mint start time // 30 seconds from now

  // initial custom nft recipients
  let initial_assigned_recips = initial_assigned_recipients();
  constructorCalldata.push(initial_assigned_recips.length)
  for (let j =0 ; j < initial_assigned_recips.length; j++) {
    constructorCalldata.push(initial_assigned_recips[j]);
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

  return contract.address

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

  return contract.address

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

  return contract.address
}



function whitelist_merkle_roots(){
  return [
    0x3a5f886e952da36285158c8e9e2cec6d4d17d1271cbb66d6c770bc0ea795025n, // tier 1
    0x7355045c69306c4f0aa9b82ec8fe14cedc41f4e1ecf632f159d416d89b30a7n, // tier 2
    0x5ae7c1084891066205bff66d47382b55de150e9e7f8807e76e33cc65b7e8a23n, // tier 3
    0xe124d0eba590a8049e8a1107799a3ed7253f0eaa4c2c1d1e6927969dc1069dn, // tier 4
  ]
}