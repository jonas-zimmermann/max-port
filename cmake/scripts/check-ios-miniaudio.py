"""Check the actual Xcode compiler invocation, including when the build fails."""
import pathlib
import shlex
import sys


def escape(message):
    return message.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")


def check(log):
    commands = []
    for line in log.splitlines():
        try:
            args = shlex.split(line)
        except ValueError:
            continue
        if not args or pathlib.Path(args[0]).name not in ("clang", "clang++"):
            continue
        if "-c" not in args or not any(arg.endswith("/miniaudio.c") for arg in args):
            continue
        modes = [args[i + 1] for i, arg in enumerate(args[:-1]) if arg == "-x"]
        commands.append((line, modes))
    if not commands:
        raise ValueError("No actual clang invocation compiling miniaudio.c was found")
    for line, modes in commands:
        print(line)
        if not modes or modes[-1] != "objective-c":
            raise ValueError(f"miniaudio.c compiler modes were {modes}, expected final -x objective-c")
    print("::notice title=miniaudio language verified::Actual clang invocation for miniaudio.c uses -x objective-c")


if __name__ == "__main__":
    log = pathlib.Path(sys.argv[1]).read_text(errors="replace")
    # Expose compiler diagnostics through the Checks API when log ZIP downloads
    # are blocked. Keep the original build exit status in the workflow.
    diagnostics = [line for line in log.splitlines()
                   if " error:" in line or "fatal error:" in line or "Undefined symbols" in line]
    for line in diagnostics[:30]:
        print(f"::error title=iOS compiler::{escape(line)}")
    try:
        check(log)
    except ValueError as error:
        print(f"::error title=miniaudio language verification::{escape(str(error))}")
        sys.exit(1)
