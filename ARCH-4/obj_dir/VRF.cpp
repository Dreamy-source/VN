// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VRF__pch.h"

//============================================================
// Constructors

VRF::VRF(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VRF__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

VRF::VRF(const char* _vcname__)
    : VRF(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VRF::~VRF() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VRF___024root___eval_debug_assertions(VRF___024root* vlSelf);
#endif  // VL_DEBUG
void VRF___024root___eval_static(VRF___024root* vlSelf);
void VRF___024root___eval_initial(VRF___024root* vlSelf);
void VRF___024root___eval_settle(VRF___024root* vlSelf);
void VRF___024root___eval(VRF___024root* vlSelf);

void VRF::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VRF::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VRF___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VRF___024root___eval_static(&(vlSymsp->TOP));
        VRF___024root___eval_initial(&(vlSymsp->TOP));
        VRF___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VRF___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VRF::eventsPending() { return false; }

uint64_t VRF::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VRF::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VRF___024root___eval_final(VRF___024root* vlSelf);

VL_ATTR_COLD void VRF::final() {
    contextp()->executingFinal(true);
    VRF___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VRF::hierName() const { return vlSymsp->name(); }
const char* VRF::modelName() const { return "VRF"; }
unsigned VRF::threads() const { return 1; }
void VRF::prepareClone() const { contextp()->prepareClone(); }
void VRF::atClone() const {
    contextp()->threadPoolpOnClone();
}
