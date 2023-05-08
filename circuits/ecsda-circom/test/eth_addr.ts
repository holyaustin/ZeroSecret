import path from "path";
import wasm_tester from "../../../wasm_tester";
import { setupDirectories } from "../../test_utils"

const pathToCircom = "./eth_addr.circom"

describe("Test eth_addr", function () {
    this.timeout(100000);

    const ethaddr2Dir = setupDirectories(pathToCircom);

    // yarn run test -g "eth_addr 2 input"
    it("eth_addr 2 input", async function () {
        const circuit = await wasm_tester(
            path.join(__dirname, pathToCircom),
            {
                output: ethaddr2Dir,
                // recompile: false,
            }
        );
        const w = await circuit.calculateWitness({
            "privkey": ["6862539325408419825", "7739665414899438580", "3575179427557022600", "11277760030985572954"],
            "publickey": "978617770967819762654777740949918972567359649306"
        });
        await circuit.checkConstraints(w);
    });
});
