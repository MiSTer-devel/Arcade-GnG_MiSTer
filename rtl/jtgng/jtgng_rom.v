/*  This file is part of JT_GNG.
    JT_GNG program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT_GNG program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT_GNG.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 27-10-2017 */

module jtgng_rom(
    input           rst,
    input           clk,
    input           cen6,
    input   [ 2:0]  H,
    input   [12:0]  char_addr,
    input   [16:0]  main_addr,
    input   [14:0]  snd_addr,
    input   [15:0]  obj_addr,
    input   [14:0]  scr_addr,

    output      [ 7:0]  main_dout,
    output      [ 7:0]  snd_dout,
    output      [15:0]  obj_dout,
    output  reg [15:0]  char_dout,
    output  reg [23:0]  scr_dout,

    // ROM load 
    input           romload_clk,
    input           romload_wr,
    input   [18:0]  romload_addr,
    input    [7:0]  romload_data
);

// cpu  00000 14000
// chr  14000 04000
// snd  18000 08000
// scr1 20000 08000
// scr2 28000 08000
// scr3 30000 08000
// ---- 38000 08000
// obj1 40000 10000
// obj2 50000 10000


jtgng_dual_clk_ram #(8,17,81920) main_ram
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[16:0]),
    .data_a(romload_data),
    .we_a(romload_wr && !romload_addr[18:17]),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(main_addr),
    .q_b(main_dout)
); 

jtgng_dual_clk_ram #(8,15) snd_ram
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[14:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:15] == 'b0011)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(snd_addr),
    .q_b(snd_dout)
); 

wire [15:0] char_d;
jtgng_dual_clk_ram #(8,13) chr_ram1
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[13:1]),
    .data_a(romload_data),
    .we_a(romload_wr && romload_addr[0] && (romload_addr[18:14]==5'b00101)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(char_addr),
    .q_b(char_d[7:0])
);
jtgng_dual_clk_ram #(8,13) chr_ram2
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[13:1]),
    .data_a(romload_data),
    .we_a(romload_wr && ~romload_addr[0] && (romload_addr[18:14]==5'b00101)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(char_addr),
    .q_b(char_d[15:8])
);
always @(posedge clk) if (cen6 && !H) char_dout <= char_d;


wire [23:0] scr_d;
jtgng_dual_clk_ram #(8,15) scr_ram1
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[14:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:15] == 4'b0100)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(scr_addr),
    .q_b(scr_d[15:8])
);
jtgng_dual_clk_ram #(8,15) scr_ram2
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[14:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:15] == 4'b0101)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(scr_addr),
    .q_b(scr_d[7:0])
);
jtgng_dual_clk_ram #(8,15) scr_ram3
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[14:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:15] == 4'b0110)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(scr_addr),
    .q_b(scr_d[23:16])
);
always @(posedge clk) if (cen6 && !H) scr_dout = scr_d;


jtgng_dual_clk_ram #(8,16,49152) obj_ram1
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[15:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:16] == 3'b100)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(obj_addr),
    .q_b(obj_dout[15:8])
);
jtgng_dual_clk_ram #(8,16,49152) obj_ram2
(
    .clka(romload_clk),
    .clka_en(1),
    .addr_a(romload_addr[15:0]),
    .data_a(romload_data),
    .we_a(romload_wr && (romload_addr[18:16] == 3'b101)),

    .clkb(clk),
    .clkb_en(1),
    .addr_b(obj_addr),
    .q_b(obj_dout[7:0])
);


endmodule // jtgng_rom
