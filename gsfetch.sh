#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
list_file_path=""
output_base_dir=""
num_jobs=4
max_attempts=10
verbose=false

# Animation function
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Banner animation
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║          🧬 Genome Sequence Fetch v0.1 🧬                ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    sleep 0.5
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}Progress: [${GREEN}"
    printf "%${completed}s" | tr ' ' '█'
    printf "${NC}"
    printf "%${remaining}s" | tr ' ' '░'
    printf "${CYAN}] ${YELLOW}%d%%${NC} (%d/%d)" $percentage $current $total
}

# Usage function
usage() {
    cat << EOF
${CYAN}Usage:${NC} $0 [OPTIONS]

${YELLOW}Required Options:${NC}
    -i, --input FILE        Full path to the accession list file

${YELLOW}Optional Options:${NC}
    -o, --output DIR        Output directory for all downloaded files
                            (default: same directory as input file)
    -j, --jobs NUM          Number of parallel jobs (default: 4)
    -a, --attempts NUM      Maximum download attempts (default: 10)
    -v, --verbose           Enable verbose output
    -h, --help              Display this help message

${CYAN}Examples:${NC}
    # Save output in same directory as input file
    $0 -i /path/to/accessions.txt -j 8

    # Save output in a specific directory
    $0 -i /path/to/accessions.txt -o /data/genomes -j 8 -a 5

    # With verbose output
    $0 -i /path/to/accessions.txt -o /output -v

${CYAN}Description:${NC}
    Downloads genome data from NCBI using accession numbers, extracts
    the archives, and collects all .fna files into a central directory.
    
    Output structure (in specified output directory):
      ├── dl/          - Downloaded zip files
      ├── data/        - Extracted genome data
      ├── files/       - Collected .fna files
      └── log/         - Download logs and failed accessions

EOF
    exit 1
}

# Parse command line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        usage
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                list_file_path="$2"
                shift 2
                ;;
            -o|--output)
                output_base_dir="$2"
                shift 2
                ;;
            -j|--jobs)
                num_jobs="$2"
                shift 2
                ;;
            -a|--attempts)
                max_attempts="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                usage
                ;;
        esac
    done

    # Validate required arguments
    if [ -z "$list_file_path" ]; then
        echo -e "${RED}Error: Input file path is required!${NC}\n"
        usage
    fi
}

# Validation function
validate_inputs() {
    echo -e "\n${CYAN}🔍 Validating inputs...${NC}"
    
    # Convert to absolute path
    list_file_path=$(readlink -f "$list_file_path" 2>/dev/null || realpath "$list_file_path" 2>/dev/null || echo "$list_file_path")
    
    if [ ! -f "$list_file_path" ]; then
        echo -e "${RED}✗ Error: File '$list_file_path' does not exist!${NC}"
        exit 1
    fi
    
    # Extract directory and filename from the path
    list_folder=$(dirname "$list_file_path")
    list_filename=$(basename "$list_file_path")
    
    # Set output base directory
    if [ -z "$output_base_dir" ]; then
        output_base_dir="$list_folder"
        echo -e "${YELLOW}ℹ  No output directory specified, using input file location${NC}"
    else
        # Convert output directory to absolute path
        output_base_dir=$(readlink -f "$output_base_dir" 2>/dev/null || realpath "$output_base_dir" 2>/dev/null || echo "$output_base_dir")
        
        # Create output directory if it doesn't exist
        if [ ! -d "$output_base_dir" ]; then
            echo -e "${YELLOW}ℹ  Creating output directory: $output_base_dir${NC}"
            mkdir -p "$output_base_dir"
            if [ $? -ne 0 ]; then
                echo -e "${RED}✗ Error: Cannot create output directory '$output_base_dir'${NC}"
                exit 1
            fi
        fi
    fi
    
    if ! command -v datasets &> /dev/null; then
        echo -e "${RED}✗ Error: 'datasets' command not found. Please install NCBI datasets CLI.${NC}"
        exit 1
    fi
    
    if ! command -v parallel &> /dev/null; then
        echo -e "${RED}✗ Error: 'parallel' command not found. Please install GNU Parallel.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All validations passed!${NC}"
    sleep 0.5
}

