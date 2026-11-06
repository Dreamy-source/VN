// -- FILE: main.td (VN64 LLVM backend descriptor)
// Copyright (c) 2026 Dreamy-source
// 
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2.
// 
// You may redistribute and modify this source and make products using it under
// the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).
// 
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
// PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
// 
// Source location: https://github.com/Dreamy-source/VN


// --@ BASE DEFINE SECTION
defvar ARCH = "VN64";

// --@ INCLUDE SECTION
include "llvm/Target/Target.td"

// --@ TARGET SECTION
def VN64 : Target {}

// --@ REGISTER SECTION
class VN64DescribeRegister<bits<5> addr, string name> : Register<name>
{
    let Namespace = ARCH;
    let HWEncoding{4-0} = addr;
}

defvar REGISTER_MIN = 0;
defvar REGISTER_MAX = 31;
foreach i = REGISTER_MIN-REGISTER_MAX in {
    // X - code identifier
    // x - description identifier
    def "X"#i : VN64DescribeRegister<i, "x"#i>;
}

defvar REGISTER_BITS = 64;
def VN64GPR : RegisterClass<ARCH, [i64], REGISTER_BITS, (add (sequence "X%u", REGISTER_MIN, REGISTER_MAX))>;
