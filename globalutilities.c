#include "globalutilities.h"
#include "tree.h"
#include <stdlib.h>
#include <stdio.h>

int yyerror(char *string)
{
    printf("\033[0;31m");
    printf("%s\t%s:%d: before '%s' \n", string, currentfile, yylineno, yylval.node->data->text);
    printf("\033[0m");
    exit(2);
}
