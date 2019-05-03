module syncgen_test;

localparam STEP = 8;    //125MHz
localparam CLKNUM = (112*507+12000)*5;

reg CLK;
reg RST;
wire PCK;
wire HS;
wire VS;

wire [9:0]HCNT;
wire [9:0]VCNT;
wire ENABLE_MEM;

syncgen syncgen(
    .CLK(CLK),
    .RST(RST),
    .PCK(PCK),
    .HS(HS),
    .VS(VS),
    .HCNT(HCNT),
    .VCNT(VCNT),
    .ENABLE_MEM(ENABLE_MEM)
);

//1CK = 1ns
always begin
    CLK =0; #(STEP/2);
    CLK =1; #(STEP/2);
end

initial begin
    RST = 0;
    #(STEP*100) RST=1;
    #(STEP*100) RST=0;
    #(STEP*CLKNUM);
    $stop;
end

endmodule