# Display configuration
show_config() {
    echo -e "\n${MAGENTA}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                    Configuration                         ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}  📄 Input File:${NC}        $list_file_path"
    echo -e "${CYAN}  📂 Output Base Dir:${NC}   $output_base_dir"
    echo -e "${CYAN}  🔢 Parallel Jobs:${NC}    $num_jobs"
    echo -e "${CYAN}  🔄 Max Attempts:${NC}     $max_attempts"
    echo -e "${CYAN}  📊 Verbose Mode:${NC}     $verbose"
    echo ""
    echo -e "${YELLOW}  Output Structure:${NC}"
    echo -e "${CYAN}    📥 Downloads:${NC}       $output_dir"
    echo -e "${CYAN}    📦 Extracted:${NC}       $extract_dir"
    echo -e "${CYAN}    🧬 FNA Files:${NC}       $central_fna_dir"
    echo -e "${CYAN}    📋 Logs:${NC}            $log_dir"
    echo ""
}

# Download function with enhanced logging
download() {
    accession=$(echo "$1" | tr -d '\r' | xargs)
    declare -i attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if [ "$verbose" = true ]; then
            echo -e "${YELLOW}⏳ Attempt $(($attempt + 1))/$max_attempts for $accession${NC}"
        fi
        
        if datasets download genome accession "$accession" --filename "$output_dir/$accession.zip" 2>/dev/null; then
            if unzip -t "$output_dir/$accession.zip" &>/dev/null; then
                if [ "$verbose" = true ]; then
                    echo -e "${GREEN}✓ Download successful: $accession${NC}"
                fi
                
                # Extract
                foldername=$(basename "$output_dir/$accession.zip" .zip)
                mkdir -p "$extract_dir/$foldername"
                unzip -q "$output_dir/$accession.zip" -d "$extract_dir/$foldername"
                
                # Copy .fna files
                find "$extract_dir/$foldername" -type f -name "*.fna" -exec cp {} "$central_fna_dir/" \;
                
                return 0
            fi
        fi
        
        if [[ $attempt -eq $((max_attempts - 1)) ]]; then
            echo "$accession" >> "$log_file"
            if [ "$verbose" = true ]; then
                echo -e "${RED}✗ Failed: $accession${NC}"
            fi
        fi
        
        ((attempt++))
    done
    
    return 1
}

# Main execution
main() {
    show_banner
    parse_args "$@"
    
    validate_inputs
    
    # Construct paths based on the output base directory
    list_path="$list_file_path"
    output_dir="$output_base_dir/dl"
    extract_dir="$output_base_dir/data"
    central_fna_dir="$output_base_dir/files"
    log_dir="$output_base_dir/log"
    log_file="$log_dir/failed_accessions_$(date +%Y%m%d_%H%M%S).txt"
    
    # Create directories
    mkdir -p "$log_dir" "$output_dir" "$extract_dir" "$central_fna_dir"
    
    show_config
    
    # Count total accessions
    total_accessions=$(wc -l < "$list_path")
    echo -e "${CYAN}📋 Total accessions to download: ${YELLOW}$total_accessions${NC}\n"
    
    # Countdown
    echo -e "${YELLOW}Starting download in...${NC}"
    for i in 3 2 1; do
        echo -e "${GREEN}  $i${NC}"
        sleep 1
    done
    echo -e "${GREEN}  GO! 🚀${NC}\n"
    
    # Export functions and variables
    export -f download
    export log_file max_attempts output_dir extract_dir central_fna_dir verbose
    
    # Run parallel downloads
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  Downloading Genomes...                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    parallel --will-cite --progress -a "$list_path" -j "$num_jobs" download
    
    # Summary
    echo -e "\n\n${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   Download Complete! ✓                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    if [ -f "$log_file" ] && [ -s "$log_file" ]; then
        failed_count=$(wc -l < "$log_file")
        echo -e "${YELLOW}⚠️  Failed accessions: $failed_count${NC}"
        echo -e "${CYAN}📄 Log file: $log_file${NC}\n"
    else
        echo -e "${GREEN}🎉 All downloads completed successfully!${NC}\n"
    fi
    
    fna_count=$(find "$central_fna_dir" -type f -name "*.fna" | wc -l)
    echo -e "${CYAN}🧬 Total .fna files collected: ${YELLOW}$fna_count${NC}"
    echo -e "${CYAN}📂 All files saved in: ${YELLOW}$output_base_dir${NC}\n"
}

# Run main function with all arguments
main "$@"
