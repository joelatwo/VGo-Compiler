#include "globalutilities.h"
#include "tree.h"
#include <stdlib.h>
#include <stdio.h>

int yyerror(char *string)
{
    printf("%s\t%s:%d: before '%s' \n", string, currentfile, yylineno, yylval.node->data->text);
    exit(2);
}
