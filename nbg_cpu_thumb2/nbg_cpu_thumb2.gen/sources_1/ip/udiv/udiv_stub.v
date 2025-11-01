// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2.2 (win64) Build 6060944 Thu Mar 06 19:10:01 MST 2025
// Date        : Fri Apr 11 22:14:24 2025
// Host        : study-box running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/nibao/Desktop/vivado/nbg_cpu_16/nbg_cpu_16.gen/sources_1/ip/udiv/udiv_stub.v
// Design      : udiv
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "udiv,div_gen_v5_1_23,{}" *) (* core_generation_info = "udiv,div_gen_v5_1_23,{x_ipProduct=Vivado 2024.2.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=div_gen,x_ipVersion=5.1,x_ipCoreRevision=23,x_ipLanguage=VERILOG,x_ipSimLanguage=VERILOG,C_XDEVICEFAMILY=zynq,C_HAS_ARESETN=0,C_HAS_ACLKEN=0,C_LATENCY=35,ALGORITHM_TYPE=1,DIVISOR_WIDTH=32,DIVIDEND_WIDTH=32,SIGNED_B=0,DIVCLK_SEL=8,FRACTIONAL_B=0,FRACTIONAL_WIDTH=32,C_HAS_DIV_BY_ZERO=0,C_THROTTLE_SCHEME=3,C_TLAST_RESOLUTION=0,C_HAS_S_AXIS_DIVISOR_TUSER=0,C_HAS_S_AXIS_DIVISOR_TLAST=0,C_S_AXIS_DIVISOR_TDATA_WIDTH=32,C_S_AXIS_DIVISOR_TUSER_WIDTH=1,C_HAS_S_AXIS_DIVIDEND_TUSER=0,C_HAS_S_AXIS_DIVIDEND_TLAST=0,C_S_AXIS_DIVIDEND_TDATA_WIDTH=32,C_S_AXIS_DIVIDEND_TUSER_WIDTH=1,C_M_AXIS_DOUT_TDATA_WIDTH=64,C_M_AXIS_DOUT_TUSER_WIDTH=1}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "div_gen_v5_1_23,Vivado 2024.2.2" *) 
module udiv(aclk, s_axis_divisor_tvalid, 
  s_axis_divisor_tready, s_axis_divisor_tdata, s_axis_dividend_tvalid, 
  s_axis_dividend_tready, s_axis_dividend_tdata, m_axis_dout_tvalid, m_axis_dout_tdata)
/* synthesis syn_black_box black_box_pad_pin="s_axis_divisor_tvalid,s_axis_divisor_tready,s_axis_divisor_tdata[31:0],s_axis_dividend_tvalid,s_axis_dividend_tready,s_axis_dividend_tdata[31:0],m_axis_dout_tvalid,m_axis_dout_tdata[63:0]" */
/* synthesis syn_force_seq_prim="aclk" */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_mode = "slave aclk_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF S_AXIS_DIVIDEND:S_AXIS_DIVISOR:M_AXIS_DOUT, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 1000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVISOR TVALID" *) (* x_interface_mode = "slave S_AXIS_DIVISOR" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_DIVISOR, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_divisor_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVISOR TREADY" *) output s_axis_divisor_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVISOR TDATA" *) input [31:0]s_axis_divisor_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVIDEND TVALID" *) (* x_interface_mode = "slave S_AXIS_DIVIDEND" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_DIVIDEND, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_dividend_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVIDEND TREADY" *) output s_axis_dividend_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_DIVIDEND TDATA" *) input [31:0]s_axis_dividend_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DOUT TVALID" *) (* x_interface_mode = "master M_AXIS_DOUT" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_DOUT, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_dout_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_DOUT TDATA" *) output [63:0]m_axis_dout_tdata;
endmodule
