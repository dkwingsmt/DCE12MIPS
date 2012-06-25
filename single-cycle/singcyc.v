`timescale 1ns/1ps

`define OPCODE_RSTYLE       6'h00;
`define OPCODE_LW           6'h23;
`define OPCODE_SW           6'h2b;
`define OPCODE_LUI          6'h0f;
`define  FUNCT_ADD          6'h20;
`define  FUNCT_ADDU         6'h21;
`define OPCODE_ADDI         6'h08;
`define OPCODE_ADDIU        6'h09;
`define  FUNCT_SUB          6'h22;
`define  FUNCT_SUBU         6'h23;
`define  FUNCT_AND          6'h24;
`define OPCODE_ANDI         6'h0c;
`define  FUNCT_OR           6'h25;
`define  FUNCT_XOR          6'h26;
`define  FUNCT_NOR          6'h27;
`define  FUNCT_SLL          6'h00;
`define  FUNCT_SRL          6'h02;
`define  FUNCT_SRA          6'h03;
`define  FUNCT_SLT          6'h2a;
`define OPCODE_SLTI         6'h0a;
`define OPCODE_SLTIU        6'h0b;
`define OPCODE_BEQ          6'h04;
`define OPCODE_BNE          6'h05;
`define OPCODE_J            6'h02;
`define OPCODE_JAL          6'h03;
`define  FUNCT_JR           6'h08;
`define  FUNCT_JALR         6'h09;

module singcyc_ctrl_unit(iOpCode, oCtrlSig)
    input               iOpCode;
    output      [9:0]   oCtrlSig;

    reg             RegDst,     
                    Jump,       
                    Branch,
                    MemRead,
                    MemWrite,
                    ALUSrc,
                    MemtoReg;
    reg     [1:0]   ALUOp;
endmodule

module singcyc_core(iClk,
                    iRst_n, 
                    oRdInstAddr, 
                    iRdInst, 
                    oRdWrMemAddr, 
                    oMemWrite, 
                    oMemRead, 
                    oWData, 
                    iRData)

    input               iClk;
    input               iRst_n;
    output  reg [31:0]  oRdInstAddr;
    input       [31:0]  iRdInst;
    output  reg         oRdWrMemAddr;
    output  reg         oMemWrite;
    output  reg         oMemRead;
    output  reg [31:0]  oWData;
    input       [31:0]  iRData;



endmodule
