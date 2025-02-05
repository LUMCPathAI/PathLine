#!/bin/bash

# Usage information
usage() {
    echo "Usage: $0 module1 module2 ..."
    exit 1
}

# Ensure at least one module is provided
if [ $# -eq 0 ]; then
    usage
fi

# Generate timestamped output file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="pipeline_${TIMESTAMP}.output"

echo "[INFO] Pipeline output will be saved to $OUTPUT_FILE"
touch "$OUTPUT_FILE"

# Iterate over all provided modules
for MODULE in "$@"; do
    if [ -d "modules/$MODULE" ]; then
        echo "[INFO] Running $MODULE..."
        
        # Run the module with the JSON config and output file as arguments
        bash "modules/$MODULE/run.sh" "config.json" "$OUTPUT_FILE"
    else
        echo "[ERROR] Module $MODULE not found!"
        exit 1
    fi
done

echo "[INFO] Pipeline completed successfully."