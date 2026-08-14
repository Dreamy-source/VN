// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VRF.h for the primary calling header

#include "VRF__pch.h"


VRF___024root::VRF___024root(VRF__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
}

void VRF___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

VRF___024root::~VRF___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
