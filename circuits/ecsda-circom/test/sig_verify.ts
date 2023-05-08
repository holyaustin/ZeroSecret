import path from "path";
import wasm_tester from "../../../wasm_tester";
import {
  setupDirectories,
  getCircuitInputWithAddrAndSig,
  getAddrAndSig
} from "../../test_utils"
import { expect } from 'chai';

const pathToCircom = "./sig_verify.circom"

describe("Test sig verify", function () {
  const output = setupDirectories(pathToCircom);

  it("Checks sig verify", async function () {
    const privateKey = "f5b552f608f5b552f608f5b552f6082ff5b552f608f5b552f608f5b552f6082f"
    const addrAndSig = getAddrAndSig(privateKey)
    const input = getCircuitInputWithAddrAndSig(addrAndSig)

    const circuit = await wasm_tester(
      path.join(__dirname, pathToCircom),
      {
        output
      }
    );

    const w = await circuit.calculateWitness(input);

    // 0n means failed, 1n measn passed
    expect(w[1]).to.equal(1n);

    await circuit.checkConstraints(w);
  });
});
