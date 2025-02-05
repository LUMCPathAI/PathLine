#!/bin/bash

# Set directory to script location
ROOT_PATH="$(dirname "$(realpath "$0")")"

echo "Root path: $ROOT_PATH"

# Move two directories back to the PathLine directory
PATHLINE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

echo "PathLine path: $PATHLINE_PATH"

# Set the Conda environment directory
ENV_PATH="$PATHLINE_PATH/envs/tile_extractor"

echo "Environment path: $ENV_PATH"

# Installation script for module1
echo "Installing tile extractor module...."

# Check if Conda is installed
if command -v conda &> /dev/null; then

    echo "[INFO] Creating a local Conda environment at $ENV_PATH..."
    conda create --prefix "$ENV_PATH" python=3.8 -y

    echo "[INFO] Installing dependencies..."
    source ~/.bashrc  # Ensure Conda is initialized

    # Activate environment using full path
    conda activate "$ENV_PATH"

    echo "[INFO] Upgrading pip, setuptools, and wheel..."
    pip install --upgrade pip setuptools wheel

    pip install -r "$ROOT_PATH/requirements.txt"

    echo "[INFO] To activate this environment, run: conda activate $ENV_PATH"
    echo "[INFO] Installation complete, environment saved in Conda."

    conda deactivate

elif command -v python3 &> /dev/null; then
    echo "[INFO] Creating a local virtual environment in $ENV_PATH..."
    python3 -m venv "$ENV_PATH"

    # Activate virtualenv
    source "$ENV_PATH/bin/activate"

    echo "[INFO] Upgrading pip, setuptools, and wheel..."
    pip install --upgrade pip setuptools wheel

    echo "[INFO] Installing dependencies..."
    pip install -r "$ROOT_PATH/requirements.txt"

    echo "[INFO] Installation complete, environment saved in $ENV_PATH"

else
    echo "[ERROR] No supported environment manager found. Install Conda or Python3."
    exit 1
fi

echo "Tile extractor module installed successfully."
