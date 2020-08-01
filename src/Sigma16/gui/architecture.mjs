// Sigma16: architecture.mjs
// Copyright (C) 2020 John T. O'Donnell
// email: john.t.odonnell9@gmail.com
// License: GNU GPL Version 3 or later. See Sigma16/README.md, LICENSE.txt

// This file is part of Sigma16.  Sigma16 is free software: you can
// redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, either
// version 3 of the License, or (at your option) any later version.
// Sigma16 is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.  You should have received
// a copy of the GNU General Public License along with Sigma16.  If
// not, see <https://www.gnu.org/licenses/>.

//-----------------------------------------------------------------------------
// architecture.mjs defines tables specifying opcodes, mnemonics, flag
// bits, and other aspects of the architecture.
//-----------------------------------------------------------------------------

import * as com from './common.mjs';
import * as smod from './s16module.mjs';

// Global variables

export let ctlReg = new Map();
export let statementSpec = new Map();
let emptyStmt = statementSpec.get("");

//-----------------------------------------------------------------------------
// Instruction table
//-----------------------------------------------------------------------------

export const mnemonicRRR =
  ["add",     "sub",     "mul",     "div",
   "addc",     "nop",    "nop",     "nop",
   "nop",     "nop",    "nop",     "nop",
   "nop",     "trap",    "EXP",     "RX"];

export const mnemonicRX =
  ["lea",     "load",    "store",   "jump",
   "jal",     "jumpc0",  "jumpc1",  "jumpz",
   "jumpnz",  "testset", "nop",     "nop",
   "nop",     "nop",     "nop",     "nop"];

const mnemonicEXP =
      ["rfi",      "getctl",   "putctl",  "shiftl",
       "shiftr",   "logicb",   "logicw",  "extract",
       "extracti", "inject",   "injecti", "push",
       "pop",      "top",      "save",     "restore",
       "execute",  "dispatch", "nop",      "nop"];


//-----------------------------------------------------------------------------
// Instruction set and assembly language formats
//-----------------------------------------------------------------------------

// Assembly language statement formats (machine language format).  The
// statement formats have names that begin with "a" (e.g. aRRR) while
// the architecture formats don't (e.g. RRR).

export const aRRR         =  0;    // R1,R2,R3    (RRR)
export const aRR          =  1;    // R1,R2       (RRR, omitting d or b field
export const aRX          =  2;    // R1,xyz[R2]  (RX)
export const aKX          =  3;    // R1,xyz[R2]  (RX)
export const aJX          =  4;    // loop[R0]    (RX omitting d field)
export const EXP0        =  5;    // EXP format with no operand
export const aRREXP       =  6;    // R1,R2       (EXP)
export const aRRREXP      =  7;    // R1,R2,R3    (EXP) like RRR instruction
export const aRRKEXP      =  8;    // R1,R2,3    (EXP)
export const aRKKEXP      =  9;    // R1,3,5     (EXP)
export const aRRRKEXP     = 10;    // R1,R2,R3,k    (EXP) logicw
export const aRRKKEXP     = 11;    // R1,R2,3    (EXP)
export const aRRRKKEXP    = 12;    // R1,R2,R3,g,h    (EXP) logicb
export const aRRXEXP      = 13;    // save R4,R7,3[R14]   (EXP)
export const aRCEXP       = 14;    // getctl R4,mask register,control (EXP)
export const DATA        = 15;    // -42
export const COMMENT     = 16;    // ; full line comment, or blank line
export const afmtIdId    = 17;    // modname,locname for export statement

export const DirModule   = 17;    // module directive
export const DirImport   = 18;    // import directive
export const DirExport   = 19;    // export directive
export const DirOrg      = 20;    // org directive
export const DirEqu      = 21;    // equ directive
export const UNKNOWN     = 22;    // statement format is unknown
export const EMPTY       = 23;    // empty statement

export const NOOPERATION = 24;    // error
export const NOOPERAND   = 25;    // statement has no operand

