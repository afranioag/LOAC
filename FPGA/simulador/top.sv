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

enum logic [1:0] {parada, codigo1, codigo2, codigo3} estado;

logic [3:0] codigo;
logic cartao, reset;
logic [2:0] tentativas;

always_comb begin
	codigo <= SWI[6:4];
	cartao <= SWI[1];
	reset <= SWI[0];
end

always_ff @(posedge clk_2 && posedge reset) begin
	if(reset) begin
		tentativas <= 0;
		codigo <= 0;
		estado <= parada;
	end
	else begin
		unique case(estado)
			parada: begin
				if(codigo == 1 && cartao) estado <= codigo1;
				else tentativas <= tentativas + 1;
			end
			
			codigo1: begin
				if(codigo == 3 && cartao) estado <= codigo2;
				else tentativas <= tentativas + 1;
			end
			
			codigo2: begin
				if(codigo == 7 && cartao) estado <= codigo3;
				else tentativas <= tentativas + 1;
			end
			
		endcase
	end
end

always_comb begin
	LED[7] <= clk_2;
	LED[2] <= cartao;
	LED[0] <= (codigo == 7 && estado == codigo3);
	LED[1] <= (tentativas == 3);
	
end
  
endmodule
