import path from "path";
import wasm_tester from "../../../wasm_tester";
import {
  setupDirectories,
  padEmailTo2032Bits,
  stringToBitArray,
  extractLeastSignificantBits
} from "../../test_utils"
import { sha256 } from 'js-sha256';
import { expect } from 'chai';

const pathToCircom = "../sha256bits2032.circom"

describe("Test sha256", function () {
  const output = setupDirectories(pathToCircom);

  it("test sha256", async function () {

    const email = "example@example.com";

    const paddedEmail = padEmailTo2032Bits(email);

    if (!paddedEmail) {
      throw ("The email address is not valid.");
    }

    const hash = sha256(paddedEmail);

    const userId = extractLeastSignificantBits(hash, 216);

    const inputBits = stringToBitArray(paddedEmail);

    const circuit = await wasm_tester(
      path.join(__dirname, pathToCircom),
      {
        output
      }
    );

    const w = await circuit.calculateWitness({
      "userEmailAddress": inputBits,
      "userId": userId
    }, true);

    expect(w[1]).to.equal(1n);

    await circuit.checkConstraints(w);
  });
});
