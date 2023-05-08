import { Addresses } from "@/shared/addresses";
import { TransactionReceipt } from "@ethersproject/abstract-provider";
import { prepareWriteContract, writeContract } from "@wagmi/core";

export const executeTransaction = async (
  proof: any,
  publicSignals: Array<string>
): Promise<TransactionReceipt> => {
  const abiPath = require("./abi/SimpleMultiplier.json");

  // Prepare the transaction data
  const config = await prepareWriteContract({
    address: Addresses.SIMPLE_MULTIPLIER_ADDR,
    abi: abiPath.abi,
    functionName: "submitProof",
    args: [proof, publicSignals],
  });

  // Execute the transaction
  const writeResult = await writeContract(config);

  // Wait for the transaction block to be mined
  const txResult = await writeResult.wait();
  return txResult;
};
