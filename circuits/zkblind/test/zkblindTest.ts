
import path from "path";
import wasm_tester from "../../../wasm_tester";
import {
  setupDirectories,
  padEmailTo2032Bits,
  stringToBitArray,
  getCircuitInputWithAddrAndSig,
  getAddrAndSig,
  bitArrayToBigInt,
  extractLeastSignificantBits,
  bigint_to_array
} from "../../test_utils"
import { sha256 } from 'js-sha256';
import { expect } from 'chai';

const pathToCircom = "./zkbindTest.circom"

describe("Test zkblind", function () {
  const output = setupDirectories(pathToCircom);

  it("Checks zkblind", async function () {
    const email = "example@example.com";

    const paddedEmail = padEmailTo2032Bits(email);

    if (!paddedEmail) {
      throw ("The email address is not valid.");
    }

    const emailAddressInputBits = stringToBitArray(paddedEmail);

    const emailSuffix = `@${email.split('@')[1]}`;
    const paddedEmailSuffix = padEmailTo2032Bits(emailSuffix);
    if (!paddedEmailSuffix) {
      throw ("The email suffix is not valid.");
    }
    const emailAddressSuffixInputBits = stringToBitArray(paddedEmailSuffix);
    const emailAddressSuffixBigInt = bitArrayToBigInt(emailAddressSuffixInputBits);
    const emailAddressSuffixInput = bigint_to_array(128, 16, emailAddressSuffixBigInt);

    const hash = sha256(paddedEmail);

    const userId = extractLeastSignificantBits(hash, 216);

    const privateKey = "f5b552f608f5b552f608f5b552f6082ff5b552f608f5b552f608f5b552f6082f"
    const addrAndSig = getAddrAndSig(privateKey)
    const sigInput = getCircuitInputWithAddrAndSig(addrAndSig)

    const circuit = await wasm_tester(
      path.join(__dirname, pathToCircom),
      {
        output
      }
    );

    const w = await circuit.calculateWitness({
      userId: userId,
      userEmailAddress: emailAddressInputBits,
      userEmailSuffix: emailAddressSuffixInput,
      userEthAddr: 0n,
      userSigR: sigInput.r,
      userSigS: sigInput.s,
      userEthAddressSha256Hash: sigInput.msghash,
      userPubKey: sigInput.pubkey,
    });

    console.log(w[1])
    expect(w[1]).to.equal(1n);

    await circuit.checkConstraints(w);
  });
});
