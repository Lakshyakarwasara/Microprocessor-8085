module pc (
    input clk,                 // Clock input
    input rst,                 // Reset signal
    output reg [5:0] pc_out_addr // Address output for instruction memory
);
    reg [5:0] next_addr;       // next address register
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            next_addr <= 5'b00000; // Reset the next_addr to 0
            pc_out_addr <= 5'b00000;    // Reset the address output
        end
        else begin
            // Increment the counter on each clock cycle
            next_addr <= next_addr + 1;
            
            // Output the incremented value as the address
            pc_out_addr <= next_addr;
        end
    end
endmodule


module instr_memory (
    input [5:0] mem_addr, 
    input [10:0] instr_in,    // Address for writing instruction. i.e 8 words memory
    output reg [10:0] mem_instr_out, // Instruction output
    input rw, // read/write control
    input clk, // clock input
    input rst // reset signal
   );
    reg [10:0] mem[63:0]; // Instruction memory array
    integer i;
    // Memory initialization
    always @(*) begin
        if (rst) begin
	
		for (i = 0; i < 64; i = i + 8) begin 
            mem[i] = 11'b00010010010;   // Initialize each memory location to 0
            mem[i+1] = 11'b00110011010;
            mem[i+2] = 11'b01011010010;
            mem[i+3] = 11'b01110010010;
            mem[i+4] = 11'b10010110010;
            mem[i+5] = 11'b10110011110;
            mem[i+6] = 11'b11010011010;
            mem[i+7] = 11'b11111110010;
	
        end

        end
    end

    // Memory read and write operations
    always @(posedge clk) begin
        if (!rst) begin
            if (!rw)
                mem[mem_addr] <= instr_in;
            else
                mem_instr_out <= mem[mem_addr]; // Read operation
        end
    end
endmodule

module decoder(in_decoder,en,opcode,out_decoder);
input [10:0]in_decoder;
input en;
output reg [2:0]opcode; 
output reg[7:0]out_decoder;
  always @(*)
  begin
    if(en==1)
      begin
  opcode = in_decoder[10:8];
  out_decoder = in_decoder[7:0];
   end
//  else
 // begin
 // opcode = 0;
 // out_decoder = 0;
// end
end
endmodule



module instr_reg(ir_inp_instr,en,ir_op_instr); 
  input [10:0]ir_inp_instr;
  input en;
  output reg [10:0]ir_op_instr;
  always @(*)
  begin
    if(en==1)begin
  ir_op_instr <= ir_inp_instr;
end
end
endmodule

module alu(
    input   [7:0] alu_in1,   
    input   [7:0] alu_in2,
    input   [2:0] alu_opcode,
    output  zero,
    output  carry,
    output  negative,
    output  [7:0] alu_result
);

    reg [8:0] result_with_carry;

    // Outputs
    reg zero_reg, carry_reg, negative_reg;

    // Intermediate signals
    reg [7:0] result_reg;

    always @* begin
        case(alu_opcode)
            3'b000: begin  // Bitwise OR
                result_reg = alu_in1 | alu_in2;
		zero_reg = result_reg == 8'b0;
		carry_reg = 1'b0;
		negative_reg = 1'b0;
            end

            3'b001: begin  // Bitwise XOR
                result_reg = alu_in1 ^ alu_in2;
		zero_reg = result_reg == 8'b0;
		carry_reg = 1'b0;
		negative_reg = 1'b0;
            end

            3'b010: begin  // Addition
                result_with_carry = alu_in1 + alu_in2;
                carry_reg = result_with_carry[8];
                result_reg = result_with_carry[7:0];
                zero_reg = result_reg == 8'b0;
		negative_reg = 1'b0;
            end

            3'b011: begin  // Subtraction
                result_with_carry = alu_in1 - alu_in2;
                negative_reg = alu_in1 < alu_in2;
                if (alu_in1 >= alu_in2) begin
                    carry_reg = 1'b0;
                    zero_reg = result_with_carry[7:0] == 8'b0;
		    negative_reg = 1'b0;
                end else begin
                    result_reg = ~result_with_carry[7:0] + 1'b1;
                    carry_reg = 1'b0;
                    zero_reg = 1'b0;
                    negative_reg = 1'b1;
                end
            end

            3'b100: begin  // Compare 
                negative_reg = alu_in1 < alu_in2;
                carry_reg = alu_in1 >= alu_in2;  // Carry flag indicates A >= B
                zero_reg = alu_in1 == alu_in2;
            end

            3'b101: begin  // Bitwise AND
                result_reg = alu_in1 & alu_in2;
                zero_reg = result_reg == 8'b0;
                carry_reg = 1'b0;
                negative_reg = 1'b0;
            end
            
            3'b110: begin  // Shift Left (SLL)
                result_reg = alu_in1 << alu_in2[2:0];
                zero_reg = result_reg == 8'b0;
		carry_reg = 1'b0;
                negative_reg = 1'b0;
            end
            
            3'b111: begin  // Shift Right (SRL)
                result_reg = alu_in1 >> alu_in2[2:0];
                zero_reg = result_reg == 8'b0;
		carry_reg = 1'b0;
                negative_reg = 1'b0;
            end
            
            
	    default: begin
    // Default to grounding the floating pins
    result_reg[0] = 1'b0; // Set bit 0 to 0
    result_reg[1] = 1'b0; // Set bit 1 to 0
    result_reg[2] = 1'b0; // Set bit 2 to 0
    result_reg[3] = 1'b0; // Set bit 3 to 0
    result_reg[4] = 1'b0; // Set bit 4 to 0
    result_reg[5] = 1'b0; // Set bit 5 to 0
    result_reg[6] = 1'b0; // Set bit 6 to 0
    result_reg[7] = 1'b0; // Set bit 7 to 0
    zero_reg = 1'b1;     // Ground zero output
    carry_reg = 1'b0;    // Ground carry output
    negative_reg = 1'b0; // Ground negative output
