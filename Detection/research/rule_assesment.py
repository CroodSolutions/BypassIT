"""
Title: YARA Rule Analysis Tool
Author: BypassIT Research Team
Date Created: August 7th, 2024
Last Modified: August 7th, 2024
Description:
This script is designed to analyze the output of multiple YARA scans. It processes a file containing the results of various YARA rule executions and provides insights into which rules were triggered most frequently across different files. The tool also reports on the total number of unique rules encountered during the scan.
Dependencies:
- Python 3.x (ensure it's installed in your environment)
- sys module for command line argument processing
- collections module to handle rule hit counts efficiently
Usage:
1. Ensure you have a Python interpreter capable of running this script.
2. Run the script from the command line by providing the path to the YARA results file as an argument. Example: python3 rule_assesment.py yara_results.txt
3. The script will output the rules with the most hits and provide statistics on the total number of unique files and rules scanned.
"""

import sys
from collections import defaultdict

def analyze_yara_output(file_path):
    rule_hits = defaultdict(int)
    total_files = set()

    try:
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 2:
                    rule = parts[0]
                    file = parts[-1]
                    rule_hits[rule] += 1
                    total_files.add(file)

        print("Rules with most hits:")
        for rule, hits in sorted(rule_hits.items(), key=lambda x: x[1], reverse=True):
            print(f"{rule}: {hits} hits")

        print(f"\nTotal unique rules: {len(rule_hits)}")
        print(f"Total files scanned: {len(total_files)}")

    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <path_to_yara_results_file>")
        sys.exit(1)
    
    yara_results_file = sys.argv[1]
    analyze_yara_output(yara_results_file)