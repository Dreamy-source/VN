#![allow(unused_variables, dead_code, unused_imports)]

use std::env;

#[path = "libs/fs/fs.rs"]
mod fs;

#[path = "libs/pl/pl.rs"]
mod pl;
use pl::instructions_to_bin;
use pl::instructions_to_txt;

pub fn register_to_hex(reg: &str) -> u8 {
    let reg_parsed: u8 = reg.trim_start_matches("rx").parse()
        .expect(&format!("    [?] machine: unknown register: '{}'", reg));

    reg_parsed
}

pub fn opcode_to_hex(op: &str) -> u16 {
    match op {
        "nothing" => 0x0000,
        "add"     => 0x0001,
        "sub"     => 0x0002,
        "mul"     => 0x0003,
        "div"     => 0x0004,
        "and"     => 0x0005,
        "or"      => 0x0006,
        "xor"     => 0x0007,
        "not"     => 0x0008,
        "lshft"   => 0x0009,
        "rshft"   => 0x000A,
        "asr"     => 0x000B,
        "reg"     => 0x000C,
        "dclr"    => 0x000D,
        "dcls"    => 0x000E,
        _ => panic!("    [?] machine: unknown opcode: '{}'", op),
    }
}

pub fn value_to_hex(val: &str) -> u64 {
    let (radix, val) = if val.starts_with("0x") {
        (16, &val[2..])
    } else if val.starts_with("0b") {
        (2, &val[2..])
    } else if val.ends_with('b') {
        (2, &val[..val.len()-1])
    } else {
        (10, val)
    };

    let val_parsed: u64 = u64::from_str_radix(val, radix)
        .expect(&format!("    [?] machine: unknown value: '{}'", val));

    val_parsed
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("usage: <file.vn>");
        return;
    }

    let content = fs::read_file(&args[1]);
    let output_content = if args.len() >= 3 && args[2] == "-o" {
        println!("[ok] output file found");
        &args[3]
    } else {
        println!("[no] output file not found, using default.");
        "output.bin"
    };

    let accessing_level = args.iter()
    .find(|a| a.starts_with("-accessing="))
    .map(|a| {
        if a == "-accessing=MACHINE" {
            println!("machine: LEVEL=MACHINE");
            "MACHINE"
        } else if a == "-accessing=KERNEL" {
            println!("machine: LEVEL=KERNEL");
            "KERNEL"
        } else {
            "USER"
        }
    })
    .unwrap_or("USER");

    let mut instructions: Vec<u64> = Vec::new();
    println!("\nmachine: enter");
    println!("");

    for line in content.lines() {
        let line = line.trim();
        let parts: Vec<&str> = line.split_whitespace().collect();

        if line.is_empty() || line.starts_with(';') {
            continue;
        }

        let opcode = parts[0];

        match opcode {
            "reg" => {
                println!("\n [prc] decoding: '{}'", opcode);
                let op  = opcode_to_hex(parts[0]);
                let dst = register_to_hex(parts[1]);
                let val = value_to_hex(parts[3]);

                let instruction: u64 =
                    (op  as u64) << 48 |
                    (dst as u64) << 32 |
                    (val as u64);
                

                instructions.push(instruction);
                println!("   [ok] machine: decoded: 0x{:064X}", instruction);
            }
            "add" | "sub" | "mul" | "div" | "and" | "or" | "xor" | "lshft" | "rshft" | "asr" => {
                println!("\n [prc] decoding: '{}'", opcode);
                let op   = opcode_to_hex(parts[0]);
                let dst  = register_to_hex(parts[1]);
                let reg0 = register_to_hex(parts[3]);
                let reg1 = register_to_hex(parts[5]);

                let instruction: u64 =
                    (op   as u64) << 48 |
                    (dst  as u64) << 43 |
                    (reg0 as u64) << 38 |
                    (reg1 as u64) << 33;
                
                instructions.push(instruction);
                println!("   [ok] machine: decoded: 0x{:064X}", instruction);
            }
            "nothing" => {
                let op = opcode_to_hex(parts[0]);

                let instruction: u64 = op as u64;
                instructions.push(instruction);
                println!("   [ok] machine: decoded: 0x{:064X}", instruction);
            }
            "dclr" => {
                if accessing_level == "MACHINE" {
                    println!("\n====== DCL Appeal Start ======");
                    println!("   [*] machine: appealing to DCL (LEVEL={})", accessing_level);
                    println!("   [*] machine: appeal: DCL (Device Control Lines)");
                    println!("   [*] machine: appeal: reset DCL lines");
                    println!("   [*] machine: waiting for answer...");
                    let op = opcode_to_hex(parts[0]);

                    let instruction: u64 = op as u64;

                    instructions.push(instruction);
                    println!("      [ok] machine: appeal: accepted");
                    println!("      [ok] machine: decoded: {:04X} (dclr)  (0x{:064X})", op, instruction);
                    println!("\n");
                } else {
                    eprintln!(" [*] machine: cannot to decode 'dclr', LEVEL={}", accessing_level);
                }
            }
            "dcls" => {
                if accessing_level == "MACHINE" {
                    println!("\n====== DCL Appeal Start ======");
                    println!("   [*] machine: appealing to DCL (LEVEL={})", accessing_level);
                    println!("   [*] machine: appeal: DCL (Device Control Lines)");
                    println!("   [*] machine: appeal: set bit in DCL lines");
                    println!("   [*] machine: waiting for answer...");
                    let op = opcode_to_hex(parts[0]);
                    let line = value_to_hex(parts[1]);
                    let bit = value_to_hex(parts[3]);

                    let instruction: u64 =
                        (op as u64)   << 48 |
                        (line as u64) << 40 |
                        (bit as u64)  << 39;

                    instructions.push(instruction);
                    println!("      [ok] machine: appeal: accepted");
                    println!("      [ok] machine: decoded: {:04X} (dcls) | line={} | bit={}  (0x{:064X})", op, line, bit, instruction);
                    println!("\n");
                } else {
                    eprintln!(" [*] machine: cannot to decode 'dcls', LEVEL={}", accessing_level);
                }
            }
            _ => {
                if opcode == "meow" {
                    println!("    [] meow :3");
                } else {
                    println!("    [?] machine: cannot decode: '{}', skipping.", opcode);
                }
            }
        }
    }

    fs::write_bytes(output_content, &instructions_to_bin(&instructions));
    //fs::write_file("files/debug.txt", &instructions_to_txt(&instructions));

    println!("");
    for (index, line) in content.lines().enumerate() {
        println!(" {:08X}: {}", index, line);
    }
    println!("\nmachine: exit");
}