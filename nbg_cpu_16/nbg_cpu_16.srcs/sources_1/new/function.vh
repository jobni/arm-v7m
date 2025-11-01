function [7:0] convert_3_8;
    input [2:0] data_in;
    begin
        case(data_in)
            3'd0 : convert_3_8 = 8'b00000001;
            3'd1 : convert_3_8 = 8'b00000010;
            3'd2 : convert_3_8 = 8'b00000100;
            3'd3 : convert_3_8 = 8'b00001000;
            3'd4 : convert_3_8 = 8'b00010000;
            3'd5 : convert_3_8 = 8'b00100000;
            3'd6 : convert_3_8 = 8'b01000000;
            3'd7 : convert_3_8 = 8'b10000000;
        endcase
    end
endfunction

function [15:0] convert_4_16;
    input [3:0] data_in;
    begin
        case(data_in)
            4'h0 : convert_4_16 = 16'h0001;
            4'h1 : convert_4_16 = 16'h0002;
            4'h2 : convert_4_16 = 16'h0004;
            4'h3 : convert_4_16 = 16'h0008;
            4'h4 : convert_4_16 = 16'h0010;
            4'h5 : convert_4_16 = 16'h0020;
            4'h6 : convert_4_16 = 16'h0040;
            4'h7 : convert_4_16 = 16'h0080;
            4'h8 : convert_4_16 = 16'h0100;
            4'h9 : convert_4_16 = 16'h0200;
            4'hA : convert_4_16 = 16'h0400;
            4'hB : convert_4_16 = 16'h0800;
            4'hC : convert_4_16 = 16'h1000;
            4'hD : convert_4_16 = 16'h2000;
            4'hE : convert_4_16 = 16'h4000;
            4'hF : convert_4_16 = 16'h8000;
        endcase
    end
endfunction

function [10:0] decode_imm_shift_tn(input [1:0] type, input [4:0] imm5);
    begin
        decode_imm_shift_tn={decode_imm_shift_t(type, imm5),decode_imm_shift_n(type, imm5)};
    end
endfunction

function [7:0] decode_imm_shift_n(input [1:0] type, input [4:0] imm5);
    begin
        case(type)
            2'b00:decode_imm_shift_n={3'b0, imm5};
            2'b01:decode_imm_shift_n=(imm5==5'b0000)?8'd32:{3'b0, imm5};
            2'b10:decode_imm_shift_n=(imm5==5'b0000)?8'd32:{3'b0, imm5};
            2'b11:decode_imm_shift_n=(imm5==5'b0000)?8'd1 :{3'b0, imm5};
        endcase
    end
endfunction

function [2:0] decode_imm_shift_t(input [1:0] type, input [4:0] imm5);
    begin
        case(type)
            2'b00:decode_imm_shift_t=`SRTYPE_LSL;
            2'b01:decode_imm_shift_t=(imm5==5'b0000)?`SRTYPE_LSR:`SRTYPE_LSR;
            2'b10:decode_imm_shift_t=(imm5==5'b0000)?`SRTYPE_ASR:`SRTYPE_ASR;
            2'b11:decode_imm_shift_t=(imm5==5'b0000)?`SRTYPE_RRX :`SRTYPE_ROR;
        endcase
    end
endfunction

function [32:0] thumb_expand_imm_c(input [11:0] imm12, input carry_in);
    begin
        if(imm12[11:10] == 2'b00) begin
            case(imm12[9:8])
                2'b00:thumb_expand_imm_c={carry_in, 24'b0, imm12[7:0]};
                2'b01:thumb_expand_imm_c={carry_in, 8'b0, imm12[7:0], 8'b0, imm12[7:0]};
                2'b10:thumb_expand_imm_c={carry_in ,imm12[7:0], 8'b0, imm12[7:0], 8'b0};
                2'b11:thumb_expand_imm_c={carry_in, imm12[7:0], imm12[7:0], imm12[7:0], imm12[7:0]};
            endcase
        end
        else begin
            thumb_expand_imm_c = ror_c({24'b0, 1'b1, imm12[6:0]},imm12[11:7]);
        end
    end
endfunction

function [34:0] shift_c(input [31:0] value, input [2:0] sr_type, input [7:0] shift, input carry_in);
    reg [31:0] result;
    reg nagative;
    reg zero;
    reg carry_out;
    begin
        if(shift==8'b0) begin
            {carry_out, result} = {carry_in, value};
        end
        else begin
            case(sr_type)
                `SRTYPE_LSL:{carry_out, result}=lsl_c(value, shift);
                `SRTYPE_LSR:{carry_out, result}=lsr_c(value, shift);
                `SRTYPE_ASR:{carry_out, result}=asr_c(value, shift);
                `SRTYPE_ROR:{carry_out, result}=ror_c(value, shift);
                `SRTYPE_RRX:{carry_out, result}=rrx_c(value, carry_in);
            endcase
        end
        nagative = result[31];
        zero = result == 32'b0;
        shift_c = {nagative, zero, carry_out, result};
    end
endfunction

function [32:0] lsl_c(input [31:0] x, input [7:0] shift);
    reg [31:0] result;
    reg carry_out;
    begin
        {carry_out, result} = {1'b0, x}<<shift;
        lsl_c = {carry_out, result};
    end
endfunction

function [32:0] lsr_c(input [31:0] x, input [7:0] shift);
    reg [31:0] result;
    reg carry_out;
    begin
        {result, carry_out} = {x, 1'b0}>>shift;
        lsr_c = {carry_out, result};
    end
endfunction

function [32:0] asr_c(input [31:0] x, input [7:0] shift);
    reg [31:0] result;
    reg carry_out;
    begin
        {result, carry_out} = $signed({x, 1'b0})>>>shift;
        asr_c = {carry_out, result};
    end
endfunction

function [32:0] ror_c(input [31:0] x, input [7:0] shift);
    reg [31:0] result;
    begin
        result = (x<<(32-shift))|(x>>shift);
        ror_c = {result[31], result};
    end
endfunction

function [32:0] rrx_c(input [31:0] x, input carry_in);
    reg [31:0] result;
    begin
        rrx_c = {x[0], carry_in, x[31:1]};
    end
endfunction