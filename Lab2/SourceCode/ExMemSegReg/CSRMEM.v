`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: Reg2_MEM
// Module Name: Register 2 Seg Reg
// Tool Versions: Vivado 2017.4.1
// Description: Register 2 Seg Reg for EX\MEM
// 
//////////////////////////////////////////////////////////////////////////////////


//  功能说明
    // EX\MEM的寄存器段寄存器
// 输入
    // clk               时钟信号
    // csr_EX            csr寄存器内容(可能是转发后的)
    // bubbleM           MEM阶段的bubble信号
    // flushM            MEM阶段的flush信号
// 输出
    // csr_MEM           传给下一流水段的csr寄存器内容
// 实验要求  
    // 无需修改


module CSR_MEM(
    input wire clk, bubbleM, flushM,
    input wire [31:0] csr_EX,
    output reg [31:0] csr_MEM
    );

    initial csr_MEM = 0;
    
    always@(posedge clk)
        if (!bubbleM) 
        begin
            if (flushM)
                csr_MEM <= 0;
            else 
                csr_MEM <= csr_EX;
        end
    
endmodule