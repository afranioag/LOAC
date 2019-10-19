// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

enum logic [1:0]{entrada, saida, fechadas} estado_atual;
  
logic acionaEntrada, acionaSaida, reset;
logic [3:0] numero_carros;
  
parameter CARROS_MAX = 10;
parameter CARROS_MIN = 0;
  
always_comb begin
	acionaEntrada <= SWI[0];
	acionaSaida <= SWI[7];
	reset <= SWI[6];
end

always_ff @(posedge clk_2) begin
	if(reset) begin
		numero_carros <= 0;
		estado_atual <= fechadas;
	end
	else begin
		unique case (estado_atual)
			fechadas: begin
				if(acionaEntrada && numero_carros < CARROS_MAX) estado_atual <= entrada;
				else if(acionaSaida && numero_carros > CARROS_MIN) estado_atual <= saida;
			end
			entrada: begin
				if(!acionaEntrada) begin
					numero_carros <= numero_carros + 1;
					estado_atual <= fechadas;
				end
			end
			saida: begin
				if(!acionaSaida) begin
					numero_carros <= numero_carros - 1;
					estado_atual <= fechadas;
				end
			end
		endcase
	end
end
  
  
always_comb begin
	LED[6:3] <= numero_carros;
	LED[7] <= clk_2;
	LED[0] <= (estado_atual == entrada);
	LED[1] <= (estado_atual == saida);
end
  
  
endmodule
