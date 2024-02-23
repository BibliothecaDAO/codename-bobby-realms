import "dotenv/config";
import { getNetwork, getAccount } from "./network.js";
import {byteArray} from "starknet"
import colors from "colors";

import * as fs from "fs";

const blobertAddress = 0x007075083c7f643a2009cf1dfa28dfec9366f7d374743c2e378e03c01e16c3afn;
export const generateSvgImage = async () => {

  ///////////////////////////////////////////
  ////////    BLOBERT SVG IMAGE        //////
  ///////////////////////////////////////////

  // Load account
  const account = getAccount();
  let bytearr = {
    data: res,
    pending_word: pending_word,
    pending_word_len: pending_word_len,  
  }

  let str = byteArray.stringFromByteArray(bytearr)
  // Write data in 'Output.txt' .
  fs.writeFile('Svg.txt', str, (err) => {
      // In case of a error throw err.
      if (err) throw err;
  })

}


export const callWhitelistMint = async () => {

  ///////////////////////////////////////////
  ////////    BLOBERT         ///////////////
  ///////////////////////////////////////////

  // Load account
  const account = getAccount();

  // Connect the deployed Test contract in Testnet

  // read abi of Test contract
  let calldata = []
  calldata.push(account.address) //recipient

  let merkle_proof = [
    "2461346573285723365912187430944399967588953026779287944953191952128612292614",
    "1046207144106800084680566165664977077184516474202712165255045607345244738617",
    "1700665023328058276710386641482722623796946951043856227758729548785023586887",
    "1776384935207426675478629185070085697852105557904271143125014918582071270454",
    "2356048579238990704538630181877896738178417927929725321119494838445799290171"
  ]

  calldata.push(merkle_proof.length)
  for (let i =0; i < merkle_proof.length; i++) {
    calldata.push(merkle_proof[i]) 
  } // merkle proof

  const whitelist_tier = 0;
  calldata.push(whitelist_tier) // whitelist tier

  let res = await account.execute(
    { contractAddress: blobertAddress, 
      entrypoint: "mint_whitelist", 
      calldata
    }
  )
  let network = getNetwork(process.env.STARKNET_NETWORK);
  console.log(
    "Tx hash: ".green,
    `${network.explorer_url}/tx/${res.transaction_hash})`,
  );
  await account.waitForTransaction(res.transaction_hash);


}


// generateSvgImage()
callWhitelistMint()