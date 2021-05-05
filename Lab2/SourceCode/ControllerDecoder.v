`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Controller Decoder
// Tool Versions: Vivado 2017.4.1
// Description: Controller Decoder Module
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  对指令进行译码，将其翻译成控制信号，传输给各个部�?????
// 输入
    // Inst              待译码指�?????
// 输出
    // jal               jal跳转指令
    // jalr              jalr跳转指令
    // op2_src           ALU的第二个操作数来源�?�为1时，op2选择imm，为0时，op2选择reg2
    // ALU_func          ALU执行的运算类�?????
    // br_type           branch的判断条件，可以是不进行branch
    // load_npc          写回寄存器的值的来源（PC或�?�ALU计算结果�?????, load_npc == 1时�?�择PC
    // wb_select         写回寄存器的值的来源（Cache内容或�?�ALU计算结果），wb_select == 1时�?�择cache内容
    // load_type         load类型
    // src_reg_en        指令中src reg的地�?????是否有效，src_reg_en[1] == 1表示reg1被使用到了，src_reg_en[0]==1表示reg2被使用到�?????
    // reg_write_en      通用寄存器写使能，reg_write_en == 1表示�?????要写回reg
    // cache_write_en    按字节写入data cache
    // imm_type          指令中立即数类型
    // alu_src1          alu操作�?????1来源，alu_src1 == 0表示来自reg1，alu_src1 == 1表示来自PC
    // alu_src2          alu操作�?????2来源，alu_src2 == 2’b00表示来自reg2，alu_src2 == 2'b01表示来自reg2地址，alu_src2 == 2'b10表示来自立即�?????
// 实验要求
    // 补全模块


`include "Parameters.v"   
module ControllerDecoder(
    input wire [31:0] inst,
    output wire jal,
    output wire jalr,
    output wire op1_src, // csr
    output wire [1:0] op2_src,
    output reg [3:0] ALU_func,
    output reg [2:0] br_type,
    output wire load_npc,
    output wire [1:0] wb_select,
    output reg [2:0] load_type,
    output reg [1:0] src_reg_en,
    output reg reg_write_en,
    output reg csr_write_en,
    output reg [3:0] cache_write_en,
    output wire alu_src1,
    output wire [1:0] alu_src2,
    output reg [2:0] imm_type
    );

    // TODO: Complete this module
    parameter LUI = 7'b0110111, AUIPC = 7'b0010111, JAL = 7'b1101111, JALR = 7'b1100111, BR = 7'b1100011, LOAD = 7'b0000011, STORE = 7'b0100011, I = 7'b0010011, R = 7'b0110011, CSR = 7'b1110011;
    assign jal = (inst[6:0] == JAL)? 1'b1 : 1'b0;
    assign jalr = (inst[6:0] == JALR)? 1'b1 : 1'b0;
    assign op2_src = (inst[6:0] == LUI || inst[6:0] == AUIPC || inst[6:0] == JAL || inst[6:0] == JALR || inst[6:0] == BR || inst[6:0] == LOAD || inst[6:0] == STORE || inst[6:0] == I) ? 2'b01 : 
                     ((inst[6:0] == CSR) ? 2'b10 : 2'b0);
    assign op1_src = (inst[6:0] == CSR && inst[14] == 1'b1)? 1'b1 : 1'b0;
    assign load_npc = (inst[6:0] == JAL || inst[6:0] == JALR)? 1'b1 : 1'b0;
    assign wb_select = (inst[6:0] == CSR) ? 2'b10 : ((inst[6:0] == LOAD) ? 2'b01 : 2'b00);  //因此alu的操作不会影响register的写�?
    assign alu_src1 = (inst[6:0] == AUIPC) ? 1'b1 : 1'b0;
    assign alu_src2 = (inst[6:0] == LUI || inst[6:0] == AUIPC || inst[6:0] == STORE || inst[6:0] == I || inst[6:0] == LOAD || inst[6:0] == BR) ? 2'b10 : 2'b00;
    always @ (*)
    begin
        ALU_func = `ADD;
        br_type = `NOBRANCH;
        load_type = `NOREGWRITE;
        src_reg_en = 2'b0;
        reg_write_en = 1'b0;
        csr_write_en = 1'b0;
        cache_write_en = 4'b0;
        imm_type = `RTYPE;
        case(inst[6:0])
            LUI:  //lui
            begin
              //  op2_src = 1'b0;
                ALU_func = `LUI;
             //   load_npc = 1'b0;
             //   wb_select = 1'b0;
                src_reg_en = 2'b0;
                reg_write_en = 1'b1;
                imm_type = `UTYPE;
            end
            AUIPC:  //auipc
            begin
               // op2_src = 1'b0;
                ALU_func = `ADD;
              //  load_npc = 1'b0;
              //  wb_select = 1'b0;
                src_reg_en = 2'b0;
                reg_write_en = 1'b1;
            //    alu_src1 = 1'b1;  //来自PC
                imm_type = `UTYPE;
            end
            JAL:  //jal
            begin
             //   jal = 1'b1;
             //   op2_src = 1'b1;  //计算偏移地址
              // load_npc = 1'b1;
             //  wb_select = 1'b0;
                src_reg_en = 2'b0;
                reg_write_en = 1'b1;
                imm_type = `JTYPE;
            end
            JALR:  //jalr
            begin
            //    jalr = 1'b1;
             //   op2_src = 1'b1;  //计算偏移地址
                ALU_func = `ADD;
             //   load_npc = 1'b1;
             //   wb_select = 1'b0;
                src_reg_en = 2'b10;
                reg_write_en = 1'b1;
                imm_type = `ITYPE;
            end
            BR:  //br
            begin
              //  op2_src = 1'b1;
             //   load_npc = 1'b0;
                src_reg_en = 2'b11;
                imm_type = `BTYPE;
                case(inst[14:12])
                    3'b000: br_type = `BEQ;  //beq
                    3'b001: br_type = `BNE;  //bne
                    3'b100: br_type = `BLT;  //blt
                    3'b101: br_type = `BGE;  //bge
                    3'b110: br_type = `BLTU;  //bltu
                    3'b111: br_type = `BGEU;  //bgeu
                endcase
            end
            LOAD:  //load
            begin
             //   op2_src = 1'b1;
                ALU_func = `ADD;
             //   load_npc = 1'b0;
                //wb_select = 1'b1;
                src_reg_en = 2'b10;
                reg_write_en = 1'b1;
                imm_type = `ITYPE;
                case(inst[14:12])
                    3'b000: load_type = `LB;  //lb
                    3'b001: load_type = `LH;  //lh
                    3'b010: load_type = `LW;  //lw
                    3'b100: load_type = `LBU;  //lbu
                    3'b101: load_type = `LHU;  //lhu
                endcase
            end
            STORE: //store
            begin
               // op2_src = 1'b1;
                ALU_func = `ADD;
             //   load_npc = 1'b0;
                src_reg_en = 2'b11;
                imm_type = `STYPE;
                case(inst[14:12])
                    3'b000: cache_write_en = 4'b0001;  //sb
                    3'b001: cache_write_en = 4'b0011;  //sh
                    3'b010: cache_write_en = 4'b1111;  //sw
                endcase
            end
            I:  //立即数指�????
            begin
              //  op2_src = 1'b1;
              //  load_npc = 1'b0;
              //  wb_select = 1'b0;
                src_reg_en = 2'b10;   //reg1被用�???
                reg_write_en = 1'b1;
                imm_type = `ITYPE;
                case(inst[14:12])
                    3'b000: ALU_func = `ADD;  //addi    
                    3'b010: ALU_func = `SLT;  //slti
                    3'b011: ALU_func = `SLTU;  //sltiu
                    3'b100: ALU_func = `XOR;  //xori
                    3'b110: ALU_func = `OR;  //ori
                    3'b111: ALU_func = `AND;  //andi
                    3'b001: ALU_func = `SLL;  //slli
                    3'b101:  
                        if(inst[31:25] == 7'b0)  //srli
                            ALU_func = `SRL; 
                        else 
                            ALU_func = `SRA; 
                endcase
            end
            R:  //R指令
            begin
              //  op2_src = 1'b0;
              //  load_npc = 1'b0;
             //   wb_select = 1'b0;
                src_reg_en = 2'b11;   //reg1,2均被用到
                reg_write_en = 1'b1;
                imm_type = `RTYPE;
                case(inst[14:12])
                    3'b000:  
                        if(inst[31:25] == 7'b0)  //add
                            ALU_func = `ADD;
                        else  //sub
                            ALU_func = `SUB;
                    3'b001: ALU_func = `SLL;  //sll
                    3'b010: ALU_func = `SLT;  //slt
                    3'b011: ALU_func = `SLTU; //sltu
                    3'b100: ALU_func = `XOR;  //xor
                    3'b101:  
                        if(inst[31:25] == 7'b0)  //srl
                            ALU_func = `SRL; 
                        else ALU_func = `SRA;  //sra

                    3'b110: ALU_func = `OR;  //or
                    3'b111: ALU_func = `AND;  //and 
                endcase
             end
            CSR: //特殊指令
            begin
                if(inst[14] == 1'b1 && inst[19:15] == 5'h0)
                    csr_write_en = 1'b0;
                else
                    csr_write_en = 1'b1;
                if(inst[14] == 1'b1)
                    src_reg_en = 2'b00;
                else
                    src_reg_en = 2'b10;
                reg_write_en = 1'b1;  //如果rd�?0，由register本身的设定，不会写入reg
                imm_type = `ZTYPE;
                case(inst[14:12])
                    3'b001: ALU_func = `REG1; //csrrw
                    3'b010: ALU_func = `OR; //csrrs
                    3'b011: ALU_func = `CLR; //csrrc
                    3'b101: ALU_func = `REG1; //csrrwi  op1_src是wire，因此这里不必指�?
                    3'b110: ALU_func = `OR; //csrrsi
                    3'b111: ALU_func = `CLR; //csrrci
                endcase 
            end
            //default:
        endcase
    
    end

endmodule
