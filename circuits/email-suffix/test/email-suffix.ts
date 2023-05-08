
import path from "path";
import wasm_tester from "../../../wasm_tester";
import {
  setupDirectories,
  padEmailTo2032Bits,
  stringToBitArray,
  getEmailSuffixStartingIndexInBitArray,
  bigint_to_array,
  bitArrayToBigInt
} from "../../test_utils"
import { expect } from 'chai';

const pathToCircom = "./email-suffix.circom"

describe("Test email suffix", function () {
  const output = setupDirectories(pathToCircom);

  it("Checks email suffix", async function () {
    const email = "example@example.com";

    const paddedEmail = padEmailTo2032Bits(email);

    if (!paddedEmail) {
      throw ("The email address is not valid.");
    }

    const emailAddressInputBits = stringToBitArray(paddedEmail);

    const emailSuffixStartingIndex = getEmailSuffixStartingIndexInBitArray(paddedEmail);

    // used to create the circuit
    console.log(emailSuffixStartingIndex)

    const emailSuffix = `@${email.split('@')[1]}`;

    const paddedEmailSuffix = padEmailTo2032Bits(emailSuffix);

    if (!paddedEmailSuffix) {
      throw ("The email suffix is not valid.");
    }

    const emailAddressSuffixInputBits = stringToBitArray(paddedEmailSuffix);

    const emailAddressSuffixBigInt = bitArrayToBigInt(emailAddressSuffixInputBits);

    const emailAddressSuffixInput = bigint_to_array(128, 16, emailAddressSuffixBigInt);

    const circuit = await wasm_tester(
      path.join(__dirname, pathToCircom),
      {
        output
      }
    );

    const w = await circuit.calculateWitness({
      userEmailAddress: emailAddressInputBits,
      userEmailSuffix: emailAddressSuffixInput,
    });

    expect(w[1]).to.equal(1n);

    await circuit.checkConstraints(w);
  });
});
