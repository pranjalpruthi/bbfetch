# BBFetch 


![Batch Biomolecular Fetch](https://github.com/pranjalpruthi/bbfetch/assets/47497714/75ca328d-ac51-40b4-a627-613eb82cec24)


BBFetch ⚡️Batch Biomolecular Fetch⚡️ is a powerful shell script designed to facilitate the batch downloading of genomic data from a specified list of accession numbers. Utilizing GNU Parallel, BBFetch efficiently manages multiple downloads in parallel, significantly reducing the time required to download large datasets. The tool also incorporates integrity checks for each download, ensuring the reliability of the downloaded files.



## Updates

ℹ️ **BBfetch-cli⚡ver-0.0.5 Updates:**

✅ Auto sequence sent to file's folder and data folder for unzip datasets and dl folder for datasets  
✅ Added Support for corrupt file validation✨  
✅ ✨Auto Extraction finally😍  
✅ L⭕G file maintenance💁🏻‍♂️ failed ids go there  


## Prerequisites

Before using BBFetch, there are a few prerequisites to ensure the script runs smoothly.

### NCBI Datasets CLI Tools

BBFetch requires the NCBI Datasets CLI tools to be pre-installed. These tools are available as a Conda package and include both datasets and dataformat commands necessary for downloading and verifying genomic data.

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

To make the BBFetch script executable, navigate to the directory containing the script and run the following command:

```bash
chmod +x bbfetch.sh
```

## Usage

1. Prepare a text file containing the list of accession numbers you wish to download, with each accession number on a separate line.
2. Run the script by executing `./bbfetch.sh` in your terminal.
3. When prompted, enter the filename of your list of accession numbers.

### Important Notes

- Before running the script, consider increasing the file descriptor limit to accommodate a large number of parallel downloads. This can be done by executing `ulimit -n [desired limit]` in your terminal.
- Ensure you have sufficient disk space and a stable internet connection to complete the downloads.

## Contributing

Contributions to BBFetch are welcome! Please feel free to fork the repository, make your changes, and submit a pull request.


---
