import { getContractInfo } from "@/utils/contracts";
import {
  prepareWriteContract,
  writeContract,
  getAccount,
  readContract,
  getNetwork,
} from "@wagmi/core";
import { ethers } from "ethers";

const { chain } = getNetwork();
const { contractAddress, abi } = getContractInfo(chain?.id);

export const checkWhitelisted = async () => {
  const account = getAccount();
  console.log("Current account:", account);
  const data = await readContract({
    address: contractAddress as `0x${string}`,
    abi: abi,
    functionName: "verifyUser",
    args: [account.address],
  });

  console.log("Verify data:", data);

  if (data) {
    return true;
  }
  return false;
};

export const addWhitelistTransaction = async (
  a:any, 
  b:any, 
  c:any, 
  input:any,
  userId: string,
  emailSuffix: string
) => {
  try {
    emailSuffix = ethers.utils.formatBytes32String(emailSuffix);
    const config = await prepareWriteContract({
      address: contractAddress as `0x${string}`,
      abi: abi,
      functionName: "addToWhitelist",
      args: [userId, emailSuffix, a, b, c, input],
    });

    // Execute the transaction
    const writeResult = await writeContract(config);

    // Wait for the transaction block to be mined
    const txResult = await writeResult.wait();
    return txResult.transactionHash;
  } catch (err) {
    console.log("addWhitelistTransaction err2:", err);
  }
};