// Need to update ???
export function showFormat (n) {
    let f = ['RRR','RR','RX', 'KX', 'JX','EXP0', 'RREXP', 'RRREXP', 'RRKEXP',
             'RKKEXP', 'RRRKEXP',  'RRKKEXP', 'RRRKKEXP', 'RRXEXP',
             'RCEXP', 'DATA','COMMENT',
             'DirModule', 'DirImport', 'DirExport', 'DirOrg', 'DirEqu',
             'UNKNOWN', 'EMPTY'] [n];
    let r = (f) ? f : 'UNKNOWN';
    return r;
}

// Give the size of generated code for an instruction format
export function formatSize (fmt) {
    if (fmt==aRRR || fmt==aRR || fmt==EXP0 || fmt==DATA) {
        return 1;
    } else if (fmt==aRX || fmt==aKX || fmt==aJX
               || fmt==aRREXP ||  fmt==aRCEXP || fmt==aRRREXP || fmt==aRRKEXP
               || fmt==aRRRKEXP || fmt==aRRRKKEXP || fmt==aRKKEXP
               || fmt==aRRKKEXP || fmt==aRRXEXP) {
        return 2;
    } else if (fmt==NOOPERAND) {
        return 1;
    } else {
        return 0;
    }
}

//------------------------------------------------------------------------------
// Condition codes
//------------------------------------------------------------------------------

// Bits are numbered from right to left, starting with 0.  Thus the
// least significant bit has index 0, and the most significant bit has
// index 15.

// Define a word for each condition that is representable in the
// condition code.  The arithmetic operations may or several of these
// together to produce the final condition code.

// These definitions give the bit index
export const bit_ccG = 0;   //    G   >          binary
export const bit_ccg = 1;   //    >   >          two's complement
export const bit_ccE = 2;   //    =   =          all types
export const bit_ccl = 3;   //    <   <          two's complement
export const bit_ccL = 4;   //    L   <          binary
export const bit_ccV = 5;   //    V   overflow   binary
export const bit_ccv = 6;   //    v   overflow   two's complement
export const bit_ccC = 7;   //    c   carry      binary


//-----------------------------------------------------------------------------
// Assembly language statements
//-----------------------------------------------------------------------------

// The instruction set is represented by a map from mnemonic to
// statementSpec spec


// Each statement is initialized as noOperation; this is overridden if a
// valid operation field exists (by the parseOperation function)

// const noOperation = {format:NOOPERATION, opcode:[]};

// Data statements
statementSpec.set("data",  {format:DATA, opcode:[]});

// Empty statement
statementSpec.set("",   {format:EMPTY, opcode:[]});

// Opcodes (in the op field) of 0-13 denote RRR instructions
statementSpec.set("add",     {format:aRRR, opcode:[0]});
statementSpec.set("sub",     {format:aRRR, opcode:[1]});
statementSpec.set("mul",     {format:aRRR, opcode:[2]});
statementSpec.set("div",     {format:aRRR, opcode:[3]});
statementSpec.set("cmp",     {format:aRR,  opcode:[4]});
statementSpec.set("cmplt",   {format:aRRR, opcode:[5]});
statementSpec.set("cmpeq",   {format:aRRR, opcode:[6]});
statementSpec.set("cmpgt",   {format:aRRR, opcode:[7]});
statementSpec.set("invold",  {format:aRR,  opcode:[8]});
statementSpec.set("andold",  {format:aRRR, opcode:[9]});
statementSpec.set("orold",   {format:aRRR, opcode:[10]});
statementSpec.set("xorold",  {format:aRRR, opcode:[11]});
statementSpec.set("nop",     {format:aRRR, opcode:[12]});
statementSpec.set("trap",    {format:aRRR, opcode:[13]});

// If op=14, escape to EXP format
// If op=15, escape to RX format.

// RX instructions
statementSpec.set("lea",     {format:aRX,  opcode:[15,0]});
statementSpec.set("load",    {format:aRX,  opcode:[15,1]});
statementSpec.set("store",   {format:aRX,  opcode:[15,2]});
statementSpec.set("jump",    {format:aJX,  opcode:[15,3,0]});
statementSpec.set("jumpc0",  {format:aKX,  opcode:[15,4]});
statementSpec.set("jumpc1",  {format:aKX,  opcode:[15,5]});
statementSpec.set("jumpf",   {format:aRX,  opcode:[15,6]});
statementSpec.set("jumpt",   {format:aRX,  opcode:[15,7]});
statementSpec.set("jal",     {format:aRX,  opcode:[15,8]});
statementSpec.set("testset", {format:aRX,  opcode:[15,9]});

