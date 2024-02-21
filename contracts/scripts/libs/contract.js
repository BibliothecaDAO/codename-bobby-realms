import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { json } from "starknet";
import { getNetwork, getAccount } from "./network.js";
import { initial_assigned_recipients } from "../assigned_custom.js";
// import merkle_data  from "../test_merkle_data.json" assert { type: "json" };
import merkle_data  from "../merkle_data.json" assert { type: "json" };

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
  let fee_token_address = 0x0124aeb495b947201f5fac96fd1138e326ad86195b98df6dec9009158a533b49n
  // let fee_token_address = 0x4ef0e2993abf44178d3a40f2818828ed1c09cde9009677b7a3323570b4c0f2en
  let fee_token_amount = 100 * (10 ** 18)

  let constructorCalldata = [
    token_name,
    token_symbol,
    owner,
    seeder,
    descriptor_regular,
    descriptor_custom,
    fee_token_address,
    fee_token_amount, 0 // u256 high
  ]

  // add merkle roots
  constructorCalldata 
    = addArrayToCalldata(constructorCalldata, whitelist_merkle_roots())

  // mint start time
  let wltime = Math.round(new Date().getTime() / 1000) + (50 * 60)
  let regtime = wltime + (60 * 60 * 24)
  constructorCalldata
    .push( regtime )
  constructorCalldata
    .push( wltime) 

  // initial custom nft recipients
  let initial_assigned_recips = initial_assigned_recipients();
  constructorCalldata 
  = addArrayToCalldata(constructorCalldata, initial_assigned_recips)

  
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
  let a = await account.waitForTransaction(contract.transaction_hash);
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

  // deploy descriptor custom
  let descriptor_custom = "DescriptorCustom"
  const descriptor_custom_class_hash
    = (await declare(getPath(descriptor_custom), descriptor_custom)).class_hash;
  
    // Deploy contract
  console.log(`\nDeploying ${descriptor_custom} ... \n\n`.green);
  let contract = await account.deployContract({
    classHash: descriptor_custom_class_hash
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



function whitelist_merkle_roots(){
  return [
    BigInt(merkle_data["1"]["root"]),
    BigInt(merkle_data["2"]["root"]),
    BigInt(merkle_data["3"]["root"]),
    BigInt(merkle_data["4"]["root"]),
  ]
}


const addArrayToCalldata = (calldata, arr) => {

  calldata.push(arr.length)
  for (let j =0 ; j < arr.length; j++) {
    calldata.push(arr[j]);
  }

  return calldata
}