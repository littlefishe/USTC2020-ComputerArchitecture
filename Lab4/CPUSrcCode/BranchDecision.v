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
    // reg1               寄存�??1
    // reg2               寄存�??2
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
    output reg br
    );
    
    reg [20: 0] miss_count, total_count, hit_count;
    
    initial begin
        miss_count = 0;
        total_count = 0;
        hit_count = 0;
    end

    // TODO: Complete this module
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
    end
    
    always @ (posedge clk)
    begin
        if(br_type != `NOBRANCH) begin
            total_count++;
            if(br)
                miss_count++;
            else
                hit_count++;
        end
    end

endmodule