// Mnemonics for EXP instructions
// Expanded instructions with one word: opcode 0,...,7
// EXP0
statementSpec.set("rfi",     {format:EXP0,     opcode:[14,0]});
// Expanded instructions with two words: opcode >= 8
// RRXEXP
statementSpec.set("save",    {format:aRRXEXP,   opcode:[14,8]});
statementSpec.set("restore", {format:aRRXEXP,   opcode:[14,9]});
// aRCEXP
statementSpec.set("getctl",  {format:aRCEXP,    opcode:[14,10]});
statementSpec.set("putctl",  {format:aRCEXP,    opcode:[14,11]});
// RREXP
statementSpec.set("execute", {format:aRREXP,    opcode:[14,12]});
// RRREXP
statementSpec.set("push",    {format:aRRREXP,   opcode:[14,13]});
statementSpec.set("pop",     {format:aRRREXP,   opcode:[14,14]});
statementSpec.set("top",     {format:aRRREXP,   opcode:[14,15]});
// RRKEXP
statementSpec.set("shiftl",  {format:aRRKEXP,   opcode:[14,16]});
statementSpec.set("shiftr",  {format:aRRKEXP,   opcode:[14,17]});
// RRKKEXP
statementSpec.set("extract", {format:aRRKKEXP,  opcode:[14,18]});
statementSpec.set("extracti",{format:aRRKKEXP,  opcode:[14,19]});
statementSpec.set("inject",  {format:aRRRKKEXP, opcode:[14,20]});
statementSpec.set("injecti", {format:aRRRKKEXP, opcode:[14,21]});
// RRRKEXP
statementSpec.set("logicw",  {format:aRRRKEXP,  opcode:[14,22]});
// RRRKKEXP
statementSpec.set("logicb",  {format:aRRRKKEXP, opcode:[14,23]});
// Assembler directives
statementSpec.set("data",    {format:DATA,      opcode:[]});
statementSpec.set("module",  {format:DirModule, opcode:[]});
statementSpec.set("import",  {format:DirImport, opcode:[]});
statementSpec.set("export",  {format:DirExport, opcode:[]});
statementSpec.set("org",     {format:DirOrg,    opcode:[]});
statementSpec.set("equ",     {format:DirEqu,    opcode:[]});

// -------------------------------------
// Pseudoinstructions
// -------------------------------------

// JX is a pseudoinstruction format: an assembly language statement
// format which omits the d field, but the machine language format is
// RX, where R0 is used for the d field.  For example, jump loop[R5]
// doesn't require d field in assembly language, but the machine
// language uses d=R0.

// Mnemonics for jumpc0 based on signed comparisons, overflow, carry
statementSpec.set("jumple",  {format:aJX,  opcode:[15,4,bit_ccg]});
statementSpec.set("jumpne",  {format:aJX,  opcode:[15,4,bit_ccE]});
statementSpec.set("jumpge",  {format:aJX,  opcode:[15,4,bit_ccl]});
statementSpec.set("jumpnv",  {format:aJX,  opcode:[15,4,bit_ccv]});
statementSpec.set("jumpnvu", {format:aJX,  opcode:[15,4,bit_ccV]});
statementSpec.set("jumpnco", {format:aJX,  opcode:[15,4,bit_ccC]});

// Mnemonics for jumpc1 based on signed comparisons
statementSpec.set("jumplt",  {format:aJX,  opcode:[15,5,bit_ccl]});
statementSpec.set("jumpeq",  {format:aJX,  opcode:[15,5,bit_ccE]});
statementSpec.set("jumpgt",  {format:aJX,  opcode:[15,5,bit_ccg]});
statementSpec.set("jumpv",   {format:aJX,  opcode:[15,5,bit_ccv]});
statementSpec.set("jumpvu",  {format:aJX,  opcode:[15,5,bit_ccV]});
statementSpec.set("jumpco",  {format:aJX,  opcode:[15,5,bit_ccC]});


