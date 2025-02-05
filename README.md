# **PathLine Repository**
Welcome to the **PathLine** repository! This repository provides a **modular framework** for running **computational pathology pipelines**, designed for **flexibility and ease of use**. Each module is independent and can be installed separately, with its **own local environment** stored under `PathLine/envs/`, ensuring reproducibility and minimal dependency conflicts.

---

## **📂 Repository Structure**
```
PathLine/
├── pipeline.sh                # Main pipeline execution script
├── setup.sh                   # Script to install selected modules
├── config.json                # Global configuration file for the pipeline
├── envs/                       # Directory for storing virtual environments
│   ├── tile_extractor/         # Environment for tile extractor
│   ├── nuclei_segmentor/       # Environment for nuclei segmentor
│   └── nuclei_graph_constructor/ # Environment for graph constructor
├── modules/                   # Directory containing pipeline modules
│   ├── tile_extractor/         # Tile extraction module
│   │   ├── install.sh          # Installation script for dependencies
│   │   ├── run.sh              # Script to run the module
│   │   ├── extract_tiles.py    # Main script for tile extraction
│   │   ├── requirements.txt    # Python dependencies
│   │   ├── README.md           # Documentation
│   ├── nuclei_segmentor/       # Nuclei segmentation module
│   │   ├── install.sh
│   │   ├── run.sh
│   │   ├── segment_nuclei.py
│   │   ├── requirements.txt
│   │   ├── README.md
│   ├── nuclei_graph_constructor/ # Graph construction module
│   │   ├── install.sh
│   │   ├── run.sh
│   │   ├── construct_graph.py
│   │   ├── requirements.txt
│   │   ├── README.md
└── README.md                  # General documentation
```

---

## **🚀 Getting Started**

### **1️⃣ Clone the repository**
```bash
git clone https://github.com/LUMCPathAI/PathLine.git
cd PathLine
```

### **2️⃣ Install the required modules**
Run the **setup script** to install selected modules.

#### **Install all modules**
```bash
bash setup.sh
```

#### **Install specific modules**
```bash
bash setup.sh tile_extractor nuclei_segmentor
```
Environments for each module will be stored in **`PathLine/envs/`**.

### **3️⃣ Run the pipeline**
Execute specific modules in sequence using `pipeline.sh`.

#### **Example: Running multiple modules**
```bash
bash pipeline.sh tile_extractor nuclei_segmentor nuclei_graph_constructor
```
- **Each module receives the same `config.json` as input** and writes relevant output paths to a shared pipeline output file.
- The pipeline logs will be saved in `pipeline_{timestamp}.output`.

---

## **📜 Global Configuration (`config.json`)**
PathLine uses a **centralized configuration file** (`config.json`), which is passed to each module. This **ensures consistency** across all steps.

### **Example `config.json`**
```json
{
  "modules": {
    "tile_extractor": {
      "slide_dirs": ["/path/to/slides1", "/path/to/slides2"],
      "annotation_file": "/path/to/annotation_file",
      "output_dir": "/path/to/output_dir",
      "tile_size": 256,
      "tile_um": "20x",
      "project_dir": "/path/to/project"
    },
    "nuclei_segmentor": {
      "output_dir": "/path/to/output_dir",
      "checkpoint": "/path/to/checkpoint"
    },
    "nuclei_graph_constructor": {
      "output_dir": "/path/to/output_dir"
    }
  }
}
```
Each module reads only its **own parameters** from this file.

---

## **🔹 Running the Pipeline (`pipeline.sh`)**
This script **executes multiple modules sequentially** using the **same configuration file**.

### **Script**
```bash
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
        bash "modules/$MODULE/run.sh" "config.json" "$OUTPUT_FILE"
    else
        echo "[ERROR] Module $MODULE not found!"
        exit 1
    fi
done

echo "[INFO] Pipeline completed successfully."
```

---

## **✅ Summary**
- **`setup.sh`** installs selected modules.
- **`pipeline.sh`** executes multiple modules in order.
- **Each module has** its own `install.sh` and `run.sh`.
- **Configurations are centrally managed** via `config.json`.
- **Environments are stored in** `PathLine/envs/`.
