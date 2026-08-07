#![allow(unused_variables, dead_code, unused_imports)]

pub fn instructions_to_bin(instructions: &[u64]) -> Vec<u8> {
    let mut bytes = Vec::new();
    for inst in instructions {
        bytes.extend_from_slice(&inst.to_le_bytes());
    }
    bytes
}

pub fn instructions_to_txt(instructions: &[u64]) -> String {
    let mut dump = String::new();
    for inst in instructions {
        dump.push_str(&format!("0x{:016X}\n", inst));
    }
    dump
}