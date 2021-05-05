`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Data Extend
// Tool Versions: Vivado 2017.4.1
// Description: Data Extension module
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  将Cache中Load的数据扩展成32�??
// 输入
    // data              cache读出的数�??
    // addr              字节地址
    // load_type         load的类�??
    // ALU_func          运算类型
// 输出
    // dealt_data        扩展完的数据
// 实验要求
    // 补全模块


`include "Parameters.v"

module DataExtend(
    input wire [31:0] data,
    input wire [1:0] addr,
    input wire [2:0] load_type,
    output reg [31:0] dealt_data
    );

    // TODO: Complete this module
    always @ (*)
    begin
        case(load_type)
            `NOREGWRITE: dealt_data = 32'b0;       //	Do not write Register
            `LB:   //	load 8bit from Mem then signed extended to 32bit
                case(addr)
                    2'd0: dealt_data = {{25{data[7]}}, data[6:0]};
                    2'd1: dealt_data = {{25{data[15]}}, data[14:8]};
                    2'd2: dealt_data = {{25{data[23]}}, data[22:16]};
                    2'd3: dealt_data = {{25{data[31]}}, data[30:24]};
                endcase
            `LH:     //	load 16bit from Mem then signed extended to 32bit
                case(addr)
                    2'd0: dealt_data = {{17{data[15]}}, data[14:0]};
                    2'd2: dealt_data = {{17{data[31]}}, data[30:16]};
                    default: dealt_data = 32'd0;
                endcase
            `LW: dealt_data = data;	//	write 32bit to Register
            `LBU:       //	load 8bit from Mem then unsigned extended to 32bit
                case(addr)
                    2'd0: dealt_data = {24'd0, data[7:0]};
                    2'd1: dealt_data = {24'd0, data[15:8]};
                    2'd2: dealt_data = {24'd0, data[23:16]};
                    2'd3: dealt_data = {24'd0, data[31:24]};
                endcase
            `LHU:       //	load 16bit from Mem then unsigned extended to 32bit
                case(addr)
                    2'd0: dealt_data = {16'd0, data[15:0]};
                    2'd2: dealt_data = {16'd0, data[31:16]};
                    default: dealt_data = 32'd0;
                endcase
            default: dealt_data = 32'b0;
        endcase
    end

endmodule