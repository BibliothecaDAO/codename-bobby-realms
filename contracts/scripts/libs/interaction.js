import "dotenv/config";
import { getNetwork, getAccount } from "./network.js";
import {byteArray} from "starknet"
import colors from "colors";

import * as fs from "fs";

const blobertAddress = 0x42f5f669ae20b76fa38badec759f4c25b099ae05e167595f81964f796f8bb80n;
export const generateSvgImage = async () => {

  ///////////////////////////////////////////
  ////////    BLOBERT SVG IMAGE        //////
  ///////////////////////////////////////////

  // Load account
  const account = getAccount();

  // read abi of Test contract
  let res = await account.callContract(
    {contractAddress: blobertAddress, entrypoint: "svg_image", calldata:[39,0] } // 36 fails
    )

  let pending_word = res[res.length - 2]
  let pending_word_len = res[res.length -1]
  res.pop() // pop pending_word_len
  res.pop() // pop pending word
  res.shift() // shift "data"
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
    0x1bfd917fdf403007307805477ec62a6b8ec2883afa38cdc52a47b1756822248n,
    0x294c410fc840bc5c257d481337bbcb5901662c1276c29b94f491b04e2b18cban,
    0xa08249e3f9ee50da4382d47fa01ce5c3a1f7466dcadf0e0c375add37ef48ebn
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


generateSvgImage()
// callWhitelistMint()