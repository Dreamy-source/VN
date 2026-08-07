#![allow(unused_variables, dead_code, unused_imports)]

use std::env;

#[path = "libs/fs/fs.rs"]
mod fs;

pub fn register_to_bits(reg: &str) -> u8 {
    let reg_parsed: u8 = reg.trim_start_matches("rx").parse()
        .expect(&format!("unknown register: {}", reg));

    reg_parsed
}

pub fn value_to_bits(val: &str) -> u8 {
    val.parse()
        .expect(&format!("unknown value: {}", val))
}

pub fn opcode_to_bits(opcode: &str) -> u8 {
    match opcode {
        "nothing" => 0b0000000000000000,
        "add"     => 0b0000000000000001,
        "sub"     => 0b0000000000000010,
        "mul"     => 0b0000000000000011,
        "div"     => 0b0000000000000100,
        "and"     => 0b0000000000000101,
        "or"      => 0b0000000000000110,
        "xor"     => 0b0000000000000111,
        "not"     => 0b0000000000001000,
        "lshft"   => 0b0000000000001001,
        "rshft"   => 0b0000000000001010,
        "asr"     => 0b0000000000001011,
        "reg"     => 0b0000000000001100,
        _ => panic!("unknown opcode: {}", opcode),
    }
}

pub fn symbol_to_bits(sym: &str) -> u8 {
    match sym {
        "+" => 0b0000000000000001,
        "-" => 0b0000000000000010,
        "*" => 0b0000000000000011,
        "/" => 0b0000000000000100,
        "&" => 0b0000000000000101,
        "|" => 0b0000000000000110,
        "^" => 0b0000000000000111,
        _ => panic!("unknown symbol: {}", sym),
    }
}

pub fn char_to_bits(bit: &str) -> u8 {
    match bit {
        "S" => 0b0000000000000001,
        "R" => 0b0000000000000010,
        _ => panic!("unknown char: {}", bit),
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("help <-> use: {} file.asm / file.vn", args[0]);
        return;
    }
    let input_content = fs::read_file(&args[1]);
    let output_content = if args.len() > 3 && args[2] == "-o" {
        println!("found flag '-o', next argument is child of flag");
        let output_filename = args[3].clone();
        println!("child (output file): {}", output_filename);
        output_filename
    } else {
        println!("child in flag '-o' not found, using default output file...");
        String::from("output.bin")
    };

    let mut enumerate_bits = 32;
    let mut container: Vec<u64> = Vec::new();

    println!("machine: enter");

    for line in input_content.lines() {
        if line.trim_start().starts_with(';') {
            continue;
        }

        let parts: Vec<&str> = line.split_whitespace().collect();
        
        if parts.is_empty() {
            continue;
        }

        let opcode = parts[0];

        match opcode {
            "asm!" => {
                if parts.len() >= 3 && parts[1] == "enumerate" {
                    enumerate_bits = parts[2].parse::<usize>().unwrap_or(32);
                    println!("\n in machine: asm is ready in code section 'asm!'");
                    println!(" in machine: asm got command to enumerate lines. bits: {}", enumerate_bits);
                } else {
                    eprintln!("error: command 'asm!' expected 3 tokens, got: {}", parts.len());
                }
            }
            "reg" => {
                if parts.len() >= 4 {
                    let op   = opcode_to_bits(opcode);
                    let dest = register_to_bits(parts[1]);
                    let val  = value_to_bits(parts[3]);

                    let instruction: u64 = 
                        (op as u64)   << 48 |
                        (dest as u64) << 41 |
                        (val as u64);
                    
                    println!("\n in machine: asm is ready in code section 'reg'");
                    println!(" in machine: asm data retrieved:");
                    println!("-----------------------------------------------------");
                    println!(" {:08b} {:08b}={:08b} (max=08b | op, reg, val)", op, dest, val);
                    println!("-----------------------------------------------------");
                    container.push(instruction);
                } else {
                    eprintln!("error: instruction 'reg' expected 4 tokens, got: {}", parts.len());
                }
            }
            "nothing" => {
                if parts.len() >= 1 {
                    println!("\n in machine: asm is ready in code section 'nothing'");
                    println!(" in machine: skipping instruction. reason: (instruction: nothing)");
                }
            }
            "add" | "sub" | "mul" | "div" | "and" | "or" | "xor" | "lshft" | "rshft" | "asr" => {
                let op  = opcode_to_bits(opcode);
                let dst = register_to_bits(parts[1]);
                let rx0 = register_to_bits(parts[3]);
                let rx1 = register_to_bits(parts[5]);

                let instruction: u64 =
                    (op as u64)  << 48 |
                    (dst as u64) << 41 |
                    (rx0 as u64) << 34 |
                    (rx1 as u64) << 27;

                println!("\n in machine: asm is ready in code section 'arithmetic & bit operations'");
                println!(" in machine: asm data retrieved:");
                println!("-----------------------------------------------------");
                println!(" {:08b} {:08b} {:08b} {:08b} (max=08b | op, dst, rx0, rx1)", op, dst, rx0, rx1);
                println!("-----------------------------------------------------");
                container.push(instruction);
            }
            _ => {}
        }
    }

    println!("\ninstructions:");
    for (i, inst) in container.iter().enumerate() {
        println!("{:03}: {:064b}", i, inst);
    }
    println!("\nfile:");
    let mut addr = 0u64;

    for line in input_content.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with(';') {
            continue;
        }
        println!("0x{:0width$x}: {}", addr, trimmed, width = enumerate_bits / 4);
        addr += 1;
    }
    let mut bytes = Vec::new();
    for inst in &container {
        bytes.extend_from_slice(&inst.to_le_bytes());
    }
    std::fs::write(&output_content, &bytes).expect("failed to write file");
    println!("\ndata written in: {}", &output_content);
    println!("\nmachine: exit");
}