import sys
from cx_Freeze import setup, Executable

# Dependencies are automatically detected, but it might need fine tuning.
build_exe_options = {"packages": ["os"], "excludes": ["tkinter"]}

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None

setup(  name = "S4A-Embedded",
        version = "1",
        description = "Super easy to use Scratch extension for uploading Scratch code to Arduino that doesn't require Scratch to run.",
        options = {"build_exe": build_exe_options},
        executables = [Executable("CommandLineConverter.py", base=base)])