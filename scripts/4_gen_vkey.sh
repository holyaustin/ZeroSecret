#!/bin/bash

# Get the absolute path of the current script
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# Find the directory containing the script
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Get the root path of the repository by going up a level (assuming the script is in a 'scripts' directory)
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the circuit.env file relative to the repository root
source "${REPO_ROOT}/scripts/circuit.env"


R1CS_FILE="$BUILD_DIR/$CIRCUIT_NAME.r1cs"
PHASE1="${REPO_ROOT}/circuits/powersOfTau28_hez_final_22.ptau"

echo "****EXPORTING VKEY****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=644000' npx snarkjs zkey export verificationkey "$BUILD_DIR"/"$CIRCUIT_NAME".zkey "$BUILD_DIR"/vkey.json
end=$(date +%s)
{ set +x; } 2>/dev/null
echo "DONE ($((end - start))s)"
echo

echo "****GENERATE SOLIDITY VERIFIER****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=644000' npx snarkjs zkey export solidityverifier "$BUILD_DIR"/"$CIRCUIT_NAME".zkey --sol "$BUILD_DIR"/verifier.sol
end=$(date +%s)
{ set +x; } 2>/dev/null
echo "DONE ($((end - start))s)"
echo
