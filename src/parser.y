%{
	#include <headers.h>
	int asm_lineno = 0;
%}

%union {
	int               ival;
	unsigned int      uival;
	float             fval;
	char           *  sval;
	struct arglist * arglist_t;
}

%type <arglist_t> args

%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

%token <ival> I_CONSTANT <fval> F_CONSTANT <sval> D_CONSTANT STRING_LITERAL IDENTIFIER
%token <ival> LABEL

/* Opcodes: */
/* ARITHMETIC AND LOGIC */
%token<sval> ADD ADDI ADDIS ADDS
%token<sval> SUB SUBI SUBIS SUBS
%token<sval> MUL SMULH UMULH
%token<sval> SDIV UDIV
%token<sval> AND ANDI ANDIS ANDS
%token<sval> ORR ORRI
%token<sval> EOR EORI
%token<sval> LSL LSR
%token<sval> MOVK MOVZ
/* BRANCHING */
%token<sval> B BCOND BL BR CBNZ CBZ
/* LOAD AND STORE */
%token<sval> LDUR LDURB LDURH LDURSW LDXR
%token<sval> STUR STURB STURH STURW STXR
/* PSEUDO INSTRUCTIONS */
%token<sval> CMP CMPI
%token<sval> LDA
%token<sval> MOV

%token<uival> REGISTER IMMEDIATE

%start program
%%
program
	:
	| instruction program
	| label program
	;

instruction
	: IDENTIFIER args { make_instruction($1, $2); }
	
args
	: 
	  REGISTER ',' REGISTER ',' REGISTER  eol { $$ = make_argument_list(3, make_argument(0, 0, $1), make_argument(0, 0, $3), make_argument(0, 0, $5)); }
	| REGISTER ',' REGISTER ',' IMMEDIATE eol { $$ = make_argument_list(3, make_argument(0, 0, $1), make_argument(0, 0, $3), make_argument(1, 0, $5)); }
	| REGISTER ',' '[' REGISTER ',' IMMEDIATE ']' eol { $$ = make_argument_list(3, make_argument(0, 0, $1), make_argument(0, 1, $4), make_argument(1, 1, $6)); }
	| REGISTER ',' REGISTER ',' '[' REGISTER  ']' eol { $$ = make_argument_list(3, make_argument(0, 0, $1), make_argument(0, 0, $3), make_argument(0, 1, $6)); }
	| REGISTER ',' IDENTIFIER eol { $$ = make_argument_list(2, make_argument(0, 0, $1), make_argument(1, 0, $3)); }
	| REGISTER ',' IMMEDIATE  eol { $$ = make_argument_list(2, make_argument(0, 0, $1), make_argument(1, 0, $3)); }
		
eol:
	';' { asm_lineno++; }
	|   { asm_lineno++; }
	
label: IDENTIFIER ':' { add_label($1, asm_lineno); }

%%
