`timescale 1ns/1ps
module box(
    //-----Sys----------
	input  wire           CLK,
	input  wire           rst_n,
	input  wire           display_en,
	input  wire   [15:0]  X,
	input  wire   [15:0]  Y,
	
	input  wire   [15:0]  x1,
	input  wire   [15:0]  y1,
	input  wire   [15:0]  x2,
	input  wire   [15:0]  y2,

	output  wire          out_en
);
wire   out_en0;
wire   out_en1;
wire   out_en2;
wire   out_en3;

assign out_en0 = (((Y==y1)||(Y==y2))&&(x1<=X)&&(X<=x2)) ||
				 (((X==x1)||(X==x2))&&(y1<=Y)&&(Y<=y2))  ;
				
assign out_en1 = (((Y==y1)||(Y==y2))&&(x1<=X)&&(X<=x2)) ||
				 (((X==x1)||(X==x2))&&(y2<=Y)&&(Y<=y1))  ;

assign out_en2 = (((Y==y1)||(Y==y2))&&(x2<=X)&&(X<=x1)) ||
				 (((X==x1)||(X==x2))&&(y1<=Y)&&(Y<=y2))  ;
				
assign out_en3 = (((Y==y1)||(Y==y2))&&(x2<=X)&&(X<=x1)) ||
				 (((X==x1)||(X==x2))&&(y2<=Y)&&(Y<=y1))  ;	

assign out_en  = (out_en0||out_en1||out_en2||out_en3)&&display_en	;	 
endmodule
