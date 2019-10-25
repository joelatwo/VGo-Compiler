#include "tree.h"
#include "symboltable.h"
#include "linkedlist.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "nonterminal.h"

struct symboltable *functionSymbolTable[100];
int functionSymbolTableLastIndex = 0;
struct symboltable *structSymbolTable[100];
int structSymbolTableLastIndex = 0;

struct symboltable *createSymbolTable(char *tableName, struct symboltable *parent)
{
    struct symboltable *newSymbolTable = calloc(1, sizeof(struct symboltable));
    newSymbolTable->tablename = strdup(tableName);
    newSymbolTable->parent = parent;
    return newSymbolTable;
}

int calculateHashKey(char *string)
{
    register int h = 0;
    register char c;
    while ((c = *string++))
    {
        h += c & 0377;
        h *= 37;
    }
    if (h < 0)
    {
        h = -h;
    }
    return h % HASHSIZE;
}

void insertVariableIntoHash(struct Node *terminal, int type, char *typeName, struct symboltable *currentSymbolTable)
{
    int index = calculateHashKey(terminal->data->text);
    int whereIsVariableInTable = isVariableInTable(currentSymbolTable, index, terminal->data->text);
    if (whereIsVariableInTable == 0 || whereIsVariableInTable == 2)
    {
        struct Symbol *newData = malloc(sizeof(struct Symbol));
        newData->name = strdup(terminal->data->text);
        newData->type = type;
        newData->typeName = strdup(typeName);
        // previously we set the category as a storage place for the isConst flag to keep track
        if (terminal->category == lconst)
        {
            newData->isConst = 1;
        }
        // previously we set the ival as a storage for the extra information
        else if (terminal->data->ival >= 0)
        {
            newData->arraySize = terminal->data->ival;
        }

        currentSymbolTable->hash[index] = addToFront(newData, currentSymbolTable->hash[index]);
    }
    else
    {
        printf("Redeclaration of variable '%s' not allowed. Found in file %s at line %d\n", terminal->data->text, terminal->data->filename, terminal->data->linenumber);
        exit(3);
    }
}

int isVariableInTable(struct symboltable *currentSymbolTable, int index, char *variableName)
{
    // check current
    if (isVariableInLinkedList(variableName, currentSymbolTable->hash[index]) == 1)
    {
        return 1;
    }
    // check global
    if (currentSymbolTable->parent != NULL)
    {
        if (isVariableInLinkedList(variableName, currentSymbolTable->parent->hash[index]) == 1)
        {
            return 2;
        }
    }
    // check struct table
    int i = 0;
    for (i = 0; i < structSymbolTableLastIndex; i++)
    {
        if (strcmp(structSymbolTable[i]->tablename, variableName) == 0)
        {
            return 1;
        }
        else if (isVariableInLinkedList(variableName, structSymbolTable[i]->hash[index]) == 1)
        {
            return 3;
        }
    }
    // check function tables
    for (i = 0; i < functionSymbolTableLastIndex; i++)
    {
        if (strcmp(functionSymbolTable[i]->tablename, variableName) == 0)
        {
            return 4;
        }
    }

    // haven't found it anywhere
    return 0;
}

void addToFunctionList(struct symboltable *currentSymbolTable)
{
    functionSymbolTable[functionSymbolTableLastIndex] = currentSymbolTable;
    functionSymbolTableLastIndex++;
    if (functionSymbolTableLastIndex > 99)
    {
        printf("There is a maximum of 100 functions allowed in VGo\n");
        exit(3);
    }
}

struct symboltable *createStructTable(char *tableName, struct symboltable *parent)
{
    struct symboltable *newSymbolTable = calloc(1, sizeof(struct symboltable));
    newSymbolTable->tablename = strdup(tableName);
    newSymbolTable->parent = parent;

    structSymbolTable[structSymbolTableLastIndex] = newSymbolTable;
    structSymbolTableLastIndex++;
    if (structSymbolTableLastIndex > 99)
    {
        printf("There is a maximum of 100 structs allowed in VGo\n");
        exit(3);
    }
    return newSymbolTable;
}

void printSymbolTable(struct symboltable *currentSymbolTable)
{
    printf("----Symbol Table for: %s", currentSymbolTable->tablename);
    if (currentSymbolTable->returnType)
    {
        printf(" with return type: %s", currentSymbolTable->returnTypeName);
    }
    printf("----\n");
    int i = 0;
    for (i = 0; i < 701; i++)
    {
        printLinkedList(currentSymbolTable->hash[i]);
    }
}

void printFunctionSymbolTable()
{
    int i = 0;
    for (i = 0; i < functionSymbolTableLastIndex; i++)
    {
        printSymbolTable(functionSymbolTable[i]);
    }
}

void printStructSymbolTable()
{
    int i = 0;
    for (i = 0; i < structSymbolTableLastIndex; i++)
    {

        printSymbolTable(structSymbolTable[i]);
    }
}

void insertDeclarationPropertyList(struct symboltable *currentSymbolTable)
{
    struct LinkedListNode *current = currentSymbolTable->declarationPropertyList;
    while (current != NULL)
    {
        int index = calculateHashKey(current->data->name);
        if (isVariableInTable(currentSymbolTable, index, current->data->name) == 0)
        {
            currentSymbolTable->hash[index] = addToFront(current->data, currentSymbolTable->hash[index]);
        }
        current = current->next;
    }
}

struct symboltable *findStructTable(char *variableName)
{
    int i = 0;
    for (i = 0; i < structSymbolTableLastIndex; i++)
    {
        if (strcmp(structSymbolTable[i]->tablename, variableName) == 0)
        {
            return structSymbolTable[i];
        }
    }
    printf("Unable to find struct symbol table '%s'\n", variableName);
    exit(3);
}

char *findTypeInSymbolTable(struct symboltable *currentSymbolTable, char *variableName)
{
    int index = calculateHashKey(variableName);

    char *typeName = findTypeInLinkedList(variableName, currentSymbolTable->hash[index]);
    if (strlen(typeName) == 0)
    {
        return "";
    }
    else
    {
        return typeName;
    }
}
