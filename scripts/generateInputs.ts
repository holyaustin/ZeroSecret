import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';
import {
  padEmailTo2032Bits,
  stringToBitArray,
  getCircuitInputWithAddrAndSig,
  bigint_to_array,
  bitArrayToBigInt,
  extractLeastSignificantBits,
  ethAddressToBigInt
} from "../circuits/test_utils"
import { sha256 } from 'js-sha256';

type ParsedEmail = {
  emailAddress: string;
  addrAndSig: [string, string];
};

function parseEmailFile(path: string): ParsedEmail | null {
  try {
    const fileContent = fs.readFileSync(path, 'utf8');
    const lines = fileContent.split('\n');

    let emailAddress = '';
    let addrAndSigLine = '';

    for (const line of lines) {
      if (line.startsWith('From:')) {
        const match = line.match(/<(.+)>/);
        if (match && match[1]) {
          emailAddress = match[1];
        }
      } else if (line.startsWith('["0x')) {
        addrAndSigLine = line;
        break;
      }
    }

    if (emailAddress && addrAndSigLine) {
      const addrAndSig = addrAndSigLine
        .replace(/[\[\]"]/g, '')
        .split(',')
        .map((item) => item.trim()) as [string, string];

      return { emailAddress, addrAndSig };
    }
  } catch (error) {
    console.error(`Error reading or parsing the file: ${error}`);
  }

  return null;
}

// Get the root of the repo using a git command
function getRepoRoot(): string {
  try {
    const root = execSync('git rev-parse --show-toplevel', { encoding: 'utf-8' });
    return root.trim();
  } catch (err) {
    console.error('Error: Not in a git repository');
    process.exit(1);
  }
}

// Save file to the specified location
function saveFile(filePath: string, data: any): void {
  console.log(`Writing to default filePath ${filePath}`);

  const jsonString = JSON.stringify(data, bigintReplacer);

  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, jsonString, { encoding: 'utf-8' });
}

function bigintReplacer(key: string, value: any): any {
  if (typeof value === 'bigint') {
    return value.toString(); // Convert BigInt to string
  } else {
    return value;
  }
}

const parsedEmailContent = parseEmailFile("/Users/alanwang/git/ZkBlindNextJs/scripts/zkBindRegistrationEmail.eml")

if (!parsedEmailContent) {
  throw "can't parse email content"
}

console.log(parsedEmailContent)

const email = parsedEmailContent.emailAddress;

const paddedEmail = padEmailTo2032Bits(email);

if (!paddedEmail) {
  throw ("The email address is not valid.");
}

const hash = sha256(paddedEmail);

const userId = extractLeastSignificantBits(hash, 216);

const emailAddressInputBits = stringToBitArray(paddedEmail);

const emailSuffix = `@${email.split('@')[1]}`;
const paddedEmailSuffix = padEmailTo2032Bits(emailSuffix);
if (!paddedEmailSuffix) {
  throw ("The email suffix is not valid.");
}
const emailAddressSuffixInputBits = stringToBitArray(paddedEmailSuffix);
const emailAddressSuffixBigInt = bitArrayToBigInt(emailAddressSuffixInputBits);
const emailAddressSuffixInput = bigint_to_array(128, 16, emailAddressSuffixBigInt);

const addrAndSig = JSON.stringify(parsedEmailContent.addrAndSig)
const sigInput = getCircuitInputWithAddrAndSig(addrAndSig)

const userEthAddr = parsedEmailContent.addrAndSig[0]

const userEthAddrBigInt = ethAddressToBigInt(userEthAddr)

const gen_inputs = {
  userId: userId,
  userEmailAddress: emailAddressInputBits,
  userEmailSuffix: emailAddressSuffixInput,
  userEthAddr: userEthAddrBigInt,
  userSigR: sigInput.r,
  userSigS: sigInput.s,
  userEthAddressSha256Hash: sigInput.msghash,
  userPubKey: sigInput.pubkey
};

const repoRoot = getRepoRoot();

const buildPath = path.join(repoRoot, 'build');
const outputPath = path.join(buildPath, 'input.json');

saveFile(outputPath, gen_inputs);

