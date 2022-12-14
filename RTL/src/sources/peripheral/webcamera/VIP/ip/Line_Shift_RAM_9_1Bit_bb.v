// megafunction wizard: %Shift register (RAM-based)%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: ALTSHIFT_TAPS 

// ============================================================
// File Name: Line_Shift_RAM_9_1Bit.v
// Megafunction Name(s):
// 			ALTSHIFT_TAPS
//
// Simulation Library Files(s):
// 			
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.1.0 Build 625 09/12/2018 SJ Standard Edition
// ************************************************************

//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.

module Line_Shift_RAM_9_1Bit (
	clken,
	clock,
	shiftin,
	shiftout,
	taps0x,
	taps1x,
	taps2x,
	taps3x,
	taps4x,
	taps5x,
	taps6x,
	taps7x);

	input	  clken;
	input	  clock;
	input	[0:0]  shiftin;
	output	[0:0]  shiftout;
	output	[0:0]  taps0x;
	output	[0:0]  taps1x;
	output	[0:0]  taps2x;
	output	[0:0]  taps3x;
	output	[0:0]  taps4x;
	output	[0:0]  taps5x;
	output	[0:0]  taps6x;
	output	[0:0]  taps7x;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clken;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ACLR NUMERIC "0"
// Retrieval info: PRIVATE: CLKEN NUMERIC "1"
// Retrieval info: PRIVATE: GROUP_TAPS NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: NUMBER_OF_TAPS NUMERIC "8"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "3"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: TAP_DISTANCE NUMERIC "640"
// Retrieval info: PRIVATE: WIDTH NUMERIC "1"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: CONSTANT: LPM_HINT STRING "RAM_BLOCK_TYPE=AUTO"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altshift_taps"
// Retrieval info: CONSTANT: NUMBER_OF_TAPS NUMERIC "8"
// Retrieval info: CONSTANT: TAP_DISTANCE NUMERIC "640"
// Retrieval info: CONSTANT: WIDTH NUMERIC "1"
// Retrieval info: USED_PORT: clken 0 0 0 0 INPUT VCC "clken"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: shiftin 0 0 1 0 INPUT NODEFVAL "shiftin[0..0]"
// Retrieval info: USED_PORT: shiftout 0 0 1 0 OUTPUT NODEFVAL "shiftout[0..0]"
// Retrieval info: USED_PORT: taps0x 0 0 1 0 OUTPUT NODEFVAL "taps0x[0..0]"
// Retrieval info: USED_PORT: taps1x 0 0 1 0 OUTPUT NODEFVAL "taps1x[0..0]"
// Retrieval info: USED_PORT: taps2x 0 0 1 0 OUTPUT NODEFVAL "taps2x[0..0]"
// Retrieval info: USED_PORT: taps3x 0 0 1 0 OUTPUT NODEFVAL "taps3x[0..0]"
// Retrieval info: USED_PORT: taps4x 0 0 1 0 OUTPUT NODEFVAL "taps4x[0..0]"
// Retrieval info: USED_PORT: taps5x 0 0 1 0 OUTPUT NODEFVAL "taps5x[0..0]"
// Retrieval info: USED_PORT: taps6x 0 0 1 0 OUTPUT NODEFVAL "taps6x[0..0]"
// Retrieval info: USED_PORT: taps7x 0 0 1 0 OUTPUT NODEFVAL "taps7x[0..0]"
// Retrieval info: CONNECT: @clken 0 0 0 0 clken 0 0 0 0
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @shiftin 0 0 1 0 shiftin 0 0 1 0
// Retrieval info: CONNECT: shiftout 0 0 1 0 @shiftout 0 0 1 0
// Retrieval info: CONNECT: taps0x 0 0 1 0 @taps 0 0 1 0
// Retrieval info: CONNECT: taps1x 0 0 1 0 @taps 0 0 1 1
// Retrieval info: CONNECT: taps2x 0 0 1 0 @taps 0 0 1 2
// Retrieval info: CONNECT: taps3x 0 0 1 0 @taps 0 0 1 3
// Retrieval info: CONNECT: taps4x 0 0 1 0 @taps 0 0 1 4
// Retrieval info: CONNECT: taps5x 0 0 1 0 @taps 0 0 1 5
// Retrieval info: CONNECT: taps6x 0 0 1 0 @taps 0 0 1 6
// Retrieval info: CONNECT: taps7x 0 0 1 0 @taps 0 0 1 7
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL Line_Shift_RAM_9_1Bit_bb.v TRUE
