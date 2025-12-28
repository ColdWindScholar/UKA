import subprocess
import sys

from .compile import compile as compile_


def parse_args():
    if len(sys.argv) < 2:
        RED = "\033[91m"
        ENDC = "\033[0m"
        print(f"pyc: {RED}fatal error:{ENDC} no input files")
        print("compilation terminated.")
        sys.exit(-1)
    sys.argv.pop(0)
    source_file = sys.argv.pop(0)
    return source_file, sys.argv


def compile():
    """ Command line interface."""
    source_file, _ = parse_args()
    return_code, _ = compile_(source_file)
    sys.exit(return_code)


def compile_and_run():
    source_file, argv = parse_args()
    return_code, executable = compile_(source_file)
    if return_code == 0:
        return_code = subprocess.check_call(["./" + executable] + argv)
    return return_code
