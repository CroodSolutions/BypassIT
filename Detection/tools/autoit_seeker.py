import os
import re
import yaml
import csv
import json
import logging
import binascii
from argparse import ArgumentParser, Namespace
from collections import defaultdict
from datetime import datetime
from typing import List, Dict
from rich import print
from rich.console import Console
from rich.table import Table
from rich import print as rprint

def print_banner():
    banner = """
__________                                   .______________ __________                                          .__     
\\______   \\___.__.___________    ______ _____|   \\__    ___/ \\______   \\ ____   ______ ____ _____ _______   ____ |  |__  
 |    |  _<   |  |\\____ \\__  \\  /  ___//  ___/   | |    |     |       _// __ \\ /  ___// __ \\\\__  \\\\_  __ \\_/ ___\\|  |  \\ 
 |    |   \\\\___  ||  |_> > __ \\_\\___ \\ \\___ \\|   | |    |     |    |   \\  ___/ \\___ \\\\  ___/ / __ \\|  | \\/\\  \\___|   Y  \\\\
 |______  // ____||   __(____  /____  >____  >___| |____|     |____|_  /\\___  >____  >\\___  >____  /__|    \\___  >___|  /
        \\/ \\/     |__|       \\/     \\/     \\/                        \\/     \\/     \\/     \\/     \\/            \\/     \\/ 
    """
    rprint("[bold cyan]" + banner + "[/bold cyan]")



def setup_logging(log_to_file: bool) -> None:
    log_format = '%(asctime)s - %(levelname)s - %(message)s'
    if log_to_file:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_filename = f"autoit_analyzer_{timestamp}.log"
        logging.basicConfig(filename=log_filename, level=logging.INFO, format=log_format)
    else:
        logging.basicConfig(level=logging.INFO, format=log_format)

def parse_arguments() -> Namespace:
    parser = ArgumentParser(description="Analyze AutoIT scripts for potential malicious indicators.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-p", "--path", help="Path to the directory to search.")
    group.add_argument("-f", "--file", help="File path to search within.")
    parser.add_argument("--log-to-file", action="store_true", help="Log output to a file instead of console.")
    return parser.parse_args()

def read_file(filepath: str) -> List[str]:
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            return file.readlines()
    except UnicodeDecodeError:
        logging.warning(f"Unable to read {filepath} with UTF-8 encoding. Trying with ISO-8859-1.")
        with open(filepath, 'r', encoding='iso-8859-1') as file:
            return file.readlines()

def search_strings(filepath: str, content: List[str]) -> Dict[str, List[str]]:
    matches = defaultdict(list)

    # AutoIt v3.26+ strings
    autoit_v326_strings = {
        r"This is a third-party compiled AutoIt script\\.": "AutoIt v3.26+ identifier",
        r"AU3!EA06": "AutoIt v3.26+ identifier",
        r">>>AUTOIT NO CMDEXECUTE<<<": "AutoIt v3.26+ identifier",
        r"AutoIt v3": "AutoIt v3.26+ identifier",
    }

    # AutoIt v3.00 strings
    autoit_v300_strings = {
        r"AU3_GetPluginDetails": "AutoIt v3.00 identifier",
        r"AU3!EA05": "AutoIt v3.00 identifier",
        r"OnAutoItStart": "AutoIt v3.00 identifier",
        r"AutoIt script files \\(\\*\\.au3, \\*\\.a3x\\)": "AutoIt v3.00 identifier",
    }

    # Generic AutoIt strings
    generic_autoit_strings = {
        r"AV researchers please email avsupport@autoitscript\\.com for support\\.": "Generic AutoIt identifier",
        r"#OnAutoItStartRegister": "Generic AutoIt identifier",
        r"#pragma compile": "Generic AutoIt identifier",
        r"/AutoIt3ExecuteLine": "Generic AutoIt identifier",
        r"/AutoIt3ExecuteScript": "Generic AutoIt identifier",
        r"/AutoIt3OutputDebug": "Generic AutoIt identifier",
        r">>>AUTOIT SCRIPT<<<": "Generic AutoIt identifier",
        r"#include <": "Generic AutoIT include",
    }

    # Common AutoIt functions
    common_autoit_functions = {
        r"NoTrayIcon": "Common AutoIt function",
        r"iniread": "Common AutoIt function",
        r"fileinstall": "Common AutoIt function",
        r"EndFunc": "Common AutoIt function",
        r"FileRead": "Common AutoIt function",
        r"DllStructSetData": "Common AutoIt function",
        r"Global Const": "Common AutoIt function",
        r"Run\\\(@AutoItExe": "Common AutoIt function",
        r"StringReplace": "Common AutoIt function",
        r"filewrite": "Common AutoIt function",
    }

    # Combine all patterns
    all_patterns = {**autoit_v326_strings, **autoit_v300_strings, **generic_autoit_strings, **common_autoit_functions}

    # Compile all regex patterns
    compiled_patterns = {}
    for pattern, desc in all_patterns.items():
        try:
            compiled_patterns[re.compile(pattern, re.IGNORECASE)] = desc
        except re.error as e:
            logging.error(f"Error compiling pattern: {pattern}")
            logging.error(f"Error message: {str(e)}")

    # Magic numbers
    magic_v326 = binascii.unhexlify("A3484BBE986C4AA9994C530A86D6487D415533214541303636")
    magic_v300 = binascii.unhexlify("A3484BBE986C4AA9994C530A86D6487D415533214541303535")

    # Read file content as bytes
    try:
        with open(filepath, 'rb') as file:
            file_content = file.read()
    except Exception as e:
        logging.error(f"Error reading file {filepath}: {str(e)}")
        return matches

    # Check for magic numbers
    if magic_v326 in file_content:
        matches[filepath].append("Magic number found: AutoIt v3.26+")
    if magic_v300 in file_content:
        matches[filepath].append("Magic number found: AutoIt v3.00")

    # Search for string patterns
    for line_num, line in enumerate(content, 1):
        for pattern, desc in compiled_patterns.items():
            if pattern.search(line):
                matches[filepath].append(f"Line {line_num}: {line.strip()} // {desc}")

    return matches

