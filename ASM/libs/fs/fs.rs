#![allow(unused_variables, dead_code, unused_imports)]

use std::fs;
use std::fs::OpenOptions;
use std::io::Write;

pub fn read_file(file: &str) -> String {
    fs::read_to_string(file).expect(&format!("cannot open file: {}", file))
}

pub fn create_file(file: &str) {
    fs::File::create(file).expect(&format!("cannot create file: {}", file));
}

pub fn write_file(file: &str, content: &str) {
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(file)
        .expect(&format!("cannot open file: {}", file));
    
    writeln!(file, "{}", content).expect("cannot write to file")
}

pub fn write_bytes(file: &str, data: &[u8]) {
    std::fs::write(file, data).expect("machine: fatal=write error");
}