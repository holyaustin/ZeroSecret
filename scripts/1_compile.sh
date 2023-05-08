#!/bin/bash
# Get the absolute path of the current script
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# Find the directory containing the script
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Get the root path of the repository by going up a level (assuming the script is in a 'scripts' directory)
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the circuit.env file relative to the repository root
source "${REPO_ROOT}/scripts/circuit.env"

CIRCOM_PATH="$REPO_ROOT/circuits/$CIRCUIT_NAME.circom"

if [ ! -d "$BUILD_DIR" ]; then
    echo "No build directory found. Creating build directory..."
    mkdir -p "$BUILD_DIR"
fi


echo '****COMPILING CIRCUIT****'
start=$(date +%s)
set -x
circom "$CIRCOM_PATH" --r1cs --wasm --sym --c --wat --output "$BUILD_DIR"
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo

echo '****INSPECTING CIRCUIT FOR UNDERCONSTRAINTS (OPTIONAL, CAN FORCE EXIT)****'
start=$(date +%s)
set -x
circom "$CIRCOM_PATH" --inspect
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo
