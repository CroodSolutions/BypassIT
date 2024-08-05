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