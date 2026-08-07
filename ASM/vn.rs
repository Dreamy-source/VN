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
        .expect(&format!(" in machine: unknown register: '{}'", reg));

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
        _ => panic!(" in machine: unknown opcode: '{}'", op),
    }
}

pub fn value_to_hex(val: &str) -> u64 {
    let val_parsed: u64 = u64::from_str_radix(val, 16)
        .expect(&format!(" in machine: unknown value: '{}'", val));

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
                let op  = opcode_to_hex(parts[0]);
                let dst = register_to_hex(parts[1]);
                let val = value_to_hex(parts[3]);

                let instruction: u64 =
                    (op  as u64) << 48 |
                    (dst as u64) << 32 |
                    (val as u64);
                
                instructions.push(instruction);
                println!(" [ok] in machine: decoded: 0x{:064X}", instruction);
            }
            "add" | "sub" | "mul" | "div" | "and" | "or" | "xor" | "lshft" | "rshft" | "asr" => {
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
                println!(" [ok] in machine: decoded: 0x{:064X}", instruction);
            }
            "nothing" => {
                let op = opcode_to_hex(parts[0]);

                let instruction: u64 = op as u64;
                instructions.push(instruction);
                println!(" [ok] in machine: decoded: 0x{:064X}", instruction);
            }
            _ => {}
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