// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb.h for the primary calling header

#include "Vtb__pch.h"

void Vtb_RF_if___ctor_var_reset(Vtb_RF_if* vlSelf);

Vtb_RF_if::Vtb_RF_if() = default;
Vtb_RF_if::~Vtb_RF_if() = default;

void Vtb_RF_if::ctor(Vtb__Syms* symsp, const char* namep) {
    vlSymsp = symsp;
    vlNamep = strdup(Verilated::catName(vlSymsp->name(), namep));
    // Reset structure values
    Vtb_RF_if___ctor_var_reset(this);
}

void Vtb_RF_if::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

void Vtb_RF_if::dtor() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
