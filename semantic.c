#include "tree.h"
#include "semantic.h"
#include "symboltable.h"
#include "vgobison.tab.h"
#include "nonterminal.h"
#include "semantic.h"
#include "globalutilities.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "linkedlist.h"

struct symboltable *globalSymbolTable;
struct symboltable *currentSymbolTable;

void scopeAnalysis(struct Node *treeHead);
void checkChildren(struct Node *treeHead);
void printChildren(struct Node *treeHead);
void handlePackage(struct Node *treeHead);
void handleImportPackage(struct Node *treeHead);
void handleStruct(struct Node *treeHead);
void handleFunctionDeclaration(struct Node *treeHead);
void handleVariableDeclaration(struct Node *treeHead);
void lookForVariableNames(struct Node *treeHead, int type, char *typeName);
void lookForParameterNames(struct Node *treeHead);
void lookForReturnTypes(struct Node *treeHead);
void handleVariableInstance(struct Node *treeHead);
void lookForStructVariables(struct Node *treeHead, struct symboltable *currentStruct);
void findConstName(struct Node *treeHead, int type, char *typeName);
void handleConst(struct Node *treeHead);

int arraySize = -1;

void beginSemanticAnalysis(struct Node *treeHead)
{
    globalSymbolTable = createSymbolTable("Global Scope", NULL);
    currentSymbolTable = globalSymbolTable;
    scopeAnalysis(treeHead);
    if (printCode == 3)
    {
        printSymbolTable(globalSymbolTable);
        printFunctionSymbolTable();
        printStructSymbolTable();
    }
}

void scopeAnalysis(struct Node *treeHead)
{
    if (treeHead != NULL)
    {
        switch (treeHead->category)
        {
        case package:
            handlePackage(treeHead);
            break;

        case import_here:
            handleImportPackage(treeHead);
            break;

        case typedcl:
            handleStruct(treeHead);
            break;

        case xfndcl:
            handleFunctionDeclaration(treeHead);
            break;

        case constdcl:
            handleConst(treeHead);
            break;

        case vardcl:
            handleVariableDeclaration(treeHead);
            break;

        case LNAME:
            handleVariableInstance(treeHead);
            break;

        default:
            checkChildren(treeHead);
            break;
        }
    }
}

void checkChildren(struct Node *treeHead)
{
    if (treeHead->numberOfChildren > 0)
    {
        // look in each child
        int i = 0;
        for (i = 0; i < treeHead->numberOfChildren; i++)
        {
            scopeAnalysis(treeHead->children[i]);
        }
    }
}

void printChildren(struct Node *treeHead)
{
    int i = 0;
    for (i = 0; i < treeHead->numberOfChildren; i++)
    {
        printf("%d=", i);
        if (treeHead->children[i]->data != NULL)
        {
            printf("%s, ", treeHead->children[i]->data->text);
        }
        else
        {
            printf("%s, ", treeHead->children[i]->categoryName);
        }
    }
    printf("\n");
}

void handlePackage(struct Node *treeHead)
{
    char *packageName = strdup(treeHead->children[1]->data->text);
    if (strcmp(packageName, "main") != 0)
    {
        printf("Package name must be main in VGo instead found '%s' at %s:%d\n", treeHead->children[1]->data->text, currentfile, treeHead->children[1]->data->linenumber);
        exit(3);
    }
}

void handleImportPackage(struct Node *treeHead)
{
    if (strcmp(treeHead->children[0]->data->sval, "fmt") == 0)
    {
        struct symboltable *packagetable = createStructTable("fmt", globalSymbolTable);
        int index = calculateHashKey("Println");

        struct Symbol *newData = malloc(sizeof(struct Symbol));
        newData->name = "Println";
        newData->type = function;
        newData->typeName = "function";
        packagetable->hash[index] = addToFront(newData, packagetable->hash[index]);
    }
    else if (strcmp(treeHead->children[0]->data->sval, "time") == 0)
    {
        struct symboltable *packagetable = createStructTable("time", globalSymbolTable);
        int index = calculateHashKey("Now");

        struct Symbol *newData = malloc(sizeof(struct Symbol));
        newData->name = "Now";
        newData->type = function;
        newData->typeName = "function";
        packagetable->hash[index] = addToFront(newData, packagetable->hash[index]);
    }
    else if (strcmp(treeHead->children[0]->data->sval, "math/rand") == 0)
    {
        struct symboltable *packagetable = createStructTable("math/rand", globalSymbolTable);
        int index = calculateHashKey("Intn");

        struct Symbol *newData = malloc(sizeof(struct Symbol));
        newData->name = "Intn";
        newData->type = function;
        newData->typeName = "function";
        packagetable->hash[index] = addToFront(newData, packagetable->hash[index]);
    }
    else
    {
        printf("The following package %s is not supported in VGo\n", treeHead->children[0]->data->text);
        exit(3);
    }
}

