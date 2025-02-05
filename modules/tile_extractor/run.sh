#!/bin/bash

# Ensure arguments are passed
if [ $# -ne 2 ]; then
    echo "Usage: $0 config.json output_file"
    exit 1
fi

CONFIG_FILE=$1
OUTPUT_FILE=$2

PATHLINE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"
ENV_DIR="$PATHLINE_PATH/envs/tile_extractor"

echo "[INFO] Running tile extraction pipeline..."
echo "[INFO] Configuration file: $CONFIG_FILE"
echo "[INFO] Output file: $OUTPUT_FILE"
echo "[INFO] PathLine path: $PATHLINE_PATH"
echo "[INFO] Environment path: $ENV_DIR"

export SF_BACKEND=torch
export SF_SLIDE_BACKEND=cucim

# --- Step 1: Ensure Conda is Available ---
if [[ -n "$SLURM_JOB_ID" ]]; then
    echo "[INFO] Detected SLURM job. Loading Conda module..."
    module load tools/miniconda/python3.9/4.12.0
    echo "[INFO] Conda module loaded."
else
    if command -v conda &> /dev/null; then
        echo "[INFO] Conda found. Initializing..."
        eval "$(command conda 'shell.bash' 'hook')"
    elif [ -f "/share/software/tools/miniconda/3.9/4.12.0/etc/profile.d/conda.sh" ]; then
        echo "[INFO] Sourcing Conda manually..."
        source "/share/software/tools/miniconda/3.9/4.12.0/etc/profile.d/conda.sh"
    else
        echo "[ERROR] Conda not found. Exiting."
        exit 1
    fi
fi

if [ ! -d "$ENV_DIR" ]; then
    echo "[ERROR] Conda environment not found at $ENV_DIR. Please create it first."
    exit 1
fi

# --- Step 2: Activate Conda Environment ---
if [ -d "$ENV_DIR" ]; then
    echo "[INFO] Activating Conda environment at $ENV_DIR..."
    source "/share/software/tools/miniconda/3.9/4.12.0/etc/profile.d/conda.sh"
    conda activate "$ENV_DIR"
else
    echo "[WARNING] Conda environment not found at $ENV_DIR. Running without activation."
fi


# --- Step 3: Verify Python & Packages ---
echo "[INFO] Python interpreter: $(which python)"
echo "[INFO] Python version: $(python --version)"

if ! python -c "import slideflow" &> /dev/null; then
    echo "[ERROR] 'slideflow' module not found in environment. Exiting."
    exit 1
fi

# --- Step 4: Run Python Script ---
echo "[INFO] Running extract_tiles.py..."
if python3 modules/tile_extractor/extract_tiles.py "$CONFIG_FILE" "$OUTPUT_FILE"; then
    echo "[INFO] Script executed successfully."
else
    echo "[ERROR] extract_tiles.py encountered an error."
    exit 1
fi

# --- Step 5: Deactivate Environment ---
if [ -d "$ENV_DIR" ]; then
    echo "[INFO] Deactivating Conda environment..."
    conda deactivate || deactivate
fi

echo "[INFO] Tile extraction completed."
