#!/bin/bash

echo "Please provide the full path to the folder containing the list of accessions:"
read list_folder

echo "Please enter the filename of the list of accessions (just the name, not the path):"
read list_filename

echo "Please enter the number of parallel jobs you want to run:"
read num_jobs

# Construct paths based on the provided list folder
list_path="$list_folder/$list_filename"
output_dir="$list_folder/dl"
extract_dir="$list_folder/data"
central_fna_dir="$list_folder/files"

max_attempts=10
log_dir="$list_folder/log"
log_file="$log_dir/failed_accessions_$(date +%Y%m%d_%H%M%S).txt"

# Create log, output, extract, and central .fna directories if they don't exist
mkdir -p "$log_dir"
mkdir -p "$output_dir"
mkdir -p "$extract_dir"
mkdir -p "$central_fna_dir"

download() {
 accession=$(echo "$1" | tr -d '\r' | xargs) # Remove carriage returns and trim whitespace
 declare -i attempt=0
 while [[ $attempt -lt $max_attempts ]]; do
    echo "Attempt $(($attempt + 1)) of $max_attempts for accession $accession"
    if datasets download genome accession "$accession" --filename "$output_dir/$accession.zip"; then
      if unzip -t "$output_dir/$accession.zip" &>/dev/null; then
        echo "Download and integrity check successful for accession $accession."
        # Extract the zip file into the specified extract directory
        foldername=$(basename "$output_dir/$accession.zip" .zip)
        mkdir -p "$extract_dir/$foldername"
        unzip "$output_dir/$accession.zip" -d "$extract_dir/$foldername"
        echo "Extracted $accession.zip into $extract_dir/$foldername"
        # Find and copy .fna files to the central directory
        find "$extract_dir/$foldername" -type f -name "*.fna" -exec cp {} "$central_fna_dir/" \;
        echo "Copied .fna files to $central_fna_dir"
        return 0
      else
        echo "Download failed or file is corrupted for accession $accession, retrying..."
      fi
    else
      exit_status=$?
      echo "Error occurred during download for accession $accession with exit status $exit_status, retrying..."
    fi
    # Log the failed accession to the log file only if it's the last attempt
    if [[ $attempt -eq $((max_attempts - 1)) ]]; then
      echo "$accession" >> "$log_file"
      echo "Maximum attempts reached, download failed for accession $accession."
    fi
    ((attempt++))
 done
}

export -f download
export log_file
export max_attempts
export output_dir
export extract_dir
export central_fna_dir

# Use GNU Parallel to run downloads in parallel with progress bar 
parallel --will-cite --progress -a "$list_path" -j "$num_jobs" download