end
        
endcase
    end

    assign zero = zero_reg;
    assign carry = carry_reg;
    assign negative = negative_reg;
    assign alu_result = result_reg;

endmodule

module ff (
    input wire clk,       // Clock input
    input d,        // 8-bit Data input
    output reg q    // 8-bit Output
);

    always @(posedge clk) begin
        q <= d;           // Update output based on data input on positive clock edge
    end

endmodule

module ff_8bit (
    input wire clk,      // Clock input
    input [7:0] d,       // 8-bit Data input
    output reg [7:0] q   // 8-bit Output
);

    always @(posedge clk) begin
        q <= d;  // Update output based on data input on positive clock edge
    end

endmodule


module top8_module (
    input clk,                   // Clock input
    input rst,                   // Reset signal
    input [7:0] alu_in1_inp,
    
    input [10:0] inst_in,        // Instruction input
    input rw,                    // Read/Write control
    input en,
    output wire [7:0] alu_result,
    output wire ff_zero,
    output wire ff_carry,
    output wire ff_negative
);
    wire ff_pc_rst;
    wire [7:0] alu_in1_ff; // Declare 8-bit wire to connect flip-flop output to ALU input
    wire [5:0] pc_out_addr;      // Address output for instruction memory
    wire [10:0] mem_instr_out;   // Output from instruction memory
    wire [10:0] ir_op_instr;     // Output from instruction register
    wire [2:0] opcode;           // Output opcode from decoder
    wire [7:0] out_decoder;      // Output from decoder
    wire carry;                  // ALU carry output
    wire negative;               // ALU negative output
    wire zero;                   // ALU zero output

    // Instantiate 8-bit flip-flop for alu_in1
    ff_8bit ff_alu_in1 (
        .clk(clk),
        .d(alu_in1_inp),
        .q(alu_in1_ff)
    );

    // Instantiate Program Counter
    pc pc_inst (
        .clk(clk),
        .rst(ff_pc_rst),
        .pc_out_addr(pc_out_addr)
    );

    // Instantiate Instruction Memory
    instr_memory mem_inst (
        .rw(rw),
        .instr_in(inst_in),
        .mem_addr(pc_out_addr),
        .mem_instr_out(mem_instr_out),
        .clk(clk),
        .rst(rst)
    );
    
    // Instantiate instruction register
    instr_reg ir_inst (
        .ir_inp_instr(mem_instr_out),
        .en(en),
        .ir_op_instr(ir_op_instr)
    );

    // Instantiate decoder
    decoder decoder_inst (
        .in_decoder(ir_op_instr),
        .en(en),
        .opcode(opcode),
        .out_decoder(out_decoder)
    );

    // Instantiate flip-flops
    ff ff_pc_rst_inst (
        .clk(clk),
        .d(rst),
        .q(ff_pc_rst)
    );

    ff ff_carry_inst (
        .clk(clk),
        .d(carry),
        .q(ff_carry)
    );

    ff ff_zero_inst (
        .clk(clk),
        .d(zero),
        .q(ff_zero)
    );

    ff ff_negative_inst (
        .clk(clk),
        .d(negative),
        .q(ff_negative)
    );

    // Instantiate ALU
    alu alu_inst (
        .alu_in1(alu_in1_ff),  // Connect to the output of 8-bit flip-flop
        .alu_in2(out_decoder),
        .alu_opcode(opcode),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .alu_result(alu_result)
    );

endmodule



