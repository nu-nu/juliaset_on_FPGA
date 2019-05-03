module main(
    input CLK,
    input RST,

    output PCK,
    output HS,
    output VS,
    output reg [5:0]R,
    output reg [5:0]G,
    output reg [5:0]B
);

`include "param.vh"

wire ENABLE_MEM;
wire [9:0]  HCNT;
wire [9:0]  VCNT;

syncgen syncgen(
    .CLK(CLK),
    .RST(RST),
    .PCK(PCK),
    .HS(HS),
    .VS(VS),
    .ENABLE_MEM(ENABLE_MEM),
    .HCNT(HCNT),
    .VCNT(VCNT)
);

julia_calc julia_calc1(
    .CLK(CLK),
    .ZR(ZR[0]),
    .ZI(ZI[0]),
    .CR(CR[0]),
    .CI(CI[0]),

    .CALC_START(CALC_START[0]),
    .RST(RST),

    .CALC_NUM(CALC_NUM[0]),
    .CALC_END(CALC_END[0])
);

(* RAM_STYLE="BLOCK" *) reg [17:0]mem[1:0][HWIDTH:0];
wire [1:0]mem_select;

assign mem_select = VCNT[0];

always @(posedge PCK) begin
    if((HCNT >= HFRONT && HCNT <= HPERIOD) && (VCNT >= VFRONT && VCNT <= VPERIOD))begin
        R <= mem[mem_select][HCNT - HFRONT][17:12];
        G <= mem[mem_select][HCNT - HFRONT][11:6];
        B <= mem[mem_select][HCNT - HFRONT][5:0];
    end else begin
        R <= 6'h00;
        G <= 6'h00;
        B <= 6'h00;
    end
end

reg signed [31:0]ZR[1:0];
reg signed [31:0]ZI[1:0];
reg signed [31:0]CR[1:0];
reg signed [31:0]CI[1:0];

reg [9:0] calc_x;

reg CALC_START[1:0];
wire CALC_END[1:0];

wire signed [31:0]CALC_NUM[1:0];

localparam STATE_WAIT           = 4'd1;
localparam STATE_SETTING        = 4'd2;
localparam STATE_CALC           = 4'd3;
localparam STATE_JUDGE_CONTINUE = 4'd4;

reg [3:0] state;

localparam MUL = 8192;

integer i,j,k;
always @(posedge CLK) begin
    if (RST)begin
        for (i = 0;i<= 1; i=i+1) begin
            for (j = 0;j<= HWIDTH; j=j+1) begin
                mem[i][j] <= 17'h00000;
            end
        end

        for (k = 0;k< 2; k=k+1) begin
            CALC_START[k] <=0;
            ZR[k] <= 0;
            ZI[k] <= 0;
            CR[k] <= 0;
            CI[k] <= 0;
        end
        calc_x <= 0;

        state <= STATE_WAIT;
    end else begin
        if(state == STATE_WAIT)begin
            if(HS == 1)begin
                state <= STATE_SETTING;
            end
        end else if(state == STATE_SETTING)begin
            if(VCNT < VFRONT-1)begin
                state <= STATE_WAIT;
            end else begin
                ZR[0] <= (calc_x*MUL)/HWIDTH;
                ZI[0] <= (((VCNT-VFRONT)+1)*MUL)/VWIDTH;
                CR[0] <= -0.04*MUL;
                CI[0] <= -0.695*MUL;
                CALC_START[0] <= 1;

                state <= STATE_CALC;
            end
        end else if(state == STATE_CALC && CALC_END[0] == 1)begin
            CALC_START[0] <= 0;

            //非表示側を更新
            mem[~(VCNT[0])][calc_x] <= {CALC_NUM[0][7:2],6'h00,6'h00};

            //count up
            if(calc_x < HWIDTH-1)begin
                calc_x <= calc_x + 1;
            end else begin
                calc_x <= 0;
            end
            state <= STATE_JUDGE_CONTINUE;
        end else if(state == STATE_JUDGE_CONTINUE)begin
            if(calc_x == 0)begin
                //1画面完了したら
                state <= STATE_WAIT;
            end else begin
                state <= STATE_SETTING;
            end
        end
    end
end

endmodule // main