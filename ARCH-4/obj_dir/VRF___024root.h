// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VRF.h for the primary calling header

#ifndef VERILATED_VRF___024ROOT_H_
#define VERILATED_VRF___024ROOT_H_  // guard

#include "verilated.h"


class VRF__Syms;

class alignas(VL_CACHE_LINE_BYTES) VRF___024root final {
  public:

    // INTERNAL VARIABLES
    VRF__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    VRF___024root(VRF__Syms* symsp, const char* namep);
    ~VRF___024root();
    VL_UNCOPYABLE(VRF___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
