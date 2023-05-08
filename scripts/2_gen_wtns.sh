#!/bin/bash
# Get the absolute path of the current script
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# Find the directory containing the script
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"

# Get the root path of the repository by going up a level (assuming the script is in a 'scripts' directory)
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Source the circuit.env file relative to the repository root
source "${REPO_ROOT}/scripts/circuit.env"

echo "****GENERATING WITNESS FOR SAMPLE INPUT****"
start=$(date +%s)
set -x
node "$BUILD_DIR"/"$CIRCUIT_NAME"_js/generate_witness.js "$BUILD_DIR"/"$CIRCUIT_NAME"_js/"$CIRCUIT_NAME".wasm "$BUILD_DIR"/input.json "$BUILD_DIR"/witness.wtns
{ set +x; } 2>/dev/null
end=$(date +%s)
echo "DONE ($((end - start))s)"
echo
