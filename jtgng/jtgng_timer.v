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

module jtgng_timer(
    input               clk,    // 24MHz
    input               clk_en, // 6 MHz
    input               rst,
    output  reg [8:0]   V,
    output  reg [8:0]   H,
    output  reg         Hinit,
    output  reg         Vinit,
    output  reg         HS,
    output  reg         LHBL,
    output  reg         LHBL_obj,
    output  reg         VS,
    output  reg         LVBL
);

parameter obj_offset=10'd3;

//reg LHBL_short;
//reg G4_3H;  // high on 3/4 H transition
//reg G4H;    // high on 4H transition
//reg OH;     // high on 0H transition
 
// H/V counters
always @(posedge clk) begin
    if( rst ) begin
        { Hinit, H } <= 10'd0;
        V     <= 9'd250;
        Vinit <= 1'b1;
    end else if(clk_en) begin
        Hinit <= H == 9'h86;
        if( H == 9'd511 ) begin
            //Hinit <= 1'b1;
            H <= 9'd128;
            Vinit <= &V;
            V <= &V ? 9'd250 : V + 1'd1;
        end
        else begin
            //Hinit <= 1'b0;
            H <= H + 1'b1;
        end
    end
end

wire [9:0] LHBL_obj0 = 10'd135-obj_offset >= 10'd128 ? 10'd135-obj_offset : 10'd135-obj_offset+10'd512-10'd128;
wire [9:0] LHBL_obj1 = 10'd263-obj_offset;

// L Horizontal/Vertical Blanking
always @(posedge clk) 
    if( rst ) LVBL <= 1'b0;
    else if(clk_en) begin
        if( H==LHBL_obj1 ) LHBL_obj<=1'b1;
        if( H==LHBL_obj0 ) LHBL_obj<=1'b0;
        if( &H[2:0] ) begin
            LHBL <= H[8];
            if( V==9'd496 ) LVBL <= 1'b0;
            if( V==9'd271 ) LVBL <= 1'b1;
				
            if( V==9'd507 ) VS <= 1;
            if( V==9'd510 ) VS <= 0;
        end
        if (H==9'd178) HS <= 1;
        if (H==9'd206) HS <= 0;
    end

// H indicators
// always @(posedge clk) begin
//     G4H <= &H[1:0];
//     OH  <= &H[2:0];
// end
// 
// always @(posedge clk) begin
//     G4_3H <= &H[1:0];
// end

endmodule // jtgng_timer