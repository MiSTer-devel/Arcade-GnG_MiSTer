//============================================================================
//  Arcade: Ghosts'n'Goblins  by Jose Tejada Gomez. Twitter: @topapate 
//
//  Port to MiSTer
//  Copyright (C) 2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================


module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output [11:0] VIDEO_ARX,
	output [11:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	// Use framebuffer from DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of 16 bytes.
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,    // 1 - signed audio samples, 0 - unsigned

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT
);

assign VGA_F1    = 0;
assign VGA_SCALER= 0;
assign USER_OUT  = '1;
assign LED_USER  = ioctl_download;
assign LED_DISK  = 0;
assign LED_POWER = 0;

assign {FB_PAL_CLK, FB_FORCE_BLANK, FB_PAL_ADDR, FB_PAL_DOUT, FB_PAL_WR} = '0;

wire [1:0] ar = status[20:19];


assign VIDEO_ARX =  (!ar) ? ( 8'd4) : (ar - 1'd1);
assign VIDEO_ARY =  (!ar) ? ( 8'd3) : 12'd0;


`include "build_id.v" 
localparam CONF_STR = {
	"A.GnG;;", 
	"-;",
	"H0OJK,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;", 
	"-;",
	"OF,Test mode,No,Yes;",
	"O89,Lives,3,4,5,7;",
	"OAB,+1 Life,20K 70K Every 70K,30K 80K Every 80K,20K and 80K Only,30K and 80K Only;",
	"OCD,Difficulty,Normal,Easy,Hard,Very Hard;",
	"H1OE,Invulnerable,No,Yes;",
	"-;",
	"O6,PSG,Enabled,Disabled;",
	"O7,FM,Enabled,Disabled;",
	"-;",
	"R0,Reset;",
	"J1,Fire,Jump,Start 1P,Start 2P,Coin;",
	"jn,A,B,Start,Select,R;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire clk_sys,clk_12,clk_vid;

pll pll
(
	.refclk(CLK_50M),
	.outclk_0(clk_vid),
	.outclk_1(clk_sys),
	.outclk_2(clk_12)
);

reg ce_6, ce_3, ce_1p5;
always @(posedge clk_12) begin
	reg [2:0] div;
	
	div <= div + 1'd1;
	ce_6   <= !div[0:0];
	ce_3   <= !div[1:0];
	ce_1p5 <= !div[2:0];
end

reg ce_pix;
always @(posedge clk_sys) begin
	reg [1:0] div;
	
	div <= div + 1'd1;
	ce_pix <= !div[1:0];
end

///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;
wire        forced_scandoubler;
wire        direct_video;

wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

wire  [8:0] joy_0, joy_1;

wire [21:0] gamma_bus;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.status_menumask({~inv_ena,direct_video}),
	.forced_scandoubler(forced_scandoubler),
	.gamma_bus(gamma_bus),
	.direct_video(direct_video),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),

	.joystick_0(joy_0),
	.joystick_1(joy_1)
);
wire [9:0] joy = joy_0 | joy_1;

wire m_up     = joy[3];
wire m_down   = joy[2];
wire m_left   = joy[1];
wire m_right  = joy[0];
wire m_fire   = joy[4];
wire m_jump   = joy[5];
wire m_pause  = joy[9];

wire m_start1 = joy[6];
wire m_start2 = joy[7];
wire m_coin   = joy[8];

reg pause = 0;
always @(posedge clk_sys) begin
	reg old_pause;
	
	old_pause <= m_pause;
	if(~old_pause & m_pause) pause <= ~pause;
	if(status[0] | buttons[1]) pause <= 0;
end

///////////////////////////////////////////////////////////////////


wire [3:0] R,G,B;
wire HSync,VSync,HBlank,VBlank;

wire [1:0]    dip_level = ~status[13:12];
wire [1:0]    dip_lives = ~status[9:8];
wire [1:0]    dip_bonus = ~status[11:10];
wire          dip_test  = ~status[15];

arcade_video #(256,12) arcade_video
(
	.*,
	.clk_video(clk_vid),
	.HBlank(~HBlank),
	.VBlank(~VBlank),
	.RGB_in({R,G,B}),
	.fx(status[5:3])
);

jtgng_game game
(
	.rst(RESET | ioctl_download),
	.soft_rst(status[0] | buttons[1]),
	.clk(clk_12),
	.cen12(1),
	.cen6(ce_6),
	.cen3(ce_3),
	.cen1p5(ce_1p5),
	.red(R),
	.green(G),
	.blue(B),
	.LHBL(HBlank),
	.LVBL(VBlank),
	.HS(HSync),
	.VS(VSync),

	.joystick1(~{m_jump,m_fire,m_up,m_down,m_left,m_right}),
	.joystick2(~{m_jump,m_fire,m_up,m_down,m_left,m_right}),
	.start_button(~{m_start2,m_start1}),
	.coin_input(~{1'b0,m_coin}),

	.romload_clk(clk_sys),
	.romload_wr(ioctl_wr),
	.romload_addr(ioctl_addr[18:0]),
	.romload_data(ioctl_dout),

	.enable_char(1),
	.enable_scr(1),
	.enable_obj(1),

//	.dipsw({~inv_ena | ~status[14],~status[13:12],~status[11:10],1'b0,~status[9:8],4'h5,{4{status[15]}}}),
    // DIP switches
	.dip_pause      ( ~pause     ),
	.dip_inv        ( ~inv_ena | ~status[14] ),
	.dip_lives      ( dip_lives  ),
	.dip_level      ( dip_level  ),
	.dip_bonus      ( dip_bonus  ),
	.dip_game_mode  ( dip_test   ),
	.dip_upright    ( 1'b1       ),
	.dip_attract_snd( 1'b0       ), // 0 for sound

	.enable_psg(~status[6]),
	.enable_fm(~status[7]),
	.ym_snd(AUDIO_L)
);

assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 1;


reg inv_ena = 0;
always @(posedge clk_sys) begin
	reg [3:0] flg;
	if(ioctl_wr) begin
		if(ioctl_addr == 0) flg[0] <= (ioctl_dout == 'h10);
		if(ioctl_addr == 1) flg[1] <= (ioctl_dout == 'h83);
		if(ioctl_addr == 2) flg[2] <= (ioctl_dout == 'h00);
		if(ioctl_addr == 3) flg[3] <= (ioctl_dout == 'h80);
	end
	
	inv_ena <= &flg;
end


endmodule
