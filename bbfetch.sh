#!/bin/bash

echo "Please enter the filename of the list of accessions:"
read filename

echo "Please enter the number of parallel jobs you want to run:"
read num_jobs

max_attempts=10
log_dir="./log"
log_file="$log_dir/failed_accessions_$(date +%Y%m%d_%H%M%S).txt"

# Create log directory if it doesn't exist
mkdir -p "$log_dir"

download() {
 accession=$1
 declare -i attempt=0
 while [[ $attempt -lt $max_attempts ]]; do
    echo "Attempt $(($attempt + 1)) of $max_attempts for accession $accession"
    if datasets download genome accession "$accession" --filename "$accession.zip"; then
      if unzip -t "$accession.zip" &>/dev/null; then
        echo "Download and integrity check successful for accession $accession."
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

# Use GNU Parallel to run downloads in parallel with progress bar 
parallel --will-cite --progress -a "$filename" -j "$num_jobs" download