void handleStruct(struct Node *treeHead)
{
    if (treeHead->numberOfChildren == 2)
    {
        struct symboltable *currentStructTable = createStructTable(treeHead->children[0]->data->text, globalSymbolTable);
        lookForStructVariables(treeHead->children[1], currentStructTable);
    }
}

void handleFunctionDeclaration(struct Node *treeHead)
{

    if (treeHead->children[1]->category == fndcl)
    {
        if (treeHead->children[1]->children[0]->data != NULL)
        {
            currentSymbolTable = createSymbolTable(strdup(treeHead->children[1]->children[0]->data->text), currentSymbolTable);
            addToFunctionList(currentSymbolTable);

            // handle parameters
            if (treeHead->children[1]->children[1] != NULL)
            {

                if (treeHead->children[1]->children[1]->category == oarg_type_list_ocomma)
                {
                    if (treeHead->children[1]->children[1]->children[0] == NULL)
                    {
                    }
                    else
                    {
                        lookForParameterNames(treeHead->children[1]->children[1]->children[0]);
                        handleMissingTypes(currentSymbolTable->declarationPropertyList);
                        insertDeclarationPropertyList(currentSymbolTable);
                    }
                }
            }
            if (treeHead->children[1]->numberOfChildren == 3)
            {
                lookForReturnTypes(treeHead->children[1]->children[2]);
            }
        }
    }

    // continue running on function body if it exists
    if (treeHead->numberOfChildren == 3)
    {
        if (treeHead->children[2]->category == fnbody)
        {
            scopeAnalysis(treeHead->children[2]);
            if (currentSymbolTable->parent != NULL)
            {
                currentSymbolTable = currentSymbolTable->parent;
            }
        }
    }
    else
    {
    }
}

void lookForVariableNames(struct Node *treeHead, int type, char *typeName)
{
    if (treeHead->children[0]->category == dcl_name_list)
    {
        lookForVariableNames(treeHead->children[0], type, typeName);
    }
    if (treeHead->children[0] != NULL && treeHead->children[0]->category == dcl_name)
    {
        if (arraySize != -1)
        {
            treeHead->children[0]->children[0]->data->ival = arraySize;

            arraySize = -1;
        }
        insertVariableIntoHash(treeHead->children[0]->children[0], type, typeName, currentSymbolTable);
    }
    else if (treeHead->children[1] != NULL && treeHead->children[1]->category == dcl_name)
    {
        if (arraySize != -1)
        {
            treeHead->children[1]->children[0]->data->ival = arraySize;

            arraySize = -1;
        }
        insertVariableIntoHash(treeHead->children[1]->children[0], type, typeName, currentSymbolTable);
    }
    else
    {
        printf("Something went wrong here is the tree for debugging\n");
        treeprint(treeHead, 0);
        exit(3);
    }
}

void lookForReturnTypes(struct Node *treeHead)
{
    if (treeHead == NULL)
    {
        // do nothing
    }
    else if (treeHead->numberOfChildren > 0)
    {
        int i = 0;
        for (i = 0; i < treeHead->numberOfChildren; i++)
        {
            lookForReturnTypes(treeHead->children[i]);
        }
    }
    else if (treeHead != NULL)
    {
        currentSymbolTable->returnType = treeHead->data->category;
        currentSymbolTable->returnTypeName = strdup(treeHead->data->text);
    }
}

