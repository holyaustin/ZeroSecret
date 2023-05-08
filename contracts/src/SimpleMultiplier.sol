// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Interface to PlonkVerifier.sol
interface IPlonkVerifier {
    function verifyProof(bytes memory proof, uint[] memory pubSignals) external view returns (bool);
}

contract SimpleMultiplier {
    address public s_plonkVerifierAddress;

    event ProofResult(bool result);

    constructor(address plonkVerifierAddress) {
        s_plonkVerifierAddress = plonkVerifierAddress;
    }

    // ZK proof is generated in the browser and submitted as a transaction w/ the proof as bytes.
    function submitProof(bytes memory proof, uint256[] memory pubSignals) public returns (bool) {
        bool result = IPlonkVerifier(s_plonkVerifierAddress).verifyProof(proof, pubSignals);
        emit ProofResult(result);
        return result;
    }
}