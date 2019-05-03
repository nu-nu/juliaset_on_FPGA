module julia_calc(
    input signed [31:0]ZR,
    input signed [31:0]ZI,
    input signed  [31:0]CR,
    input signed  [31:0]CI,

    input CALC_START,
    input CLK,
    input RST,

    output signed [31:0]CALC_NUM,
    output CALC_END
);

localparam mul = 8192;  //少数は計算できないので、mul倍して結果をmulで割る
localparam limit = 100;
reg [11:0] i;

//計算終了のしきい値(ルート実装が手間なので2乗のまま)
localparam target = (2*2)*mul*mul;

reg calc_end =0;
reg signed [31:0]result =0;

reg signed [31:0]dbg;

assign CALC_NUM = result;
assign CALC_END = calc_end;

function [31:0]abs;
    input [31:0]R1;
    input [31:0]I1;

    integer r,i;
    begin
        r = R1*R1;
        i = I1*I1;

        abs = r+i;
    end
endfunction

reg signed [31:0] znextr;
reg signed [31:0] znexti;

reg [3:0] state;
localparam STATE_CALC = 4'b0001;
localparam STATE_END  = 4'b1000;

always @(posedge CALC_START) begin
    state <= STATE_CALC;

    i <= 0;
    znextr <= ZR;
    znexti <= ZI;
    calc_end <= 0;
end

always @(posedge CLK) begin
    if (RST)begin
        state <= STATE_END;
    end else if (state == STATE_CALC)begin
        dbg <= abs(znextr,znexti);

        if(i<limit && abs(znextr,znexti)<target) begin
            znextr <= (((znextr**2)-(znexti**2)))/mul +CR;
            znexti <= (2*(znextr*znexti))/mul +CI;
            i = i+1;
        end else begin
            state <= STATE_END;

            znextr <= znextr;
            znexti <= znexti;
            calc_end <= 1;
            result <= i;
        end
    end
end

endmodule // julia_calc