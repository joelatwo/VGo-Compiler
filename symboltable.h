#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#define HASHSIZE 701;

struct symboltable
{
    char *tablename;
    struct symboltable *parent;
    struct symboltable *children[9];
    struct LinkedListNode *hash[701];
    struct LinkedListNode *declarationPropertyList;
    int returnType;
    char *returnTypeName;
    int regionCounter;
    struct location *address;
    struct location *returnValue;
};

struct symboltable *createSymbolTable(char *tableName, struct symboltable *parent);
void insertVariableIntoHash(struct Node *terminal, int type, char *typeName, struct symboltable *currentSymbolTable);
int calculateHashKey(char *string);
void checkStruct(char *typeName);
void addToFunctionList(struct symboltable *currentSymbolTable);
void printFunctionSymbolTable();
void printStructSymbolTable();
struct symboltable *createStructTable(char *tableName, struct symboltable *parent);
void insertDeclarationPropertyList(struct symboltable *currentSymbolTable);
int isVariableInTable(struct symboltable *currentSymbolTable, int index, char *variableName);
void printSymbolTable(struct symboltable *currentSymbolTable);
struct symboltable *findStructTable(char *variableName);
int findTypeInSymbolTable(struct symboltable *currentSymbolTable, char *variableName);
struct symboltable *findSymbolTable(char *tableName);
struct location *findLocationFromSymbolTable(struct symboltable *currentSymbolTable, char *variableName);
struct symboltable *findFunctionLocation(char *variableName);

#endif
