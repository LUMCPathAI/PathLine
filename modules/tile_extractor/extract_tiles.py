#!/usr/bin/env python
"""
extract_tiles.py
----------------
Extract TFRecords (tiles) from whole‐slide images using SlideFlow.
Reads parameters from a JSON configuration file and writes output paths
to a dataset output file (e.g. dataset.json).
"""

import json
import sys
import os
import argparse
import logging
import slideflow as sf

def load_json(file_path):
    """Load and return JSON data from a file."""
    try:
        with open(file_path, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        logging.error(f"Error loading {file_path}: {e}")
        sys.exit(1)

def check_required_params(params, required_keys):
    """Exit if any required parameter is missing."""
    missing = [key for key in required_keys if key not in params]
    if missing:
        logging.error(f"Missing required parameters in config: {missing}")
        sys.exit(1)

def create_slideflow_project(project_dir, slide_dirs, annotation_file):
    """
    Create a new SlideFlow project if it does not exist.
    Uses the first slide directory to create the project and then adds the others.
    """
    logging.info(f"[INFO] Using project directory: {project_dir}")
    if not os.path.exists(project_dir):
        logging.info("[INFO] Creating a new SlideFlow project...")
        # Use the first slide directory to create the project
        first_source = slide_dirs[0]
        project = sf.create_project(root=project_dir, slides=first_source, annotations=annotation_file)
        logging.info(f"[INFO] Created project with initial slides: {first_source}")
        # Add additional slide sources if any
        for slide_dir in slide_dirs[1:]:
            # Use the basename of the directory as the source name
            source_name = os.path.basename(os.path.normpath(slide_dir))
            project.add_source(name=source_name, slides=slide_dir)
            logging.info(f"[INFO] Added slide source: {source_name} ({slide_dir})")
    else:
        logging.info(f"[INFO] Loading existing SlideFlow project from {project_dir}")
        project = sf.load_project(project_dir)
    return project

def extract_tiles_for_all_sources(project, params):
    """
    For each dataset source in the project, run tile extraction.
    Returns the output directory information for later use.
    """
    logging.info(f"[INFO] Extracting tiles with tile size {params['tile_size']} pixels at {params['tile_um']} magnification...")
    # Create a dataset for the entire project (assumes project.sources has been set up)
    dataset = project.dataset(tile_px=params["tile_size"], tile_um=params["tile_um"])
    dataset.extract_tiles(
        num_threads=params["num_threads"],
        mpp_override=params["mpp_override"],
        enable_downsample=params["enable_downsample"],
        normalizer=params["normalizer"],
        normalizer_source=params["normalizer_source"],
        report=params["report"],
        save_tiles=params["save_tiles"],
        qc=params["qc"],
        use_edge_tiles=params["use_edge_tiles"]
    )
    logging.info("[INFO] TFRecords extraction complete for all slide sources.")
    return dataset

def main():
    parser = argparse.ArgumentParser(description="Extract TFRecords (tiles) using SlideFlow.")
    parser.add_argument("config_file", help="Path to JSON configuration file.")
    parser.add_argument("dataset_output_file", help="Path to output dataset JSON file (to record output paths).")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    # Load configuration and extract parameters for the tile_extractor module
    config = load_json(args.config_file)
    try:
        params = config["modules"]["tile_extractor"]
    except KeyError:
        logging.error("No 'tile_extractor' module found in config.")
        sys.exit(1)

    #Set the default values for the parameters
    params.setdefault("num_threads", 8)
    params.setdefault("mpp_override", None)
    params.setdefault("enable_downsample", False)
    params.setdefault("normalizer", 'reinhard_mask')
    params.setdefault("normalizer_source", 'v3')
    params.setdefault("report", False)
    params.setdefault("save_tiles", False)
    params.setdefault("qc", 'otsu')
    params.setdefault("tile_size", 256)
    params.setdefault("tile_um", 128)
    params.setdefault("use_edge_tiles", True)

    # Check for required parameters
    required_keys = ["slide_dirs", "annotation_file", "output_dir", "tile_size", "tile_um", "project_dir"]
    check_required_params(params, required_keys)

    slide_dirs = params["slide_dirs"]
    if not isinstance(slide_dirs, list) or not slide_dirs:
        logging.error("Parameter 'slide_dirs' must be a non-empty list.")
        sys.exit(1)

    annotation_file = params["annotation_file"]
    output_dir = params["output_dir"]
    project_dir = params["project_dir"]

    logging.info(f"[INFO] Extracting tiles from slide directories: {slide_dirs}")
    logging.info(f"[INFO] Using annotation file: {annotation_file}")
    logging.info(f"[INFO] Output will be saved to: {output_dir}")

    # Create or load the SlideFlow project using the provided slide directories
    project = create_slideflow_project(project_dir, slide_dirs, annotation_file)

    # Run tile extraction for all sources (the dataset extraction writes TFRecords and tiles)
    extract_tiles_for_all_sources(project, params)

    # Get the dataset output information for writing to the output JSON file
    dataset_output = {
        "project_dir": project_dir,
        "tfrecords_dir": os.path.join(project_dir, "tfrecords"),
        "tile_dir": os.path.join(project_dir, "tiles"),
    }

    # Write the dataset output information to the output JSON file.
    try:
        with open(args.dataset_output_file, "w") as f:
            json.dump(dataset_output, f, indent=4)
        logging.info(f"[INFO] Dataset output written to {args.dataset_output_file}")
    except Exception as e:
        logging.error(f"Error writing dataset output file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()