`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Branch Decision
// Tool Versions: Vivado 2017.4.1
// Description: Decide whether to branch
// 
//////////////////////////////////////////////////////////////////////////////////


//  功能说明
    //  判断是否branch
// 输入
    // reg1               寄存�?????1
    // reg2               寄存�?????2
    // br_type            branch类型
// 输出
    // br                 是否branch
// 实验要求
    // 补全模块

`include "Parameters.v"   
module BranchDecision(
    input wire clk,
    input wire [31:0] reg1, reg2,
    input wire [2:0] br_type,
    input wire [31:0] PC_IF, PC_EX,
    input wire [31:0] br_target,
    input wire taken_EX,
    output reg br, realm,
    output reg taken_btb, taken_bht,
    output reg [31:0] predicted_pc,
    output reg [31:0] pc_old
    );
    // TODO: Complete this module
    parameter NOT_TAKEN_OK = 2'b0, NOT_TAKEN = 2'b01, TAKEN = 2'b10, TAKEN_OK = 2'b11;
    localparam BTB_SIZE = 1<<10, BHT_SIZE = 1<<10;  
    reg [31:0] predicted_pc_table [BTB_SIZE-1:0];
    reg state_bit [BTB_SIZE-1:0];
    reg [1:0] state [BHT_SIZE-1:0];
    //reg taken_btb, taken_bht;
    reg [20: 0] miss_count, total_count, hit_count;
    
    //assign taken = taken_btb & taken_bht;
    
    initial begin
        for(integer i=0; i<BTB_SIZE; i++) 
        begin
            predicted_pc_table[i] = 32'b0;
            state_bit[i] = 1'b0;
        end
        for(integer i = 0; i < BHT_SIZE; i++) begin
            state[i] = NOT_TAKEN_OK;
        end
        taken_btb = 0;
        taken_bht = 0;
        realm = 1;
        pc_old = 32'b0;
        miss_count = 0;
        total_count = 0;
        hit_count = 0;
    end

    always @ (*)
    begin   
        case(br_type)
            `NOBRANCH: br = 1'b0;  //what is no branch?
            `BEQ: br = (reg1 == reg2)? 1'b1: 1'b0;
            `BNE: br = (reg1 != reg2)? 1'b1: 1'b0;
            `BLT: br = ($signed(reg1) < $signed(reg2))? 1'b1: 1'b0;  //如何比较有符号数?
            `BLTU: br = (reg1 < reg2)? 1'b1: 1'b0;
            `BGE: br = ($signed(reg1) >= $signed(reg2))? 1'b1: 1'b0;
            `BGEU: br = (reg1 >= reg2)? 1'b1: 1'b0;
            default: br = 1'b0;
        endcase
        realm = 1;
        if(br_type != `NOBRANCH)  begin
            if(!br) begin
                if(taken_EX) begin
                    realm = 0;
                end
            end
            else  begin
                if(taken_EX)
                    realm = 1;
                else
                    realm = 0;
            end
        end
    end
   
   always @ (posedge clk)
   begin 
    if(br_type != `NOBRANCH) begin
        if(br) begin
            predicted_pc_table[PC_EX[9:0]] <= br_target;
            state_bit[PC_EX[9:0]] <= 1'b1; 
        end
    end
    end

    always @ (*)
    begin
        taken_btb = 0;
        if(state_bit[PC_IF[9:0]] == 1'b1) begin
            predicted_pc = predicted_pc_table[PC_IF[9:0]];
            taken_btb = 1;
            pc_old = PC_IF;
        end
    end

    /*bht*/

    always @ (posedge clk)
    begin
        if(br_type != `NOBRANCH) begin
            if(!br) begin
                case(state[PC_EX[9:0]])
                    NOT_TAKEN_OK: state[PC_EX[9:0]] <= NOT_TAKEN_OK;
                    NOT_TAKEN: state[PC_EX[9:0]] <= NOT_TAKEN_OK;
                    TAKEN: state[PC_EX[9:0]]<= NOT_TAKEN;
                    TAKEN_OK: state[PC_EX[9:0]] <= TAKEN; 
                endcase
            end
            else begin
                case(state[PC_EX[9:0]])
                    NOT_TAKEN_OK: state[PC_EX[9:0]]<= NOT_TAKEN;
                    NOT_TAKEN: state[PC_EX[9:0]] <= TAKEN;
                    TAKEN: state[PC_EX[9:0]]<= TAKEN_OK;
                    TAKEN_OK: state[PC_EX[9:0]] <= TAKEN_OK;
                endcase
            end
     end 
    end

    always @ (*)
    begin
        taken_bht = 0;
        if(state[PC_IF[9:0]][1] == 1'b1) begin
            taken_bht = 1;
        end
    end
    
    always @ (posedge clk)
    begin
        if(br_type != `NOBRANCH) begin
            total_count++;
            if(!realm)
                miss_count++;
            else
                hit_count++;
        end
    end

endmodule
