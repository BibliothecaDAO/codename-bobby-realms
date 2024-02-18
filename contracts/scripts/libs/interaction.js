import "dotenv/config";
import { getAccount } from "./network.js";
import {byteArray} from "starknet"
import * as fs from "fs";


export const checkBlobert = async () => {

  ///////////////////////////////////////////
  ////////    BLOBERT         ///////////////
  ///////////////////////////////////////////

  // Load account
  const account = getAccount();

  // Connect the deployed Test contract in Testnet
  const blobertAddy = "0x7ffb64d0c5615689a78cdf6176de7a6ef6664df89d9a678ba487f605380b274";

  // read abi of Test contract
  let res = await account.callContract(
    {contractAddress: blobertAddy, entrypoint: "svg_image", calldata:[19,0] }
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


checkBlobert()