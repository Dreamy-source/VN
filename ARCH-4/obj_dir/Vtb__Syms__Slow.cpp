// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb__pch.h"

Vtb__Syms::Vtb__Syms(VerilatedContext* contextp, const char* namep, Vtb* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(194);
    // Setup sub module instances
    TOP__tb__DOT__bus.ctor(this, "tb.bus");
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT__tb__DOT__bus = &TOP__tb__DOT__bus;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    TOP__tb__DOT__bus.__Vconfigure(true);
    // Setup scopes
}

Vtb__Syms::~Vtb__Syms() {
    // Tear down scopes
    // Tear down sub module instances
    TOP__tb__DOT__bus.dtor();
}
