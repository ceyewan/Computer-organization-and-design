// `include "ctrl_encode_def.v"


module ctrl(Op, Funct, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,
            AREGSel
            );
            
   input  [5:0] Op;       // opcode
   input  [5:0] Funct;    // funct
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output       EXTOp;    // control signal to signed extension
   output [3:0] ALUOp;    // ALU opertion
   output [1:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for B
   output       AREGSel;  // ALU source for A****

   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   
  // r format
   wire rtype  = ~|Op;
   wire i_add  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // add
   wire i_sub  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // sub
   wire i_and  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // and
   wire i_or   = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]& Funct[0]; // or
   wire i_slt  = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // slt
   wire i_sltu = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // sltu
   wire i_addu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // addu
   wire i_subu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // subu
   wire i_sll  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // sll****
   wire i_srl  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // srl****
   wire i_sllv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // sllv****
   wire i_srlv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]&~Funct[0]; // srlv****
   wire i_nor  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]& Funct[0]; // nor****
   wire i_jr   = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // jr****
   wire i_jalr = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // jalr****

  // i format
   wire i_addi = ~Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // addi
   wire i_ori  = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]& Op[0]; // ori
   wire i_lw   =  Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0]; // lw
   wire i_sw   =  Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]& Op[0]; // sw
   wire i_beq  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // beq
   wire i_bne  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]& Op[0]; // bne****
   wire i_slti = ~Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]&~Op[0]; // slti****
   wire i_lui  = ~Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0]; // lui****
   wire i_andi = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]&~Op[0]; // andi****

  // j format
   wire i_j    = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]&~Op[0];  // j
   wire i_jal  = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0];  // jal

  // generate control signals
  assign RegWrite   = rtype | i_lw | i_addi | i_andi | i_ori | i_slti | i_lui | i_jalr | i_jal; // register write,i_slti, i_lui,i_jalr**** 
  
  assign MemWrite   = i_sw;                           // memory write
  assign ALUSrc     = i_lw | i_sw | i_addi | i_ori | i_slti | i_lui | i_andi;  // ALU B is from instruction immediate,i_slti,i_lui****
  assign EXTOp      = i_addi | i_lw | i_sw | i_slti;           // signed extension,i_slti****

  // GPRSel_RD   2'b00
  // GPRSel_RT   2'b01
  // GPRSel_31   2'b10
  assign GPRSel[0] = i_lw | i_addi | i_ori | i_slti | i_lui | i_andi;
  assign GPRSel[1] = i_jalr | i_jal;     //i_jalr****
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = i_lw;  
  assign WDSel[1] = i_jalr | i_jal;  //i_jalr is $31  

  // NPC_PLUS4   2'b00
  // NPC_BRANCH  2'b01
  // NPC_JUMP    2'b10
  // NPC_JR      2'b11
  assign NPCOp[0] = (i_beq & Zero) | (i_bne &~Zero) | i_jr | i_jalr;    //i_bne is equal with i_beq****
  assign NPCOp[1] = i_j | i_jr | i_jalr | i_jal; //i_jalr,i_jr****

  // AREGSel_Rs     1'b0
  // AREGSel_Shamt  1'b1
  assign AREGSel = i_sll | i_srl;   //i_sll,i_srl****
  
  // ALU_NOP   4'b0000
  // ALU_ADD   4'b0001
  // ALU_SUB   4'b0010
  // ALU_AND   4'b0011
  // ALU_OR    4'b0100
  // ALU_SLT   4'b0101
  // ALU_SLTU  4'b0110
  // ALU_SRL   4'b1000
  // ALU_LUI   4'b1001
  // ALU_NOR  4'b1010
  assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_slti | i_addu | i_sll | i_sllv | i_lui | i_andi; //i_slti is 101 ****
  assign ALUOp[1] = i_sub | i_beq | i_bne | i_and | i_sltu | i_subu | i_sll | i_sllv | i_nor | i_andi;     //i_bne is 010****
  assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_slti | i_sll | i_sllv;              //i_sll,i_sllv is 111****
  assign ALUOp[3] = i_srl | i_srlv | i_lui | i_nor;  //i_srl and i_srlv is 1000,i_lui is 1001,i_nor is 1010
endmodule
