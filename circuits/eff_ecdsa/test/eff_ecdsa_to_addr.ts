import path from "path";
import wasm_tester from "../../../wasm_tester";
import { setupDirectories } from "../../test_utils"
import { privateToAddress, hashPersonalMessage, ecsign } from "@ethereumjs/util";
import { computeEffEcdsaPubInput } from "@personaelabs/spartan-ecdsa";
var EC = require("elliptic").ec;

const ec = new EC("secp256k1");
const pathToCircom = "../eff_ecdsa_to_addr.circom"

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;

export const getEffEcdsaCircuitInput = (privKey: Buffer, msg: Buffer) => {
    const msgHash = hashPersonalMessage(msg);
    const { v, r: _r, s } = ecsign(msgHash, privKey);

    console.log(_r, s)

    const r = BigInt("0x" + _r.toString("hex"));

    const circuitPubInput = computeEffEcdsaPubInput(r, v, msgHash);
    const input = {
        s: BigInt("0x" + s.toString("hex")),
        Tx: circuitPubInput.Tx,
        Ty: circuitPubInput.Ty,
        Ux: circuitPubInput.Ux,
        Uy: circuitPubInput.Uy
    };

    return input;
};

export const bytesToBigInt = (bytes: Uint8Array): bigint =>
    BigInt("0x" + Buffer.from(bytes).toString("hex"));


describe("eff_ecdsa_to_addr", () => {

    it("should output correct address", async () => {

        const outputDir = setupDirectories(pathToCircom);

        const circuit = await wasm_tester(
            path.join(__dirname, pathToCircom),
            {
                output: outputDir,
                prime: "secq256k1"
            }
        );

        const msg = Buffer.from("hello world");

        const privKey = Buffer.from(
            "f5b552f608f5b552f608f5b552f6082ff5b552f608f5b552f608f5b552f6082f",
            "hex"
        );
        const addr = BigInt(
            "0x" + privateToAddress(privKey).toString("hex")
        ).toString(10);

        const circuitInput = getEffEcdsaCircuitInput(privKey, msg);

        const w = await circuit.calculateWitness(circuitInput, true);

        await circuit.assertOut(w, {
            addr
        });

        await circuit.checkConstraints(w);
    });
});
