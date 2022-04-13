`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero);
           
   input  signed [31:0] A, B;
   input         [2:0]  ALUOp;
   output signed [31:0] C;
   output Zero;
   
   reg [31:0] C;
   integer    i;
       
   always @( * ) begin
      case ( ALUOp )
          `ALU_NOP:  C = A;                          // NOP
          `ALU_ADD:  C = A + B;                      // ADD
          `ALU_SUB:  C = A - B;                      // SUB
          `ALU_AND:  C = A & B;                      // AND/ANDI
          `ALU_OR:   C = A | B;                      // OR/ORI
          `ALU_SLT:  C = (A < B) ? 32'd1 : 32'd0;    // SLT/SLTI
          `ALU_SLTU: C = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;
          `ALU_SLL:  C = B << A; // 左移操作
          `ALU_SRL:  C = B >> A; // 右移操作
          `ALU_LUI:  C = {B, 16`b0};  // 将指令中的16bit立即数保存到地址为rt的通用寄存器的高16位
          `ALU_NOR:  C = ~(A | B); // 或非
          default:   C = A;                          // Undefined
      endcase
   end // end always
   
   assign Zero = (C == 32'b0);

endmodule
    
