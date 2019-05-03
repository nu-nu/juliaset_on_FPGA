module test_julia_calc;

localparam STEP = 8;    //125MHz
localparam CLKNUM = (112*507+12000)*5;

reg CLK;
reg signed [31:0]ZR;
reg signed [31:0]ZI;
reg signed [31:0]CR;
reg signed [31:0]CI;
reg RST;

reg CALC_START;

wire signed [31:0]CALC_NUM;
wire CALC_END;

julia_calc julia_calc(
    .CLK(CLK),
    .ZR(ZR),
    .ZI(ZI),
    .CR(CR),
    .CI(CI),

    .CALC_START(CALC_START),
    .RST(RST),

    .CALC_NUM(CALC_NUM),
    .CALC_END(CALC_END)
);

//1CK = 1ns
always begin
    CLK =0; #(STEP/2);
    CLK =1; #(STEP/2);
end

localparam mul = 8192;

integer i,j;

integer fp;

initial begin
    fp = $fopen("img.raw","wb");

    RST=1;
    #(STEP*10);
    RST=0;
    #(STEP*10);

    for (j = 0;j<96 ;j=j+1 ) begin
        for (i = 0;i<400 ;i=i+1 ) begin
            ZR=(i*2-400)/400.0*mul*1;
            ZI=(j*2-96)/96.0*mul*1;
            CR=-0.04*mul;
            CI=-0.695*mul;
            CALC_START=1;
            #(STEP);
            while(~CALC_END)begin
                #(STEP);
            end

            $fwrite(fp,"%c",CALC_NUM[7:0]);
            $fwrite(fp,"%c",8'h00);
            $fwrite(fp,"%c",8'h00);

            CALC_START=0;
            #(STEP*1);
        end
    end
    $fclose(fp);
    $finish;
end

endmodule // test_julia_calc
