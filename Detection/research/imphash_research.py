"""
Title: Import Hash Analysis Tool
Author: BypassIT Research Team
Date Created: August 7th, 2024
Last Modified: August 7th, 2024
Description:
This script is designed to analyze executable files in a specified directory and compute their import hashes (imphash). The imphash is used as a unique identifier for the set of imported functions within an executable. This tool scans through all files in the given directory, identifies PE (Portable Executable) format files, computes their imphash, and then reports the most common import hashes found.
Dependencies:
- Python 3.x
- pefile library (pip install pefile) for parsing PE files
- argparse module for command line argument processing
Usage:
1. Install the required pefile library using pip: pip install pefile
2. Run the script from the command line and provide the path to the directory you want to scan as an argument. Example: python3 imphash_research.py /path/to/directory
3. The script will output the most common import hashes found in the specified directory, along with their respective counts.
"""

import os
import pefile
from collections import Counter
import argparse

def get_imphash(file_path):
    try:
        pe = pefile.PE(file_path)
        return pe.get_imphash()
    except Exception:
        return None

def get_files_in_directory(directory):
    file_paths = []
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            file_paths.append(file_path)
    return file_paths

def main(directory):
    imphash_counter = Counter()
    
    # Get the list of files in the directory
    file_paths = get_files_in_directory(directory)
    
    # Calculate imphash for each file and update the counter
    for file_path in file_paths:
        imphash = get_imphash(file_path)
        if imphash is not None:
            imphash_counter[imphash] += 1
    
    # Print the most common imphashes
    print("Most common imphashes and their counts:")
    for imphash, count in imphash_counter.most_common(10):
        print(f"Imphash: {imphash}, Count: {count}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Scan a directory for executable files and compute their import hashes.")
    parser.add_argument("directory", type=str, help="Path to the directory to scan")
    
    args = parser.parse_args()
    
    main(args.directory)