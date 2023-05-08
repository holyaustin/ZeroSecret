import path from "path";
import wasm_tester from "../../../wasm_tester";
import { setupDirectories } from "../../test_utils"

const pathToCircom = "../Multiplier2.circom"

describe("Test multiplier2", function () {
    const multiplier2Dir = setupDirectories(pathToCircom);

    it("Checking the compilation of a simple circuit generating wasm in a given folder without recompiling", async function () {
        const circuit = await wasm_tester(
            path.join(__dirname, pathToCircom),
            {
                output: multiplier2Dir,
                // recompile: false,
            }
        );
        const w = await circuit.calculateWitness({ a: 6, b: 3 });
        await circuit.checkConstraints(w);
    });
});
