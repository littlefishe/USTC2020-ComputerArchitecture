`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Hazard Module
// Tool Versions: Vivado 2017.4.1
// Description: Hazard Module is used to control flush, bubble and bypass
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  识别流水线中的数据冲突，控制数据转发，和flush、bubble信号
// 输入
    // rst               CPU的rst信号
    // reg1_srcD         ID阶段的源reg1地址
    // reg2_srcD         ID阶段的源reg2地址
    // reg1_srcE         EX阶段的源reg1地址
    // reg2_srcE         EX阶段的源reg2地址
    // reg_dstE          EX阶段的目的reg地址
    // reg_dstM          MEM阶段的目的reg地址
    // reg_dstW          WB阶段的目的reg地址
    // br                是否branch
    // jalr              是否jalr
    // jal               是否jal
    // src_reg_en        指令中的源reg1和源reg2地址是否有效
    // wb_select         写回寄存器的值的来源（Cache内容或�?�ALU计算结果�????????
    // reg_write_en_MEM  MEM阶段的寄存器写使能信�????????
    // reg_write_en_WB   WB阶段的寄存器写使能信�????????
    // alu_src1          ALU操作�????????1来源�????????0表示来自reg1�????????1表示来自PC
    // alu_src2          ALU操作�????????2来源�????????2’b00表示来自reg2�????????2'b01表示来自reg2地址�????????2'b10表示来自立即�????????
// 输出
    // flushF            IF阶段的flush信号
    // bubbleF           IF阶段的bubble信号
    // flushD            ID阶段的flush信号
    // bubbleD           ID阶段的bubble信号
    // flushE            EX阶段的flush信号
    // bubbleE           EX阶段的bubble信号
    // flushM            MEM阶段的flush信号
    // bubbleM           MEM阶段的bubble信号
    // flushW            WB阶段的flush信号
    // bubbleW           WB阶段的bubble信号
    // op1_sel           ALU的操作数1来源�????????2'b00表示来自ALU转发数据�????????2'b01表示来自write back data转发�????????2'b10表示来自PC�????????2'b11表示来自reg1
    // op2_sel           ALU的操作数2来源�????????2'b00表示来自ALU转发数据�????????2'b01表示来自write back data转发�????????2'b10表示来自reg2地址�????????2'b11表示来自reg2或立即数
    // reg2_sel          reg2的来�????????
// 实验要求
    // 补全模块


module HarzardUnit(
    input wire rst,
    input wire miss,  //cache
    input wire [4:0] reg1_srcD, reg2_srcD, reg1_srcE, reg2_srcE, reg_dstE, reg_dstM, reg_dstW,
    input wire [11:0] csr_srcE, csr_dstM,
    input wire br, jalr, jal,
    input wire [1:0] src_reg_en,
    input wire [1:0] wb_select,
    input wire reg_write_en_MEM,
    input wire reg_write_en_WB,
    input wire alu_src1,
    input wire [1:0] alu_src2,
    input wire rd_req_EX, rd_req_MEM,
    output reg flushF, bubbleF, flushD, bubbleD, flushE, bubbleE, flushM, bubbleM, flushW, bubbleW,
    output reg [1:0] op1_sel, op2_sel, reg2_sel,
    output reg wb_src
    );

    // TODO: Complete this module

    // 假定WB能先于ID执行
    always @ (*)
    begin
        flushF = 0;
        bubbleF = 0;
        flushD = 0;
        bubbleD = 0; 
        flushE = 0;
        bubbleE = 0;
        flushM = 0;
        bubbleM = 0;
        flushW = 0;
        bubbleW = 0;
        op1_sel = (alu_src1 == 1)? 2'h2 : 2'h3;
        op2_sel = 2'h3;
        reg2_sel = 2'h2;
        wb_src = 0;
        if(rst)
        begin
            flushF = 1;
            flushD = 1;
            flushE = 1;
            flushM = 1;
            flushW = 1;
        end
        else
        begin
            if(miss) begin
                bubbleF = 1;
                bubbleD = 1;
                bubbleE = 1;
                bubbleM = 1;
                bubbleW = 1;
            end 
            if(rd_req_EX == 1'b1/*wb_select == 2'b1*/ && (reg1_srcD != 0 || reg2_srcD != 0))
            begin
                if((reg1_srcD == reg_dstE || reg2_srcD == reg_dstE) /*&& reg_write_en_WB*/ /*&& src_reg_en != 2'b00*/) 
                begin
                    bubbleF = 1;
                    bubbleD = 1;
                    flushE = 1;
                    //bubbleE = 1;
                 //   bubbleM = 1;
                end
            end
            // else begin
                  // csr
                if(src_reg_en[1] == 1 && csr_srcE == csr_dstM && reg_write_en_WB)
                begin
                    wb_src = 1;
                end
                // #4 br/j
                if(jalr || br)
                begin
                //    flushF = 1;
                    flushD = 1;
                    flushE = 1;
                end
    
                if(jal)
                //    flushF = 1;
                    flushD = 1;
            
            // end

            // #1 LW + others, stall (select from cache)
            
            
            // #2
            //else
           // begin
            if(src_reg_en[1] == 1 && reg1_srcE != 0)
            begin
                if(reg1_srcE == reg_dstM && reg_write_en_MEM) begin
                        op1_sel = 2'b00;
                end
                else if(reg1_srcE == reg_dstW && reg_write_en_WB)
                    op1_sel = 2'b01;
            end

            if(src_reg_en[0] == 1 && reg2_srcE != 0)
            begin
                if(reg2_srcE == reg_dstM && reg_write_en_MEM)                 
                begin
                        if(alu_src2 == 2'b00)
                             op2_sel = 2'b00;
                        else
                            reg2_sel = 2'b00;
                end
                
                else if(reg2_srcE == reg_dstW && reg_write_en_WB)
                begin
                    if(alu_src2 == 2'b00)
                        op2_sel = 2'b01;
                    else
                        reg2_sel = 2'b01;
                end
            end
           // end
                
            // #3 WB阶段�???????
                
        end
    end

endmodule