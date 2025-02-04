# PathLine Repository
Welcome to the PathLine repository! This repository provides a modular framework for running complex computational pathology pipelines, with a focus on flexibility and ease of use. Each module is independent and can be installed with its own environment, allowing users to install only what they need for their specific workflow.

## Repository Structure
```
PathLine/
├── pipeline.sh                # Main bash-based pipeline script
├── modules/
│   ├── module1/
│   │   ├── install.sh         # Installation script for module1
│   │   ├── requirements.txt   # Dependencies for module1 (if Python-based)
│   │   ├── Dockerfile         # Optional: Dockerfile for module1
│   │   ├── script1.py         # Scripts or executables for module1
│   │   └── README.md          # Documentation for module1
│   ├── module2/
│   │   ├── install.sh         # Installation script for module2
│   │   ├── requirements.txt   # Dependencies for module2
│   │   ├── Dockerfile         # Optional: Dockerfile for module2
│   │   ├── script2.py
│   │   └── README.md
├── README.md                  # General documentation
└── setup.sh                   # Setup script for the overarching pipeline
```

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/LUMCPathAI/PathLine.git
   cd PathLine
   ```

2. Run the setup script to install modules:
   ```bash
   bash setup.sh
   ```
   - You can choose to install all modules or select specific ones based on your needs.

3. Run the main pipeline script:
   ```bash
   bash pipeline.sh [module_name]
   ```
   - Example: `bash pipeline.sh module1`

## Overarching Pipeline Script
The `pipeline.sh` script dynamically runs the selected module. Below is the content of the script:

```bash
#!/bin/bash

# Usage information
usage() {
    echo "Usage: $0 [module_name]"
    echo "Example: $0 module1"
    exit 1
}

# Check if a module is passed
if [ $# -eq 0 ]; then
    usage
fi

MODULE=$1

# Check if the module exists and run it
if [ -d "modules/$MODULE" ]; then
    echo "Running $MODULE..."
    bash modules/$MODULE/run.sh
else
    echo "Module $MODULE not found!"
    exit 1
fi
```

## Setup Script for Installing Modules
The `setup.sh` script allows users to install specific modules or all modules:

```bash
#!/bin/bash

echo "Setting up the pipeline repository..."

# List available modules
echo "Available modules:"
for module in modules/*; do
    if [ -d "$module" ]; then
        echo "- $(basename $module)"
    fi
done

# Prompt user for installation
read -p "Do you want to install all modules? (y/n): " choice
if [ "$choice" == "y" ]; then
    for module in modules/*; do
        if [ -d "$module" ]; then
            bash "$module/install.sh"
        fi
    done
else
    echo "Enter module names to install (space-separated):"
    read -a modules_to_install
    for module in "${modules_to_install[@]}"; do
        if [ -d "modules/$module" ]; then
            bash "modules/$module/install.sh"
        else
            echo "Module $module not found!"
        fi
    done
fi

echo "Pipeline setup completed."
```

## Example Individual Module
Each module should contain its own `install.sh` script for environment setup. Below is an example for `module1`:

**`modules/module1/install.sh`:**
```bash
#!/bin/bash

# Installation script for module1
echo "Installing module1..."

# Check if Conda is installed
if command -v conda &> /dev/null; then
    conda create -n module1-env python=3.8 -y
    conda activate module1-env
    pip install -r requirements.txt
elif command -v python3 &> /dev/null; then
    python3 -m venv module1-env
    source module1-env/bin/activate
    pip install -r requirements.txt
else
    echo "No supported environment manager found. Install Conda or Python3."
    exit 1
fi

echo "module1 installed successfully."
```

## Adding New Modules
1. Create a new directory under `modules/` with the module name.
2. Add an `install.sh` script for environment setup.
3. Include a `requirements.txt` (if needed) and optionally a `Dockerfile`.
4. Write the main functionality in your preferred scripting language (e.g., Python, R).
5. Document your module in a `README.md` inside the module folder.

## Best Practices
- Use version control (e.g., Git) to track changes in the pipeline and modules.
- Add automated testing to ensure pipeline and module functionality.
- Include license information in the repository.
- Follow consistent coding standards across modules.
- Use environment management tools like Conda for reproducibility.

## Contribution
We welcome contributions! Please fork the repository and submit a pull request with your changes. If adding a new module, ensure it follows the structure outlined above.

