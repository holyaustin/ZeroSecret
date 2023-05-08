import path from "path";
import fs from "fs";
import { execSync } from "child_process";
import { hmac } from '@noble/hashes/hmac';
import { sha256 } from '@noble/hashes/sha256';
import { privateToAddress } from "@ethereumjs/util";
import * as secp256k1 from '@noble/secp256k1';
import { sha256 as jsSha256 } from 'js-sha256';

export function generateEmailSuffix(email: string): string | null {
  const atIndex = email.indexOf('@');
  const dotIndex = email.indexOf('.');

  if (atIndex === -1 || dotIndex === -1) {
    console.error("Invalid email address: missing '@' or '.'.");
    return null;
  }

  const suffixWithSameLength = email.slice(0, atIndex + 1).replace(/./g, String.fromCharCode(0)) + email.slice(atIndex + 1);
  return suffixWithSameLength;
}

export function bigint_to_array(n: number, k: number, x: bigint) {
  let mod: bigint = 1n;
  for (var idx = 0; idx < n; idx++) {
    mod = mod * 2n;
  }

  let ret: bigint[] = [];
  var x_temp: bigint = x;
  for (var idx = 0; idx < k; idx++) {
    ret.push(x_temp % mod);
    x_temp = x_temp / mod;
  }
  return ret;
}

export function getCircuitInputWithAddrAndSig(input: string) {
  const [msg, sigHex]: [string, string] = JSON.parse(input)

  const sig = secp256k1.Signature.fromCompact(sigHex).addRecoveryBit(0)

  const msgHash = jsSha256(msg)

  const msgHashBigInt = BigInt("0x" + msgHash)

  const recoveredPublicKey = sig.recoverPublicKey(msgHash); // Public key recovery

  return getCircuitInput(
    sig.r,
    sig.s,
    msgHashBigInt,
    recoveredPublicKey.x,
    recoveredPublicKey.y
  )
}

export function getCircuitInput(
  r_bigint: bigint,
  s_bigint: bigint,
  msghash_bigint: bigint,
  pub0: bigint,
  pub1: bigint,
) {
  var r_array: bigint[] = bigint_to_array(64, 4, r_bigint);
  var s_array: bigint[] = bigint_to_array(64, 4, s_bigint);
  var msghash_array: bigint[] = bigint_to_array(64, 4, msghash_bigint);
  var pub0_array: bigint[] = bigint_to_array(64, 4, pub0);
  var pub1_array: bigint[] = bigint_to_array(64, 4, pub1);

  return {
    "r": r_array,
    "s": s_array,
    "msghash": msghash_array,
    "pubkey": [pub0_array, pub1_array]
  }
}

// example output of this function:
// ["0xefcbe272b0febe3edadc034af7a3f53ed35aaa53","9ea2c44a6c411cddd0351db03d87b127b64fd420104e0e072d39b29f6318e6302e6f6390a4f17f3f77a83c7b12aa692c1e6fae925a399e0800afe9de71ebab7c"]
export function getAddrAndSig(privateKey: string) {
  const privKeyBuffer = Buffer.from(privateKey, "hex");
  const addr = "0x" + privateToAddress(privKeyBuffer).toString("hex");

  const addrHash = jsSha256(addr)
  secp256k1.etc.hmacSha256Sync = (k, ...m) => hmac(sha256, k, secp256k1.etc.concatBytes(...m))
  const addrSig = secp256k1.sign(addrHash, privateKey).toCompactHex()

  const result = [
    addr,
    addrSig
  ]

  return JSON.stringify(result)
}

export function isASCII(str: string): boolean {
  return /^[\x00-\x7F]*$/.test(str);
}

export function padEmailTo2032Bits(email: string): string | null {
  if (!isASCII(email)) {
    console.error("The email address contains non-ASCII characters.");
    return null;
  }

  const emailBytes = new TextEncoder().encode(email);
  const bitSize = emailBytes.length * 8;

  if (bitSize > 2032) {
    console.error("The email address is larger than 2032 bits.");
    return null;
  }

  const paddedEmailBytes = new Uint8Array(2032 / 8);
  paddedEmailBytes.set(emailBytes);

  const paddedEmail = Array.from(paddedEmailBytes)
    .map(byte => String.fromCharCode(byte))
    .join('');

  return paddedEmail;
}

export function stringToBitArray(input: string): number[] {
  const bitArray = input
    .split('')
    .flatMap(char => {
      const byte = char.charCodeAt(0);
      return Array.from({ length: 8 }, (_, j) => (byte >> (7 - j)) & 1);
    });
  return bitArray;
}

export function bitArrayToBigInt(bitArray: number[]): bigint {
  return bitArray.reduce(
    (acc, bit, index) =>
      acc + (BigInt(bit) * (BigInt(2) ** BigInt(index))), BigInt(0)
  );
}

export function getEmailSuffixStartingIndexInBitArray(input: string): number {
  // Find the index of the '@' symbol in the input string
  const atIndex = input.indexOf('@');

  // Check if the '@' symbol is found in the input string
  if (atIndex === -1) {
    throw new Error("Invalid email address: missing '@' symbol");
  }

  // Convert the index of the '@' symbol in the input string to the corresponding index in the bit array
  const atIndexInBitArray = atIndex * 8;

  return atIndexInBitArray;
}

export function bitArray2buffer(a: number[]) {
  const len = Math.floor((a.length - 1) / 8) + 1;
  const b = Buffer.alloc(len);

  for (let i = 0; i < a.length; i++) {
    const p = Math.floor(i / 8);
    b[p] = b[p] | (Number(a[i]) << (7 - (i % 8)));
  }
  return b;
}

export function setupDirectories(pathToCircom: string) {
  // Get the repository root directory using the 'git' command
  const repoRoot = path.resolve(execSync('git rev-parse --show-toplevel', { encoding: 'utf-8' }).trim());

  // Create a 'tmp' directory in the root of the repository if it doesn't exist
  const tmpDir = path.join(repoRoot, 'tmp');
  if (!fs.existsSync(tmpDir)) {
    fs.mkdirSync(tmpDir);
  }

  // Extract the directory name from pathToCircom variable
  const circomDirName = path.parse(pathToCircom).name;

  // Create a directory with the extracted name inside the 'tmp' directory
  const multiplier2Dir = path.join(tmpDir, circomDirName);
  if (!fs.existsSync(multiplier2Dir)) {
    fs.mkdirSync(multiplier2Dir);
  }

  return multiplier2Dir;
}

export function extractLeastSignificantBits(hexString: string, bits: number): bigint {
  const fullNumber = BigInt(`0x${hexString}`);
  const mask = (BigInt(2) ** BigInt(bits)) - BigInt(1);
  return fullNumber & mask;
}

export function ethAddressToBigInt(ethAddress: string): bigint {
  const hexString = ethAddress.startsWith("0x") ? ethAddress.slice(2) : ethAddress;
  return BigInt(`0x${hexString}`);
}