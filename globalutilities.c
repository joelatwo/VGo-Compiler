#include "globalutilities.h"
#include "vgobison.tab.h"
#include "nonterminal.h"
#include "tree.h"
#include <stdlib.h>
#include <stdio.h>

int yyerror(char *string)
{
    printf("%s\t%s:%d: before '%s' \n", string, currentfile, yylineno, yylval.node->data->text);
    exit(2);
}

char *findTypeName(int typeId)
{
    switch (typeId)
    {
    case INT:
    case NUMERICLITERAL:
    case OCTAL:
    case HEXADECIMAL:
        return "int";

    case DECIMAL:
    case SCIENTIFICNUM:
        return "float64";

    case BOOL:
        return "bool";

    case CHAR:
    case STRINGLIT:
        return "string";

    case LNAME:
        return "struct";

    case VOID:
    case -1:
        return "void";

    default:
        return "Unknown Type";
    }
}

int findTypeCategory(int typeId)
{
    switch (typeId)
    {
    case INT:
    case NUMERICLITERAL:
    case OCTAL:
    case HEXADECIMAL:
        return INT;

    case DECIMAL:
    case SCIENTIFICNUM:
        return FLOAT64;

    case BOOL:
        return BOOL;

    case CHAR:
    case STRINGLIT:
        return STRING;

    case LNAME:
        return LNAME;

    case VOID:
        return VOID;

    default:
        return -1;
    }
}

int compareLeftAndRightTypes(int leftType, int righttype)
{
    leftType = findTypeCategory(leftType);
    righttype = findTypeCategory(righttype);
    if (leftType == righttype)
    {
        return leftType;
    }
    else
    {
        return 0;
    }
}

int calculateBitSize(int type, int length)
{
    int size = 0;

    switch (type)
    {
    case INT:
    case NUMERICLITERAL:
    case OCTAL:
    case HEXADECIMAL:
        size = 8;
        break;

    case DECIMAL:
    case SCIENTIFICNUM:
        size = 8;
        break;

    case BOOL:
        size = 8;
        break;

    case CHAR:
    case STRINGLIT:
        size = 8;
        break;

        if (length >= 0)
        {
            // if we have a size we need to multiply it
            size *= length;
        }
    }
    return size;
}