`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: szp
// 
// Design Name: RV32I Core
// Module Name: CSR Register
// Tool Versions: Vivado 2019.1
// Description: CSR Register File
// 
//////////////////////////////////////////////////////////////////////////////////


//  功能说明
    //  CSR寄存器，提供读写端口（同步写，异步读�??
    //  时钟下降沿写�??
    //  0号寄存器的�?�始终为0
// 输入
    // clk               时钟信号
    // rst               寄存器重置信�??
    // write_en          寄存器写使能
    // addr              reg读地�??
    // wb_addr           写回地址
    // wb_data           写回数据
// 输出
    // rd_reg            reg读数�??


module CSRFile(
    input wire clk,
    input wire rst,
    input wire write_en,
    input wire [11:0] addr, wb_addr, debug_reg_addr, //
    input wire [31:0] wb_data,
    output wire [31:0] rd_reg, debug_out_reg //
    );

    reg [31:0] reg_file[31:0];
    integer i;

    // init register file
    initial
    begin
        for(i = 0; i < 32; i = i + 1) 
            reg_file[i][31:0] <= 32'b1;
    end

    // write in clk negedge, reset in rst posedge
    // if write register in clk posedge,
    // new wb data also write in clk posedge,
    // so old wb data will be written to register
    always@(negedge clk or posedge rst) 
    begin 
        if (rst)
            for (i = 0; i < 32; i = i + 1) 
                reg_file[i][31:0] <= 32'b1;
        else if(write_en)
            reg_file[wb_addr] <= wb_data;   
    end

    // read data changes when address changes
    assign rd_reg = reg_file[addr];
    assign debug_out_reg = reg_file[debug_reg_addr]; //


endmodule