// RREXP pseudo logicw
statementSpec.set("inv",     {format:aRREXP,  opcode:[14,22,12], pseudo:true});
// RRKEXP pseudo: logicb
statementSpec.set("invb",    {format:aRRKEXP, opcode:[14,23,12], pseudo:true});
// RRREXP pseudo logic
statementSpec.set("and",     {format:aRRREXP, opcode:[14,22,1], pseudo:true});
statementSpec.set("or",      {format:aRRREXP, opcode:[14,22,7], pseudo:true});
statementSpec.set("xor",     {format:aRRREXP, opcode:[14,22,6], pseudo:true});
// aRRRKEXP pseudo logicb
statementSpec.set("andb",    {format:aRRRKEXP, opcode:[14,23,1], pseudo:true});
statementSpec.set("orb",     {format:aRRRKEXP, opcode:[14,23,7], pseudo:true});
statementSpec.set("xorb",    {format:aRRRKEXP, opcode:[14,23,6], pseudo:true});

// Mnemonic for field
// aRKKEXP pseudo injecti
statementSpec.set("field",   {format:aRKKEXP,  opcode:[14,22], pseudo:true});

// -------------------------------------
// Mnemonics for control registers
// -------------------------------------

// The getctl and putctl instructions contain a field indicating which
// control register to use. This record defines the names of those
// control registers (used in the assembly language) and the numeric
// index for the control register (used in the machine language).

ctlReg.set ("status",   {ctlRegIndex:0});
ctlReg.set ("mask",     {ctlRegIndex:1});
ctlReg.set ("req",      {ctlRegIndex:2});
ctlReg.set ("istat",    {ctlRegIndex:3});
ctlReg.set ("ipc",      {ctlRegIndex:4});
ctlReg.set ("vect",     {ctlRegIndex:5});
ctlReg.set ("psegBeg",  {ctlRegIndex:6});
ctlReg.set ("psegEnd",  {ctlRegIndex:7});
ctlReg.set ("dsegBeg",  {ctlRegIndex:8});
ctlReg.set ("dsegEnd",  {ctlRegIndex:9});

//-----------------------------------------------------------------------------
// Status register bits
//-----------------------------------------------------------------------------

// Define the bit index for each flag in the status register.  "Big
// endian" notation is used, where 0 indicates the most significant
// (leftmost) bit, and index 15 indicates the least significant
// (rightmost) bit.

// When the machine boots, the registers are initialized to 0.  The
// user state flag is defined so that userStateBit=0 indicates that
// the processor is in system (or supervisor) state.  The reason for
// this is that the machine should boot into a state that enables the
// operating system to initialize itself, so privileged instructions
// need to be executable.  Furthermore, interrupts are disabled when
// the machine boots, because interrupts are unsafe to execute until
// the interrupt vector has been initialized.

export const userStateBit     = 0;   // 0 = system state,  1 = user state
export const intEnableBit     = 1;   // 0 = disabled,      1 = enabled



//-----------------------------------------------------------------------------
// Interrupt request and mask bits
//-----------------------------------------------------------------------------

export const timerBit         = 0;   // timer has gone off
export const segFaultBit      = 1;   // access invalid virtual address
export const stackFaultBit    = 2;   // invalid memory virtual address
export const userTrapBit      = 3;   // user trap
export const overflowBit      = 4;   // overflow occurred
export const zDivBit          = 5;   // division by 0

//-----------------------------------------------------------------------------
// Assembly language data definitions for control bits
//-----------------------------------------------------------------------------

// A systems program can use the following canonical data definitions
// to access the control bits.  These statements can be copied and
// pasted into an assembly language program (removing, of course, the
// // on each line).

// ; Define status register control bits
// userStateBit    data   $8000
// intEnableBit    data   $4000

// ; Define interrupt control bits
// timerBit        data   $8000   ; bit 0
// segFaultBit     data   $4000   ; bit 1
// stackFaultBit   data   $2000   ; bit 2
// userTrapBit     data   $1000   ; bit 3
// overflowBit     data   $0800   ; bit 4
// zDivBit         data   $0400   ; bit 5

