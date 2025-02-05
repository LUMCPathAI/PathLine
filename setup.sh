#!/bin/bash

echo "Setting up the pipeline repository..."

# List available modules
echo "Available modules:"
for module in modules/*; do
    if [ -d "$module" ]; then
        echo "- $(basename "$module")"
    fi
done

# Function to install a module
install_module() {
    local module=$1
    if [ -d "modules/$module" ]; then
        echo "[INFO] Installing $module..."
        bash "modules/$module/install.sh"
    else
        echo "[ERROR] Module $module not found!"
    fi
}

# Check if modules are passed as arguments
if [ $# -gt 0 ]; then
    echo "[INFO] Installing specified modules: $@"
    for module in "$@"; do
        install_module "$module"
    done
else
    # Prompt user for installation if no modules are passed
    read -p "Do you want to install all modules? (y/n): " choice
    if [ "$choice" == "y" ]; then
        for module in modules/*; do
            if [ -d "$module" ]; then
                install_module "$(basename "$module")"
            fi
        done
    else
        echo "Enter module names to install (space-separated):"
        read -a modules_to_install
        for module in "${modules_to_install[@]}"; do
            install_module "$module"
        done
    fi
fi

echo "Pipeline setup completed."