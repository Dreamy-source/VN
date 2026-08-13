#![allow(warnings)]

use std::env;

#[path = "libs/fs/fs.rs"]
mod fs;

#[path = "libs/pl/pl.rs"]
mod pl;
use pl::instructions_to_bin;
use pl::instructions_to_txt;

pub fn opcode_to_hex(op: &str) -> u32 {
    match (op) {
        "add"   => 0x001,
        "sub"   => 0x002,
        "mul"   => 0x003,
        "div"   => 0x004,
        "and"   => 0x005,
        "or"    => 0x006,
        "xor"   => 0x007,
        "not"   => 0x008,
        "lshft" => 0x009,
        "rshft" => 0x00A,
        "asr"   => 0x00B,
        "load"  => 0x00C,
        _ => {
            eprintln!("error: unknown opcode: {}", op);
            std::process::exit(1);
        }
    }
}

pub fn register_to_hex(reg: &str) -> u8 {
    let reg_parsed: u8 = reg.trim_start_matches("rx").parse()
        .expect(&format!("error: invalid register: '{}'", reg));

    reg_parsed
}

pub fn value_to_hex(val: &str) -> u64 {
    val.parse().unwrap_or(0)
}

fn main() {
    let argv: Vec<String> = env::args().collect();
    if argv.len() < 2 {
        eprintln!("error: expected <file.asm>, got: {:?}", argv.get(1));
        return;
    }
    let content = fs::read_file(&argv[1]);
    let mut instructions: Vec<u64> = Vec::new();

    let output = if argv.len() >= 4 && argv[2] == "-o" {
        argv[3].clone()
    } else {
        eprintln!("error: output file not assigned");
        return;
    };

    for line in content.lines() {
        let line = line.trim();
        let parts: Vec<&str> = line.split_whitespace().collect();

        if line.is_empty() || line.starts_with(";") {
            continue;
        }
        let opcode = parts[0];

        match (opcode) {
            "add" | "sub" | "mul" | "div" | "and" | "or" | "xor" | "lshft" | "rshft" | "asr" => {
                if parts.len() < 6 {
                    eprintln!("error: expected format: {} <dst> = <src0> <sep> <src1>", opcode);
                    continue;
                }
                
                let op       = opcode_to_hex(opcode);
                let dst      = register_to_hex(parts[1]);
                let reg_src0 = register_to_hex(parts[3]);
                let reg_src1 = register_to_hex(parts[5]);

                let instruction: u64 =
                    (op as u64)       << 55 |
                    (dst as u64)      << 50 |
                    (reg_src0 as u64) << 45 |
                    (reg_src1 as u64) << 40;
                    
                instructions.push(instruction);
                println!("decoded: 0x{:016X}", instruction);
            }
            "load" => {
                let op       = opcode_to_hex(opcode);
                let dst      = register_to_hex(parts[1]);
                let imm      = value_to_hex(parts[3]);

                let instruction: u64 =
                    (op  as u64) << 55 |
                    (dst as u64) << 50 |
                    imm;
                
                instructions.push(instruction);
                println!("decoded: 0x{:016X}", instruction);
            }
            _ => eprintln!("[?] warning: unknown instruction: {}", opcode),
        }
    }
    for (i, instruction) in instructions.iter().enumerate() {
        println!("[{}] 0x{:016X}", i, instruction);
    }
    let bin = instructions_to_bin(&instructions);
    if bin.len() == 0 { return; } else { println!("--- hexdump ({} bytes) ---", bin.len()); };
    for byte in &bin {
        print!("{:02X} ", byte);
    }
    println!();
    fs::write_file_no_append(&output, &instructions_to_txt(&instructions));
}