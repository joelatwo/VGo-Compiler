#ifndef LOCATION
#define LOCATION

#include <stdio.h>
#include <stdlib.h>

struct location
{
    int region;
    int offset;
};

struct operation
{
    struct location *leftAddress;
    struct location *rightAddress;
    int opcode;
    struct location *outAddress;
    struct operation *next;
};

/* REGIONS */
#define REGIONGLOBAL 1000
#define REGIONLOCAL 2000
#define REGIONFUNCTION 3000
#define REGIONLABEL 4000
#define REGIONCONST 5000
#define REGIONSTRING 6000

/* OPCODES */
#define O_ADD 3001
#define O_SUB 3002
#define O_MUL 3003
#define O_DIV 3004
#define O_NEG 3005   // !
#define O_ASN 3006   // =
#define O_ADDR 3007  //
#define O_LCONT 3008 //
#define O_SCONT 3009 //
#define O_GOTO 3010
#define O_BLT 3011  // <
#define O_BLE 3012  // <=
#define O_BGT 3013  // >
#define O_BGE 3014  // >=
#define O_BEQ 3015  // ==
#define O_BNE 3016  // !=
#define O_BIF 3017  // if
#define O_BNIF 3018 // not if
#define O_PARM 3019
#define O_CALL 3020
#define O_RET 3021
#define O_ADD1 3022
#define O_SUB1 3023

/* declarations/pseudo instructions */
#define D_GLOB 4051
#define D_PROC 4052
#define D_LOCAL 4053
#define D_LABEL 4054
#define D_END 4055

struct operation *createOperation(int opcode, struct location *left, struct location *right, struct location *destination);
struct operation *combineLinkedList(struct operation *head, struct operation *tail);
struct operation *findLastOperation(struct operation *head);
char *convertCodeToString(int code);
struct location *createLocation(int region, int *offset);
void printOperationLinkedList(struct operation *head, char *filename);
void printOperationData(struct operation *head, FILE *fp);

#endif