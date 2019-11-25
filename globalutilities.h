#ifndef GLOBAL
#define GLOBAL

#include "vgobison.tab.h"
#include <stdio.h>
#include "tree.h"

int printCode;

extern int yylineno;
extern char *yytext;
extern FILE *yyin;
extern void *yylast;
extern int yyprev();
char *currentfile;
extern int yylex();
int yyerror(char *string);
extern YYSTYPE yylval;
char *findTypeName(int typeId);
int findTypeCategory(int typeId);
int compareLeftAndRightTypes(int leftType, int righttype);
int calculateBitSize(int type, int length);

struct Node *treeHead;

#endif
