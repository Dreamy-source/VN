// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb.h for the primary calling header

#ifndef VERILATED_VTB_RF_IF_H_
#define VERILATED_VTB_RF_IF_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_RF_if final {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ clk;

    // INTERNAL VARIABLES
    Vtb__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vtb_RF_if();
    ~Vtb_RF_if();
    void ctor(Vtb__Syms* symsp, const char* namep);
    void dtor();
    VL_UNCOPYABLE(Vtb_RF_if);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
