module cmsdk_fpga_sram #(
// --------------------------------------------------------------------------
// Parameters
// --------------------------------------------------------------------------
  parameter AW = 14
 )
 (
  // Inputs
  input  wire          CLK,
  input  wire [AW-1:0] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA
  );

// -----------------------------------------------------------------------------
// Constant Declarations
// -----------------------------------------------------------------------------
/*
localparam AWT = ((1<<(AW-0))-1);

// Memory Array
reg     [31:0]  BRAM [AWT:0];
reg[4:0] n;

initial begin
  //$readmemh("F:/09-file/FPGA/ALTERA/SOC/M3_SOC/Smart_camera/v2.0/software/image.hex",BRAM);
  //$readmemh("image.hex",BRAM); 
end

// Internal signals
reg     [AW-1:0]  addr_q1;
wire    [3:0]     write_enable;
reg               cs_reg;
wire    [31:0]    read_data;

assign write_enable[3:0] = WREN[3:0] & {4{CS}};

always @ (posedge CLK)
begin
cs_reg <= CS;
end

// Infer Block RAM - syntax is very specific.
always@(posedge CLK) begin
if(write_enable[0]) BRAM[ADDR][7:0] <= WDATA[7:0];
BRAM[0][7:0] <= 8'hff;
end
always@(posedge CLK) begin
if(write_enable[1]) BRAM[ADDR][15:8] <= WDATA[15:8];
end
always@(posedge CLK) begin
if(write_enable[2]) BRAM[ADDR][23:16] <= WDATA[23:16];
end
always@(posedge CLK) begin
if(write_enable[3]) BRAM[ADDR][31:24] <= WDATA[31:24];
end

always @ (posedge CLK)begin
  addr_q1 <= ADDR[AW-1:0];
end

assign read_data  = BRAM[addr_q1];
assign RDATA      = (cs_reg) ? read_data : {32{1'b0}};*/

fpga_sram_ip	fpga_sram_ip_inst (
	.address ( ADDR   ),
	.byteena ( WREN   ),
	.clock   ( CLK    ),
	.data    ( WDATA  ),
	.wren    ( CS     ),
	.q       ( RDATA  )
);
endmodule
