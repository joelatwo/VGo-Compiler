#ifndef TOKENCODES
#define TOKENCODES
#include <stdio.h>
/* Tokens. */
#define COMMENT 300

/* Keywords */
#define FUNC 301
#define ELSE 302
#define CONST 303
#define FOR 304
#define MAP 305
#define PACKAGE 306
#define IF 307
#define IMPORT 308
#define STRUCT 309
#define TYPE 310
#define RETURN 311
#define PUBLIC 345
#define PRIVATE 346

/* Symbols */
#define BOOL 312
#define STRING 313
#define INT 314
#define FLOAT 315
#define VAR 357
#define LPAREN 316
#define RPAREN 317
#define LSQUAREBRACE 318
#define RSQUAREBRACE 319
#define PERIOD 320
#define MINUS 321
#define MINUSMINUS 354
#define EXCLAMATION 322
#define STAR 323
#define DIVIDE 324
#define MOD 325
#define PLUS 326
#define PLUSPLUS 353
#define LESSTHAN 327
#define GREATERTHAN 328
#define LESSTHANEQUAL 329
#define GREATERTHANEQUAL 330
#define EQUALEQUAL 331
#define NOTEQUAL 332
#define ANDAND 333
#define OROR 334
#define EQUAL 335
#define PLUSEQUAL 336
#define MINUSEQUAL 337
#define LBRACKET 340
#define RBRACKET 341
#define COLON 352
#define SEMICOLON 342
#define COMA 344

#define DECIMAL 355
#define OCTAL 352
#define HEXADECIMAL 370
#define SCIENTIFICNUM 371

/* Literals */
#define STRINGLIT 338
#define CHAR 356
#define NUMERICLITERAL 339

/* Scope */
#define PACKAGESCOPE 350
#define LOCALSCOPE 351

/* Other */
#define IDENTIFIER 343

extern int yyparse();
extern void yyerror(char *s);
extern char *yytext;
extern FILE *yyin;
char *currentfile;
extern int yylex();
void reportGenericError(char *errorMessage);
void reportError(char *errorMessage);
void reportErrorOnlyText(char *errorMessage, char *text);

#endif