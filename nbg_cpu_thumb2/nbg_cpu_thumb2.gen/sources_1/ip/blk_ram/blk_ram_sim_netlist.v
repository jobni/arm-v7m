// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2.2 (win64) Build 6060944 Thu Mar 06 19:10:01 MST 2025
// Date        : Thu Apr 10 23:27:47 2025
// Host        : study-box running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/nibao/Desktop/vivado/nbg_cpu_16/nbg_cpu_16.gen/sources_1/ip/blk_ram/blk_ram_sim_netlist.v
// Design      : blk_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_ram,blk_mem_gen_v8_4_10,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_10,Vivado 2024.2.2" *) 
(* NotValidForBitStream *)
module blk_ram
   (clka,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [31:0]dina;
  wire [31:0]douta;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.632725 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_ram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_ram_blk_mem_gen_v8_4_10 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Vo/CdCry+4XqWyOAGIjJkQxiiFmxV56JJA9+DRAoA73w3PX/VB2Q5+hs51IJHJDQpfz8b+RkWiDc
wzwfz369ViGuppNv4dXlNznLJnJnC7EiskELf02DdJnWWoSZpu+OHK3OSBEQ/zsd9Jo2Fo1W/rmW
MGZUU/6yH18wHS4h1Ks=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
0wk1VmWYpT58dDId4XJkh8egEYIlbnZZOGeyGy5kRkRnXHqDOWQ+oylx90YDv9xCL7Hk4eMKPCF2
m4MOF7S4hVPD0/sWpEA8P8FAe8xJ87dKWSVL4jsUlHtRrOJgD7GALPmxmP7Si18wN1nhP/Em10F8
/dLfzgj1xP3Zf5H9fEp2GcwX2TuABOVnDWshUVbBokKz/60SbCSepujD00YwhBntPBKLjT63NlmT
RTSjuWX0rpXlxj6VOXIYSdG7RSLBcpnJy64tUezG1b35R+o5DxZXCqjet77d6quzpY0zZZt9Ulht
JmIAuDRf34NavmVAN7Mtd0cnmfoh7ogGicjKvQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
F/wTwmHmqba+ezt7048nG7m9PFcFX8+e1ugB8tNrzJbpZSuJRRd6CQfWgrFM6z3Lt+Xnv27fU91W
7UPwQzlK1jnTliJBxoAq1fE2EHH6Meu6+HJfRVpgJ7fg13fbfZIfHUvNXIsh98f9heu0jLNI6weE
/vvav4FblngbAAYUgd0=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PMW8encF5gzdNpDYeC/r8ImvAQhXqmTUs6jwRDNtn48A6Ujylle4R1SCnyZkY+FJKwRrbwQYM5xZ
q0WAIHjuqQu9pP4jSz77dIgvrGNt/Jq52Ez+a8pAE/wAoX0RiMsIeHFJYKfkmGjaCqeRtGDmk3BV
9+dy4HcmsDt9Uh4xvFjdpggdkLbiE5tjHgzwTlr5njpIBBM3Mc6IQE9aae7pv8wKGZh0ty66qFAn
4S9+ebhRZxOoWu/Dy19sbR1RkcJRag8MPJw9oRctKzduV4AF5TwH1waH32OTyX1p1716Vo25yin9
+rz315JRpqTLSkZJDH0UVGxiqyJ73W6GTzGjvQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Y9dtFDZe/9fosnZUVejOdy+XS5PuLJ0yXHKg9fuNlibvaa70MDgcUmFI1aUQMIXkh/nyrlAYhEOw
ZYwLUiCgGX9gv4rJdGQtx6W5YHqEqKc6ojSRxBAaLdRpzdYB0DpW8oIbjnXFf7e1yx+LS0ZeRvga
Fh2UzEgqmwMNRgmnJM4j2rvUiRrhCjtiaXlkc9pB80ojbMz6j5O0jOYRDx8scLtA39zyl6jlHXkZ
0NhLqQuJbbWjmec6JRtGnaM5QouDbk+MW/fNkDY31kIbegNsEOLQpMNJ83TJH5kTnsHlY9l+0XJ4
tN8eHqmH3rYC3OGyXe7Fa8ZFq6ms3GQKGeMfhA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cxjMtMSESPI2+yc8BX2YuZW6C3RMyKfgTvyd4r8Gx1wWxH8i+oZbwjGEFrD70y8NIz21xljoxFEk
JmtYWVokBQDW3gKLSJSvxmzp0T6nMPTGtNrpUDalO3XojGO7PY5zxMgZP7ntyQop50FaRZncfqcN
5w5hYNWywr3sHm14iUZQvYkjfpfI/X0gHmaRZTUBwZnVc3yZYPKpIi/5HdJ0+dh3SqEErHU3sVTy
bnAyZkhEZ9ZbLjELJ9twQdIRF4MiHKefy97m/3WdDg2YAmsDhwVJqEDSQRrhJ1qxyCHTjvccibuz
u7FvVmHfh6hk1tUEJgfJBY2OFz8zJE//prc5iA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ez5C57juA3+sjvTiTimQXL3ngWJqcGkQ5hv2jVBj+qRGyMllvIQOBQlpQ+bYLkOWnTv/S8+6PSxT
jUx6SYCJfbiumC5jC3z/QW4c0ZC4XzIFAgVdN4am8yXHRSI8ApBLYsSyfpVsI2zGpgVek+1s684p
Gx2VLV1Wwf3TcgyHHu6+yizJ+IJrkFjBOqaNptlbq1bdEtVxRkNyJiuKh3hzbPmt386lGeCpCmeS
Ci/w6goqagrSZZ7CwRDpp6J+IHjwRIUheUuNWzxQKdW+FCjw9qNPCND4sELBajCtfBQzY23j6RZD
kUanS7/EEh2ctRvZ6ckx/Y0zFNJYqHo8Lc56aA==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HJCYSjhpgL6sqdTzuctiBLPlx6fhwuFI2l891REPcV2cKYvrbMCYI17hADRbvcxNH4paQ5/fmqeb
rE9BqB08LRASMx7jlAdSCYKA99cNcVMsByGT1l32kX7+Gtt27iKAIwVTu34+moPXqCCM4c6jUBzB
+UAJGBtS2wc0k+kTtXp6dCXiyjYXC2UFEDt8w9CU1qb2TXkPpgxXcfR4skit7umjdS0NxiP88l7x
PvAeoTea8Nw3NyDr9766x8Q1W1rRkuRmL+1VM37vp+BJsf6MNpeE5FNpkrhdCjc0D3dtRQVsCStO
scOhLAnzS45HjTjy9siiiNpJhXtCEr+5PWuEXVj4OC+yevy5VFcClOy11RiGXUho3zn1YnCjvFUJ
HO4BCq9TThOthuOExIiymQlqo0juTKNFELWCzlCbbJMDntY4twIW1uyY76cuBTeqq0r6SuzbelbH
iF1J/Ai1WoG1NEn6/Ld8lGm+aTPi/mRUvBbdYq6Xx0I1hJ/lrwpbbvpZ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
i2BfTRuoHRFB8ZXhJCQrSS5Kh/ofOKU6mrd8mOrx1SgmsHKu6td+g6cqGS2nIDZbr1QjP33k7Zjp
xKd5lImYtNz1lFR34XzdVY1YY4Mz0QRDBjsP/kAJr7DZAqZjrJAO3md/zSG8f5SaAh8iTo+EBM+6
afCMZ6ich+nq02odtxrZ5Uhzoa2vt9DW4DcnXj+tuoKWUoRKcWxCrh31TNiwS2b4E/El43/B29XG
FxzmoEh4GH3ZaiuU113Ld+/xkQRsMLFn1JubodEkM9sNeTHfppPAGwjUgCzk8/2hXirRJu/XaML9
VWT5S7x5yGlmti7sQnP9kzJJRUcjTTJzgE5KOQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FexSVDj1WIebhRipXI5Gh3YLSX845WpAldeuElSHB0huSoXz+Np2tkseCkkF2eCCt8CNhVExuuEr
7/KHUlFqvHa9DLpKIOLmNFWiy8Ay2iuzmmxyL/MPPn/teKD2VjFeD6ssY8l2BwKbCD73MswOuiCc
spGmyJ2i3k6JMBpL+zswzmIpKJ3j76vYQF+o5HgmDtaakOUGTD1nQNPMyZ1ZBD9AvAC9J3eY8qZS
1Wdw7OXuMZ5CZutq7JXBHnLE0i4Zgcf2nWCg+gKKgvBZXlGpEkhs30/caJ4SGThuIkRNEUsnHcfp
jA52TVN8H4BdzJH3hCTxAhB1e5lNWlKwQ+gYEw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Lu5hRxSLFQyLllOA9u5s1HixJJG7j3i4H09yHKiH8Dp26PhhohxwUADFKakrM7CdHL8s7BqigcX0
gERo4eIo8tMf2dBC9mu7P36rm9gCwpvvyiCA52BzF7pay+3P1pMoTC4HhwPNE6jjh2wytbNC11dG
Vy58tmmu3wmLHagXe6TbdJpcYT31yQaqmU4KGKa1xKkiI3FyGRm/MzXZcSfTCQjCiqGXQH1Lnapo
2W3GdrN+nv+SFjJe5j5+T3lxn/fmOusE1hz0LsLbVXEY8ARKrO1m0K91l+AQO9q+hPuF5pSAyHKv
VzZ6TlJOmIhHrqSknN1Au5CIrbyauNSDELtQiw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 27584)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
