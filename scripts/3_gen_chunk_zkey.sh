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
PARTIAL_ZKEYS="$BUILD_DIR"/partial_zkeys
PHASE1="${REPO_ROOT}/circuits/powersOfTau28_hez_final_22.ptau"

source "${REPO_ROOT}/scripts/entropy.env"

if [ ! -d "$BUILD_DIR"/partial_zkeys ]; then
    echo "No partial_zkeys directory found. Creating partial_zkeys directory..."
    mkdir -p "$BUILD_DIR"/partial_zkeys
fi

echo "****GENERATING ZKEY NONCHUNKED 0****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=56000' npx snarkjs groth16 setup "$R1CS_FILE" "$PHASE1" "$PARTIAL_ZKEYS"/"$CIRCUIT_NAME"_0.zkey -e=$ENTROPY1
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo

echo "****GENERATING ZKEY NONCHUNKED 1****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=56000' npx snarkjs zkey contribute "$PARTIAL_ZKEYS"/"$CIRCUIT_NAME"_0.zkey "$PARTIAL_ZKEYS"/"$CIRCUIT_NAME"_1.zkey --name="1st Contributor Name" -v -e=$ENTROPY2
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo

echo "****GENERATING ZKEY NONCHUNKED FINAL****"
start=$(date +%s)
set -x
NODE_OPTIONS='--max-old-space-size=56000' npx snarkjs zkey beacon "$PARTIAL_ZKEYS"/"$CIRCUIT_NAME"_1.zkey "$BUILD_DIR"/"$CIRCUIT_NAME".zkey $BEACON 10 -n="Final Beacon phase2"
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo
