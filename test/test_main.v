module test_main;

localparam STEP = 8;    //125MHz
localparam CLKNUM = 4200000; //30fps時�??��1画面ち?��??��??��?

reg CLK;
reg RST;
reg PCK_before;

wire PCK;
wire HS;
wire VS;
wire [5:0]R;
wire [5:0]G;
wire [5:0]B;

main main(
    .CLK(CLK),
    .RST(RST),

    .PCK(PCK),
    .HS(HS),
    .VS(VS),
    .R(R),
    .G(G),
    .B(B)
);

always begin
    CLK =0; #(STEP/2);
    CLK =1; #(STEP/2);
end

integer fp;

initial begin
    fp = $fopen("main_img.raw","wb");

    RST=1;
    #(STEP*10);
    RST=0;
    #(STEP*10);

    PCK_before =0;
    while (VS == 0)begin
        #(STEP);
    end
    #(STEP*150);
    while (VS == 0)begin
        if(PCK != PCK_before && PCK==1)begin
            $fwrite(fp,"%c", 8'd00 | (R<<2));
            $fwrite(fp,"%c", 8'h00 | (G<<2));
            $fwrite(fp,"%c", 8'h00 | (B<<2));
        end
        PCK_before = PCK;
        #(STEP);
    end

    $fclose(fp);
    $finish;
end

initial begin
end

endmodule // test_julia_calc
