module Test;
    integer i;


    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, vr);
    end

endmodule
