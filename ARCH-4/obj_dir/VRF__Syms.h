// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VRF__SYMS_H_
#define VERILATED_VRF__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "VRF.h"

// INCLUDE MODULE CLASSES
#include "VRF___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) VRF__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    VRF* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    VRF___024root                  TOP;

    // CONSTRUCTORS
    VRF__Syms(VerilatedContext* contextp, const char* namep, VRF* modelp);
    ~VRF__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
