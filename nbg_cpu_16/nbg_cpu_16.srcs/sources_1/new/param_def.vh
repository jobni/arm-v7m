//转移指令
`define MICRO_CODE_B        0
`define MICRO_CODE_BX       1
`define MICRO_CODE_BL       2
`define MICRO_CODE_BLX      3
`define MICRO_CODE_TBB      4
`define MICRO_CODE_CBNZ_CBZ 5
`define MICRO_CODE_IT       6

//数据传送指令
`define MICRO_CODE_LDR      10
`define MICRO_CODE_LDRH     11
`define MICRO_CODE_LDRB     12
`define MICRO_CODE_LDRSB    13
`define MICRO_CODE_LDRD     14
`define MICRO_CODE_STR      15
`define MICRO_CODE_STRH     16
`define MICRO_CODE_STRB     17
`define MICRO_CODE_STRD     18
`define MICRO_CODE_STMIA    19
`define MICRO_CODE_LDMIA    20
`define MICRO_CODE_PUSH     21
`define MICRO_CODE_POP      22

//移位指令
`define MICRO_CODE_ASR      25
`define MICRO_CODE_LSL      26
`define MICRO_CODE_LSR      27
`define MICRO_CODE_RRX      28
`define MICRO_CODE_ROR      29

//与或非
`define MICRO_CODE_AND      30
`define MICRO_CODE_BIC      31
`define MICRO_CODE_EOR      32
`define MICRO_CODE_ORR      33
`define MICRO_CODE_MVN      34
`define MICRO_CODE_TST      35
`define MICRO_CODE_TEQ      36

//加减乘除
`define MICRO_CODE_ADD      38
`define MICRO_CODE_ADC      39
`define MICRO_CODE_SUB      40
`define MICRO_CODE_SBC      41
`define MICRO_CODE_RSB      42
`define MICRO_CODE_BFC      43
`define MICRO_CODE_CMN      44
`define MICRO_CODE_CMP      45
`define MICRO_CODE_MUL      46
`define MICRO_CODE_UMLAL    47
`define MICRO_CODE_UMULL    48
`define MICRO_CODE_MLA      49
`define MICRO_CODE_MLS      50
`define MICRO_CODE_UDIV     51
`define MICRO_CODE_SDIV     52

//扩展指令
`define MICRO_CODE_UXTB     54
`define MICRO_CODE_SXTB     55

//综合指令
`define MICRO_CODE_ADR      58
`define MICRO_CODE_CLZ      59
`define MICRO_CODE_MOV      60
`define MICRO_CODE_MOVT     61
`define MICRO_CODE_UBFX     62
`define MICRO_CODE_NOP      63

`define MICRO_TYPE_LITERAL      0
`define MICRO_TYPE_IMMEDIATE    1
`define MICRO_TYPE_REGISTER     2
`define MICRO_TYPE_SHIFTED      3

`define REGISTER_CODE_R0    0
`define REGISTER_CODE_R1    1
`define REGISTER_CODE_R2    2
`define REGISTER_CODE_R3    3
`define REGISTER_CODE_R4    4
`define REGISTER_CODE_R5    5
`define REGISTER_CODE_R6    6
`define REGISTER_CODE_R7    7
`define REGISTER_CODE_R8    8
`define REGISTER_CODE_R9    9
`define REGISTER_CODE_R10   10
`define REGISTER_CODE_R11   11
`define REGISTER_CODE_R12   12
`define REGISTER_CODE_SP    13
`define REGISTER_CODE_LR    14
`define REGISTER_CODE_PC    15

`define CPU_ST_IF       0
`define CPU_ST_DECODE   1
`define CPU_ST_MICRO    2

`define SRTYPE_LSL      3'h0
`define SRTYPE_LSR      3'h1
`define SRTYPE_ASR      3'h2
`define SRTYPE_ROR      3'h3
`define SRTYPE_RRX      3'h4

`define SYSTEM_TICK         20'h00000
`define SYSTEM_SIGNAL       20'h00004
`define UART1_SR            20'h00100
`define UART1_DR            20'h00104
`define FLASH_WRITE_ADDR    20'h00200
`define FLASH_WRITE_COUNT	20'H00204
`define CPU_STATUS          20'h00300