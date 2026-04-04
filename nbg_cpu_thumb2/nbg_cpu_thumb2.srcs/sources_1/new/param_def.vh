//转移指令
`define MICRO_CODE_B        0
`define MICRO_CODE_BX       1
`define MICRO_CODE_BL       2
`define MICRO_CODE_BLX      3
`define MICRO_CODE_TBB      4
`define MICRO_CODE_TBH      5
`define MICRO_CODE_CBNZ_CBZ 6
`define MICRO_CODE_IT       7

//数据传送指令
`define MICRO_CODE_LDR      8
`define MICRO_CODE_LDRH     9
`define MICRO_CODE_LDRHT    10  //未实现
`define MICRO_CODE_LDRSH    11
`define MICRO_CODE_LDRB     12
`define MICRO_CODE_LDRBT    13  //未实现
`define MICRO_CODE_LDRSB    14
`define MICRO_CODE_LDRSBT   15  //未实现
`define MICRO_CODE_LDRD     16
`define MICRO_CODE_LDRT     17  //未实现
`define MICRO_CODE_LDREX    18  //未实现
`define MICRO_CODE_LDREXH   19  //未实现
`define MICRO_CODE_LDREXB   20  //未实现
`define MICRO_CODE_STR      21
`define MICRO_CODE_STRH     22
`define MICRO_CODE_STRHT    23  //未实现
`define MICRO_CODE_STRB     24
`define MICRO_CODE_STRBT    25  //未实现
`define MICRO_CODE_STRT     26  //未实现
`define MICRO_CODE_STRD     27
`define MICRO_CODE_STREX    28  //未实现
`define MICRO_CODE_STREXH   29  //未实现
`define MICRO_CODE_STREXB   30  //未实现
`define MICRO_CODE_STMIA    31
`define MICRO_CODE_STMDB    32
`define MICRO_CODE_LDMIA    33
`define MICRO_CODE_LDMDB    34
`define MICRO_CODE_PUSH     35
`define MICRO_CODE_POP      36

//位操作指令
`define MICRO_CODE_ASR      37
`define MICRO_CODE_LSL      38
`define MICRO_CODE_LSR      39
`define MICRO_CODE_RRX      40
`define MICRO_CODE_ROR      41
`define MICRO_CODE_BIC      42
`define MICRO_CODE_BFC      43
`define MICRO_CODE_BFI      44
`define MICRO_CODE_UBFX     45
`define MICRO_CODE_SBFX     46  //未实现
`define MICRO_CODE_CLZ      47
`define MICRO_CODE_RBIT     48  //未实现
`define MICRO_CODE_REV      49
`define MICRO_CODE_REV16    50
`define MICRO_CODE_REVSH    51
`define MICRO_CODE_SXTB     52
`define MICRO_CODE_SXTH     53
`define MICRO_CODE_UXTB     54
`define MICRO_CODE_UXTH     55

//与或非
`define MICRO_CODE_AND      56
`define MICRO_CODE_EOR      57
`define MICRO_CODE_ORR      58
`define MICRO_CODE_ORN      59  //未实现
`define MICRO_CODE_MVN      60
`define MICRO_CODE_TST      61
`define MICRO_CODE_TEQ      62

//加减乘除
`define MICRO_CODE_ADC      63
`define MICRO_CODE_ADD      64
`define MICRO_CODE_ADDW     65  //未实现
`define MICRO_CODE_SUB      66
`define MICRO_CODE_SUBW     67  //未实现
`define MICRO_CODE_SBC      68
`define MICRO_CODE_RSB      69
`define MICRO_CODE_CMN      70
`define MICRO_CODE_CMP      71
`define MICRO_CODE_MUL      72
`define MICRO_CODE_UMLAL    73
`define MICRO_CODE_UMULL    74
`define MICRO_CODE_MLA      75
`define MICRO_CODE_MLS      76
`define MICRO_CODE_UDIV     77
`define MICRO_CODE_SDIV     78

//综合指令
`define MICRO_CODE_ADR      79
`define MICRO_CODE_MOV      80
`define MICRO_CODE_MOVT     81
`define MICRO_CODE_MOVW     82  //未实现
`define MICRO_CODE_NOP      83
`define MICRO_CODE_MRS      84
`define MICRO_CODE_MSR      85
`define MICRO_CODE_ISB      86
`define MICRO_CODE_DSB      87
`define MICRO_CODE_DMB      88
`define MICRO_CODE_CLREX    89  //未实现
`define MICRO_CODE_UDF      90  //未实现
`define MICRO_CODE_CPY      91  //未实现
`define MICRO_CODE_NEG      92  //未实现
`define MICRO_CODE_SVC      93  //未实现
`define MICRO_CODE_SFBX     94  //未实现
`define MICRO_CODE_SMLAL    95  //未实现
`define MICRO_CODE_SMULL    96  //未实现
`define MICRO_CODE_SSAT     97  //未实现
`define MICRO_CODE_USAT     98  //未实现

//不准备实现，大多和协处理器多核同步，低功耗有关
//包含CDP2、LDC2、MCR2、MCRR2、MRC2、MRRC2、STC2
`define MICRO_CODE_SEV      100  //未实现
`define MICRO_CODE_WFE      101  //未实现
`define MICRO_CODE_WFI      102  //未实现
`define MICRO_CODE_BKPT     103  //未实现
`define MICRO_CODE_STC      104  //未实现
`define MICRO_CODE_DBG      105  //未实现
`define MICRO_CODE_PLD      106  //未实现
`define MICRO_CODE_PLI      107  //未实现
`define MICRO_CODE_YIELD    108  //未实现
`define MICRO_CODE_LDC      109  //未实现
`define MICRO_CODE_MCR      110  //未实现
`define MICRO_CODE_MCRR     111  //未实现
`define MICRO_CODE_MRC      112  //未实现
`define MICRO_CODE_MRRC     113  //未实现
`define MICRO_CODE_CPS      114  //未实现
`define MICRO_CODE_CDP      115  //未实现

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