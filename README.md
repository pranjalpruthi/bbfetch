# BBFetch Tool

BBFetch is a powerful shell script designed to facilitate the batch downloading of genomic data from a specified list of accession numbers. Utilizing GNU Parallel, BBFetch efficiently manages multiple downloads in parallel, significantly reducing the time required to download large datasets. The tool also incorporates integrity checks for each download, ensuring the reliability of the downloaded files.

## Prerequisites

Before using BBFetch, ensure you have GNU Parallel installed on your system. Additionally, the script must be made executable. Follow the instructions below to set up your environment.

### Installing GNU Parallel

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

