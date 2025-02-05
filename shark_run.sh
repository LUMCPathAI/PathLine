#!/bin/bash
#!/bin/bash
#
# Example pipeline.sh using a Hugging Face token.
#
# Usage:
#   ./pipeline.sh <huggingface_token>

#SBATCH -J PATHLINE
#SBATCH --mem=100G
#SBATCH --partition=highmemgpu,gpu,PATHgpu
#SBATCH --time=100:00:00
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=s.brussee@lumc.nl
#SBATCH --mail-type=BEGIN,END,FAIL

# 2) Load environment modules
module purge > /dev/null 2>&1
module load library/cuda/12.2.2/gcc.8.5.0
module load library/cudnn/12.2/cudnn
module load library/openslide/3.4.1/gcc-8.3.1
module load system/python/3.9.17
module load tools/miniconda/python3.9/4.12.0
module load system/gcc/13.2.0
###conda init bash
###chmod +x setup.sh
###bash setup.sh tile_extractor
###chmod +x modules/tile_extractor/run.sh
bash modules/tile_extractor/run.sh "config_siemen.json" "tile_extractor_output"