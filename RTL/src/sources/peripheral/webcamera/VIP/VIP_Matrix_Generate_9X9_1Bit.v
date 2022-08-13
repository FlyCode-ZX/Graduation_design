/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2011-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		http://blog.chinaaet.com/crazybingo
Email Address 		: 		thereturnofbingo@gmail.com
Filename			:		VIP_Matrix_Generate_3X3_1Bit.v
Data				:		2014-03-19
Description			:		Generate 1Bit 3X3 Matrix for Video Image Processor.
							Give up the 1th and 2th row edge data caculate for simple process
							Give up the 1th and 2th point of 1 line for simple process
Modification History	:
Data			By			Version			Change Description
=========================================================================
13/05/26		CrazyBingo	1.0				Original
14/03/16		CrazyBingo	2.0				Modification
-------------------------------------------------------------------------
|                                     Oooo								|
+-------------------------------oooO--(   )-----------------------------+
                               (   )   ) /
                                \ (   (_/
                                 \_)
-----------------------------------------------------------------------*/ 

`timescale 1ns/1ns
module VIP_Matrix_Generate_9X9_1Bit
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	input				per_img_Bit,		//Processed Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	output				matrix_frame_vsync,	//Prepared Image data vsync valid signal
	output				matrix_frame_href,	//Prepared Image data href vaild  signal
	output				matrix_frame_clken,	//Prepared Image data output/capture enable clock	
	output	reg			matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19,	//9X9 Matrix output
	output	reg			matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29,
	output	reg			matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39,
	output	reg			matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49,
	output	reg			matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59,
	output	reg			matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69,
	output	reg			matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79,
	output	reg			matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89,
	output	reg			matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99	
);


//Generate 9*9 matrix 
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
//sync row3_data with per_frame_clken & row1_data & raw2_data
wire	row1_data;	//frame data of the 1th row
wire	row2_data;	//frame data of the 2th row
wire  row3_data;
wire  row4_data;
wire  row5_data;
wire  row6_data;
wire  row7_data;
wire  row8_data;

reg		row9_data;	//frame data of the 3th row
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		row9_data <= 0;
	else 
		begin
		if(per_frame_clken)
			row9_data <= per_img_Bit;
		else
			row9_data <= row9_data;
		end	
end

//---------------------------------------
//module of shift ram for raw data
wire	shift_clk_en = per_frame_clken;

Line_Shift_RAM_9_1Bit u_Line_Shift_RAM_9_1Bit
(
	.clock		(clk),
	.clken		(shift_clk_en),	//pixel enable clock
//	.aclr		(1'b0),

	.shiftin	(row9_data),	//Current data input
	.taps0x		(row8_data),	//Last row data
	.taps1x		(row7_data),	//Up a row data
	.taps2x		(row6_data),
	.taps3x		(row5_data),	
	.taps4x		(row4_data),
	.taps5x		(row3_data),
	.taps6x		(row2_data),	
	.taps7x		(row1_data),	
	.shiftout	()
);

//------------------------------------------
//lag 2 clocks signal sync  
reg	[1:0]	per_frame_vsync_r;
reg	[1:0]	per_frame_href_r;	
reg	[1:0]	per_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r <= 0;
		per_frame_href_r <= 0;
		per_frame_clken_r <= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	{per_frame_vsync_r[0], 	per_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r[0], 	per_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r[0], 	per_frame_clken};
		end
end
//Give up the 1th and 2th row edge data caculate for simple process
//Give up the 1th and 2th point of 1 line for simple process
wire	read_frame_href		=	per_frame_href_r[0];	//RAM read href sync signal
wire	read_frame_clken	=	per_frame_clken_r[0];	//RAM read enable
assign	matrix_frame_vsync 	= 	per_frame_vsync_r[1];
assign	matrix_frame_href 	= 	per_frame_href_r[1];
assign	matrix_frame_clken 	= 	per_frame_clken_r[1];


//---------------------------------------------------------------------------
//---------------------------------------------------
/***********************************************
	(1)	Read data from Shift_RAM
	(2) Caculate the Sobel
	(3) Steady data after Sobel generate
************************************************/
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		{matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19} <= 9'b0;
		{matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29} <= 9'b0;
		{matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39} <= 9'b0;
		{matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49} <= 9'b0;
		{matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59} <= 9'b0;
		{matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69} <= 9'b0;
		{matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79} <= 9'b0;
		{matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89} <= 9'b0;
		{matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99} <= 9'b0;
		end
	else if(read_frame_href)
		begin
		if(read_frame_clken)	//Shift_RAM data read clock enable
			begin
			{matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19} <= {matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19 , row1_data};	//1th shift input
			{matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29} <= {matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29	,row2_data};	//2th shift input
			{matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39} <= {matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39	, row3_data};	//3th shift input
			{matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49} <= {matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49	, row4_data};	//4th shift input
			{matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59} <= {matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59	, row5_data};	//5th shift input
			{matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69} <= {matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69	, row6_data};
			{matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79} <= {matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79	, row7_data};
			{matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89} <= {matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89 , row8_data};
			{matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99} <= {matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99 , row9_data};
			
			end
		else
			begin
			{matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19} <= {matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19};
			{matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29} <= {matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29};
			{matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39} <= {matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39};
			{matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49} <= {matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49};
			{matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59} <= {matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59};
			{matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69} <= {matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69};
			{matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79} <= {matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79};
			{matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89} <= {matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89};
			{matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99} <= {matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99};
			
			end	
		end
	else
		begin
		{matrix_p11, matrix_p12, matrix_p13,matrix_p14,matrix_p15,matrix_p16,matrix_p17,matrix_p18,matrix_p19} <= 9'b0;
		{matrix_p21, matrix_p22, matrix_p23,matrix_p24,matrix_p25,matrix_p26,matrix_p27,matrix_p28,matrix_p29} <= 9'b0;
		{matrix_p31, matrix_p32, matrix_p33,matrix_p34,matrix_p35,matrix_p36,matrix_p37,matrix_p38,matrix_p39} <= 9'b0;
		{matrix_p41, matrix_p42, matrix_p43,matrix_p44,matrix_p45,matrix_p46,matrix_p47,matrix_p48,matrix_p49} <= 9'b0;
		{matrix_p51, matrix_p52, matrix_p53,matrix_p54,matrix_p55,matrix_p56,matrix_p57,matrix_p58,matrix_p59} <= 9'b0;
		{matrix_p61, matrix_p62, matrix_p63,matrix_p64,matrix_p65,matrix_p66,matrix_p67,matrix_p68,matrix_p69} <= 9'b0;
		{matrix_p71, matrix_p72, matrix_p73,matrix_p74,matrix_p75,matrix_p76,matrix_p77,matrix_p78,matrix_p79} <= 9'b0;
		{matrix_p81, matrix_p82, matrix_p83,matrix_p84,matrix_p85,matrix_p86,matrix_p87,matrix_p88,matrix_p89} <= 9'b0;
		{matrix_p91, matrix_p92, matrix_p93,matrix_p94,matrix_p95,matrix_p96,matrix_p97,matrix_p98,matrix_p99} <= 9'b0;
		end
end

endmodule
