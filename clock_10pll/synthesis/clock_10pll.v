// clock_10pll.v

// Generated using ACDS version 13.0sp1 232 at 2013.12.08.20:16:38

`timescale 1 ps / 1 ps
module clock_10pll (
		input  wire  clk_in_clk,  //  clk_in.clk
		input  wire  reset_reset, //   reset.reset
		output wire  clk_out_clk  // clk_out.clk
	);

	clock_10pll_altpll_0 altpll_0 (
		.clk       (clk_in_clk),  //       inclk_interface.clk
		.reset     (reset_reset), // inclk_interface_reset.reset
		.read      (),            //             pll_slave.read
		.write     (),            //                      .write
		.address   (),            //                      .address
		.readdata  (),            //                      .readdata
		.writedata (),            //                      .writedata
		.c0        (clk_out_clk), //                    c0.clk
		.areset    (),            //        areset_conduit.export
		.locked    (),            //        locked_conduit.export
		.phasedone ()             //     phasedone_conduit.export
	);

endmodule
