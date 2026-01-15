# GSFetch 


![Batch Biomolecular Fetch](https://github.com/pranjalpruthi/bbfetch/assets/47497714/75ca328d-ac51-40b4-a627-613eb82cec24)


GSFetch ⚡️Batch Biomolecular Fetch⚡️ is a powerful shell script designed to facilitate the batch downloading of genomic data from a specified list of accession numbers. Utilizing GNU Parallel, BBFetch efficiently manages multiple downloads in parallel, significantly reducing the time required to download large datasets. The tool also incorporates integrity checks for each download, ensuring the reliability of the downloaded files.

## Updates

ℹ️ **GSFetch-cli⚡ver-0.1 Updates:**

✅ Command-line argument support with flexible options  
✅ Customizable parallel jobs and retry attempts  
✅ Auto extraction with organized directory structure  
✅ Enhanced logging with failed accession tracking  
✅ Comprehensive verbose mode for debugging  
✅ Input validation and helpful error messages  
✅ Progress tracking and download statistics  


## Prerequisites

Before using BBFetch, there are a few prerequisites to ensure the script runs smoothly.

### NCBI Datasets CLI Tools

GSFetch requires the NCBI Datasets CLI tools to be pre-installed. These tools are available as a Conda package and include both datasets and dataformat commands necessary for downloading and verifying genomic data.

#### Install using Conda

1. First, create a Conda environment:
   ```bash
   conda create -n ncbi_datasets
   ```

2. Then, activate your new environment:
   ```bash
   conda activate ncbi_datasets
   ```

3. Finally, install the datasets Conda package:
   ```bash
   conda install -c conda-forge ncbi-datasets-cli
   ```

### GNU Parallel

Ensure you have GNU Parallel installed on your system. This tool allows BBFetch to download multiple datasets concurrently.

#### Install using Conda (Alternative Method)

You can also install GNU Parallel using Conda with the following commands:

```bash
conda config --add channels conda-forge
conda config --set channel_priority strict
mamba install parallel
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install parallel
```

#### Linux (Fedora)

```bash
sudo dnf install parallel
```

#### macOS

GNU Parallel can be installed on macOS using Homebrew:

```bash
brew install parallel
```

#### Windows

For Windows users, GNU Parallel can be run under WSL (Windows Subsystem for Linux). Install WSL and a Linux distribution from the Microsoft Store, then follow the Linux installation instructions above.

### Making the Script Executable

To make the script executable, navigate to the directory containing the script and run the following command:

```bash
chmod +x gsfetch.sh
```

## Usage

### Basic Syntax

```bash
./gsfetch.sh [OPTIONS]
```

### Required Options

- `-i, --input FILE` - Full path to the accession list file (one accession per line)

### Optional Options

- `-o, --output DIR` - Output directory for all downloaded files (default: same directory as input file)
- `-j, --jobs NUM` - Number of parallel jobs (default: 4)
- `-a, --attempts NUM` - Maximum download attempts per accession (default: 10)
- `-v, --verbose` - Enable verbose output for detailed logging
- `-h, --help` - Display help message

### Usage Examples

```bash
# Basic usage - output in same directory as input file
./gsfetch.sh -i /path/to/accessions.txt

# With custom output directory and parallel jobs
./gsfetch.sh -i /path/to/accessions.txt -o /data/genomes -j 8

# With custom output, jobs, and retry attempts
./gsfetch.sh -i /path/to/accessions.txt -o /output -j 8 -a 5

# With verbose output for debugging
./gsfetch.sh -i /path/to/accessions.txt -v

# Display help
./gsfetch.sh -h
```

### Output Structure

The script creates the following directory structure in the output directory:

```
output_directory/
├── dl/      - Downloaded zip files
├── data/    - Extracted genome data organized by accession
├── files/   - Collected .fna sequence files
└── log/     - Download logs and failed accession tracking
```

### Important Notes

- Before running the script with many parallel jobs, consider increasing the file descriptor limit to accommodate a large number of parallel downloads. This can be done by executing `ulimit -n [desired limit]` in your terminal.
- Ensure you have sufficient disk space and a stable internet connection to complete the downloads.
- The script automatically validates your input file and checks for required dependencies (NCBI Datasets CLI and GNU Parallel).
- Failed accessions are tracked in a timestamped log file in the `log/` directory for easy retry.

## Contributing

Contributions to BBFetch are welcome! Please feel free to fork the repository, make your changes, and submit a pull request.

## References

**Developed by:** Pranjal and Rounak

---
