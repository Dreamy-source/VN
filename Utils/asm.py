#!/usr/bin/env python3
import sys
from pathlib import Path

OPS_NASM = {
    "add": 0x000, "sub": 0x001, "mul": 0x002, "div": 0x003,
    "and": 0x004, "or":  0x005, "xor": 0x006, "not": 0x007,
    "shl": 0x008, "shr": 0x009, "mov": 0x00A, "nop": 0x00B,
    "hlt": 0x00C, "snd": 0x00D
}

OPS_VN = {
    "add": 0x000, "sub": 0x001, "mul": 0x002, "div": 0x003,
    "and": 0x004, "or":  0x005, "xor": 0x006, "not": 0x007,
    "lsh": 0x008, "rsh": 0x009, "mv":  0x00A, "noth": 0x00B,
    "prcstop": 0x00C, "snd": 0x00D
}

def parse_imm(s):
    s = s.strip()

    if len(s) >= 3 and s[0] == "'" and s[-1] == "'":
        return ord(s[1])

    if len(s) >= 4 and s[0] == "'" and s[1] == "\\" and s[-1] == "'":
        escapes = {'n': 10, 't': 9, 'r': 13, '0': 0, '\\': 92, "'": 39}
        return escapes.get(s[2], 0)

    return int(s, 0)

def assemble_nasm(content):
    output = []
    warns = 0
    errors = 0

    for line_i, line in enumerate(content.splitlines(), 1):
        line = line.split(";")[0].strip()
        if not line: continue

        tokens = line.replace(",", " ").split()
        operation = tokens[0]

        if operation not in OPS_NASM:
            print(f"warning: line {line_i}: unknown operation: {operation}")
            warns += 1
            continue

        op = OPS_NASM[operation]

        try:
            match operation:
                case "mov":
                    dst = int(tokens[1][1:])
                    imm = parse_imm(tokens[2])
                    instruction = (op << 53) | (dst << 38) | (imm & ((1 << 38) - 1))

                case "not":
                    src0 = int(tokens[1][1:])
                    dst  = int(tokens[2][1:])
                    instruction = (op << 53) | (src0 << 48) | (dst << 38)

                case "nop" | "hlt":
                    instruction = (op << 53)

                case "snd":
                    imm = parse_imm(tokens[1])
                    instruction = (op << 53) | (imm & ((1 << 38) - 1))

                case _:
                    src0 = int(tokens[1][1:])
                    src1 = int(tokens[2][1:])
                    dst  = int(tokens[3][1:])
                    instruction = (op << 53) | (src0 << 48) | (src1 << 43) | (dst << 38)

        except (IndexError, ValueError) as e:
            print(f"error: line {line_i}: {e}")
            print(f"  | {line}")
            errors += 1
            continue

        output.append(instruction)

    return output, warns, errors

def assemble_vn(content):
    output = []
    warns = 0
    errors = 0

    for line_i, line in enumerate(content.splitlines(), 1):
        line = line.split(";")[0].strip()
        if not line: continue

        tokens = line.replace(",", " ").split()
        operation = tokens[0]

        if operation not in OPS_VN:
            print(f"warning: line {line_i}: unknown operation: {operation}")
            warns += 1
            continue

        op = OPS_VN[operation]

        try:
            match operation:
                case "mv":
                    dst = int(tokens[1][1:])
                    imm = parse_imm(tokens[2])
                    instruction = (op << 53) | (dst << 38) | (imm & ((1 << 38) - 1))

                case "not":
                    src0 = int(tokens[1][1:])
                    dst  = int(tokens[2][1:])
                    instruction = (op << 53) | (src0 << 48) | (dst << 38)

                case "noth" | "prcstop":
                    instruction = (op << 53)

                case "snd":
                    imm = parse_imm(tokens[1])
                    instruction = (op << 53) | (imm & ((1 << 38) - 1))

                case _:
                    src0 = int(tokens[1][1:])
                    src1 = int(tokens[2][1:])
                    dst  = int(tokens[3][1:])
                    instruction = (op << 53) | (src0 << 48) | (src1 << 43) | (dst << 38)

        except (IndexError, ValueError) as e:
            print(f"error: line {line_i}: {e}")
            print(f"  | {line}")
            errors += 1
            continue

        output.append(instruction)

    return output, warns, errors

def usage():
    print("usage: vnasm <input.asm> [-o <output.frm>] [--provide-syntax=<nasm|vn>]")
    print("")
    print("syntaxes:")
    print("  nasm-vn  — mov, nop, hlt, shl, shr, ...")
    print("  vn    — mv, noth, prcstop, lsh, rsh, ...")


def main():
    # Help
    if len(sys.argv) >= 2 and sys.argv[1] in ("-h", "--help"):
        usage()
        return 0

    if len(sys.argv) < 2:
        usage()
        return 1

    input_file  = sys.argv[1]
    output_file = "auto.bin"
    syntax      = "vn"

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]

        if arg == "-o":
            if i + 1 >= len(sys.argv):
                print("error: -o requires a filename", file=sys.stderr)
                return 1
            output_file = sys.argv[i + 1]
            i += 2

        elif arg.startswith("--provide-syntax="):
            syntax = arg.split("=", 1)[1]
            if syntax not in ("nasm-vn", "vn"):
                print(f"error: unknown syntax: {syntax}", file=sys.stderr)
                return 1
            i += 1

        else:
            print(f"error: unknown argument: {arg}", file=sys.stderr)
            usage()
            return 1

    input_path = Path(input_file)
    if not input_path.exists():
        print(f"error: file not found: {input_path}", file=sys.stderr)
        return 1

    content = input_path.read_text()

    if syntax == "nasm-vn":
        output, warns, errors = assemble_nasm(content)
    else:
        output, warns, errors = assemble_vn(content)

    if errors > 0:
        print(f"failed: {errors} errors", file=sys.stderr)
        return 1

    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w") as f:
        for word in output:
            f.write(f"{word:016X}\n")

    print(f"{len(output)} instructions | {warns} warns, {errors} errors")
    return 0


if __name__ == "__main__":
    sys.exit(main())