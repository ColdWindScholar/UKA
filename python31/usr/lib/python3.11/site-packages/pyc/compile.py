import os
import sysconfig
import subprocess
from typing import Tuple

from Cython.Build import cythonize
from Cython.Compiler import Options


def compile(source_file: str, verbose: bool = False) -> Tuple[int, str]:
    """Compile Python source file to executable using Cython."""

    basename = os.path.splitext(source_file)[0]
    c_file = basename + ".c"
    executable = "a.out"

    # Generate c file
    Options.embed = "main"
    compiler_directives = {"language_level": "3"}  # or "2" or "3str"
    cythonize(source_file, compiler_directives=compiler_directives,
              force=True, quiet=not verbose)

    # Compile c file to executable
    cvars = sysconfig.get_config_vars()
    CC = cvars["CC"]  # x86_64-linux-gnu-gcc
    INCLUDEPY = cvars["INCLUDEPY"]  # /usr/include/python3.8
    BLDLIBRARY = cvars["BLDLIBRARY"]  # -lpython3.8
    BINLIBDEST = cvars["BINLIBDEST"]  # /usr/lib/python3.8
    cmd = f"{CC} -O2 {c_file} -I{INCLUDEPY} -L{BINLIBDEST} {BLDLIBRARY} -o {executable}"
    if verbose:
        print(cmd)
    return_code = subprocess.check_call(cmd.split(" "))

    if return_code != 0:
        print("Compilation failed.")

    return return_code, executable