void handleVariableDeclaration(struct Node *treeHead)
{
    int type;
    char *typeName;
    if (treeHead->children[1] != NULL && treeHead->children[1]->numberOfChildren == 0)
    {
        // regular variable declaration
        type = treeHead->children[1]->data->category;
        typeName = strdup(treeHead->children[1]->data->text);
        if (type == LNAME)
        {
        }
        lookForVariableNames(treeHead->children[0], type, typeName);
    }
    else
    {
        // array declaration
        if (treeHead->children[1]->category == othertype)
        {
            type = treeHead->children[1]->children[treeHead->children[1]->numberOfChildren - 1]->data->category;
            typeName = strdup(treeHead->children[1]->children[treeHead->children[1]->numberOfChildren - 1]->data->text);
            arraySize = treeHead->children[1]->children[1]->children[0]->data->ival;
            lookForVariableNames(treeHead->children[0], type, typeName);
        }
    }
}

void lookForParameterNames(struct Node *treeHead)
{
    if (treeHead->category == arg_type)
    {
        if (treeHead->numberOfChildren == 1)
        {
            struct Symbol *newData = malloc(sizeof(struct Symbol));
            newData->name = strdup(treeHead->children[0]->children[0]->data->text);
            newData->type = -1;
            newData->typeName = NULL;
            currentSymbolTable->declarationPropertyList = addToEnd(newData, currentSymbolTable->declarationPropertyList);
        }
        if (treeHead->numberOfChildren == 2)
        {

            int type = treeHead->children[1]->children[0]->data->category;
            char *typeName = treeHead->children[1]->children[0]->data->text;

            struct Symbol *newData = malloc(sizeof(struct Symbol));
            newData->name = strdup(treeHead->children[0]->data->text);
            newData->type = type;
            newData->typeName = strdup(typeName);
            currentSymbolTable->declarationPropertyList = addToEnd(newData, currentSymbolTable->declarationPropertyList);

            // insertVariableIntoHash(treeHead->children[0], type, typeName, currentSymbolTable);
        }
    }
    else
    {
        if (treeHead->numberOfChildren > 0)
        {
            // look in each child
            int i = 0;
            for (i = 0; i < treeHead->numberOfChildren; i++)
            {
                lookForParameterNames(treeHead->children[i]);
            }
        }
    }
}

void handleVariableInstance(struct Node *treeHead)
{
    int index = calculateHashKey(treeHead->data->text);
    if (isVariableInTable(currentSymbolTable, index, treeHead->data->text) == 0)
    {
        printf("Undeclared variable '%s' at file %s on line %d encountered\n", treeHead->data->text, treeHead->data->filename, treeHead->data->linenumber);
        exit(3);
    }
}

void lookForStructVariables(struct Node *treeHead, struct symboltable *currentStruct)
{
    if (treeHead == NULL)
    {
        // do nothing
    }
    else if (treeHead->category == structdcl)
    {
        int type = treeHead->children[1]->data->category;
        char *typeName = strdup(treeHead->children[1]->data->text);

        insertVariableIntoHash(treeHead->children[0]->children[0]->children[0], type, typeName, currentStruct);
    }
    else if (treeHead->numberOfChildren > 0)
    {
        int i = 0;
        for (i = 0; i < treeHead->numberOfChildren; i++)
        {
            lookForStructVariables(treeHead->children[i], currentStruct);
        }
    }
}

void handleConst(struct Node *treeHead)
{
    if (treeHead->numberOfChildren == 4)
    {

        if (treeHead->children[1]->numberOfChildren == 0)
        {
            int type;
            char *typeName;
            type = treeHead->children[1]->data->category;
            typeName = strdup(treeHead->children[1]->data->text);

            findConstName(treeHead->children[0], type, typeName);
        }
    }
}

void findConstName(struct Node *treeHead, int type, char *typeName)
{
    if (treeHead == NULL)
    {
        // do nothing
    }
    else if (treeHead->category == dcl_name)
    {
        treeHead->children[0]->category = lconst;
        insertVariableIntoHash(treeHead->children[0], type, typeName, currentSymbolTable);
    }
    else
    {
        int i = 0;
        for (i = 0; i < treeHead->numberOfChildren; i++)
        {
            findConstName(treeHead->children[i], type, typeName);
        }
    }
}
