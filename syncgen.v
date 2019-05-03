module syncgen(
    input               CLK,
    input               RST,
    output  reg         PCK,
    output  reg         HS,
    output  reg         VS,
    output  reg         ENABLE_MEM,
    output  reg [9:0]   HCNT,
    output  reg [9:0]   VCNT
);
`include "param.vh"

//終端まで行ったらON
wire vcntend = (VCNT == VPERIOD+10'd1);
wire hcntend = (HCNT == HPERIOD+10'd1);

reg[6:0] PCK_cnt;
wire PCK_cntend = (PCK_cnt == 7'd73);   //30fps用

always @(posedge CLK) begin
    ENABLE_MEM <=   (VCNT < VFRONT)? 1:
                    (HCNT < HFRONT)? 1:0;
    HS <= hcntend;
    VS <= vcntend;
end

always @(posedge CLK)begin
    if(RST) begin
        PCK_cnt <= 7'd0;
        PCK <= 0;
    end else begin 
        if(PCK_cntend)begin
            PCK_cnt <= 7'd0;
            PCK <= ~PCK;
        end else
            PCK_cnt <= PCK_cnt + 7'd1;
    end
end

always @(posedge PCK or posedge RST) begin
    if(RST)begin
        HCNT = 10'd0;
    end else if(PCK)begin
        if(hcntend | vcntend)
            HCNT <= 10'd0;
        else
            HCNT <= HCNT + 10'd1;
    end
end

always @(posedge PCK or posedge RST) begin
    if(RST)begin
        VCNT = 10'd0;
    end else if(PCK)begin
        if(vcntend)
            VCNT <= 10'd0;
        else if(hcntend)
            VCNT <=VCNT + 10'd1;
    end
end

endmodule // syncgen
