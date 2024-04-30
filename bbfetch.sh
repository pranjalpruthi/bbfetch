#!/bin/bash

echo "Please enter the filename of the list of accessions:"
read filename

echo "Please enter the number of parallel jobs you want to run:"
read num_jobs

max_attempts=10

download() {
 accession=$1
 declare -i attempt=0
 while [[ $attempt -le $max_attempts ]]; do
    echo "Attempt $(($attempt + 1)) of $max_attempts for accession $accession"
    datasets download genome accession "$accession" --filename "$accession.zip"
    if unzip -t "$accession.zip" &>/dev/null; then
      echo "Download and integrity check successful for accession $accession."
      return 0
    else
      echo "Download failed or file is corrupted for accession $accession, retrying..."
      ((attempt++))
      if [[ $attempt -eq $max_attempts ]]; then
        echo "Maximum attempts reached, download failed for accession $accession."
        return 1
      fi
    fi
 done
}

export -f download

# Use GNU Parallel to run downloads in parallel
parallel --will-cite -a "$filename" -j "$num_jobs" download
