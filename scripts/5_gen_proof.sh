#!/bin/bash

# Get the absolute path of the current script
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# Find the directory containing the script
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Get the root path of the repository by going up a level (assuming the script is in a 'scripts' directory)
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the circuit.env file relative to the repository root
source "${REPO_ROOT}/scripts/circuit.env"


echo "****GENERATING PROOF FOR SAMPLE INPUT****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=644000' npx snarkjs groth16 prove "$BUILD_DIR"/"$CIRCUIT_NAME".zkey "$BUILD_DIR"/witness.wtns "$BUILD_DIR"/proof.json "$BUILD_DIR"/public.json
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo

echo "****VERIFYING PROOF FOR SAMPLE INPUT****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=644000' npx snarkjs groth16 verify "$BUILD_DIR"/vkey.json "$BUILD_DIR"/public.json "$BUILD_DIR"/proof.json
end=$(date +%s)
{ set +x; } 2>/dev/null
echo "DONE ($((end - start))s)"
echo