def format_output(matches: Dict[str, List[str]], output_format: str) -> None:
    final_output = {}
    for file, match_list in matches.items():
        final_output[file] = match_list

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    if output_format == 'yaml':
        output_file = f"autoit_seeker_results-{timestamp}.yaml"
        with open(output_file, 'w', encoding='utf-8') as yamlfile:
            yaml.dump(final_output, yamlfile, default_flow_style=False)
        print(f"Results saved to {output_file}")

    elif output_format == 'csv':
        output_file = f"autoit_seeker_results-{timestamp}.csv"
        with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['File', 'Matches'])
            for file, matches in final_output.items():
                writer.writerow([file, '\\n'.join(matches)])
        print(f"Results saved to {output_file}")

    elif output_format == 'json':
        output_file = f"autoit_seeker_results-{timestamp}.json"
        with open(output_file, 'w', encoding='utf-8') as jsonfile:
            json.dump(final_output, jsonfile, indent=4)
        print(f"Results saved to {output_file}")

    else:  # Rich colorized output
        console = Console()

        # Section 1: Files with the most hits
        console.print("[bold blue]Files with the most hits:[/bold blue]")
        table = Table(show_header=True, header_style="bold magenta")
        table.add_column("File Name", style="cyan")
        table.add_column("Number of Hits", style="green")

        for file, matches in sorted(final_output.items(), key=lambda x: len(x[1]), reverse=True):
            table.add_row(file, str(len(matches)))

        console.print(table)

        # Section 2: Individual hits
        console.print("\\n[bold blue]Individual hits:[/bold blue]")
        for file, matches in final_output.items():
            console.print(f"[bold cyan]{file}[/bold cyan]")
            for match in matches:
                console.print(f"  [green]{match}[/green]")
            console.print()

    # Always save a YAML version for reference
    reference_file = f"autoit_seeker_results-{timestamp}-reference.yaml"
    with open(reference_file, 'w', encoding='utf-8') as yamlfile:
        yaml.dump(final_output, yamlfile, default_flow_style=False)
    print(f"Reference results saved to {reference_file}")

def analyze_files(path: str) -> Dict[str, List[str]]:
    all_matches = {}
    if os.path.isfile(path):
        content = read_file(path)
        all_matches.update(search_strings(path, content))
    else:
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith('.au3'):
                    filepath = os.path.join(root, file)
                    content = read_file(filepath)
                    all_matches.update(search_strings(filepath, content))
    return all_matches

def main():
    print_banner()  # Add this line at the beginning of the main function

    args = parse_arguments()
    setup_logging(args.log_to_file)

    logging.info("Starting AutoIT script analysis...")
    all_matches = analyze_files(args.path or args.file)

    if not all_matches:
        logging.info("No suspicious patterns found.")
    else:
        logging.info("Analysis complete. Suspicious patterns found.")
        output_format = input("Select output format (YAML, CSV, JSON, or RICH): ").strip().lower()
        format_output(all_matches, output_format)

    logging.info("Analysis finished.")

if __name__ == "__main__":
    main()