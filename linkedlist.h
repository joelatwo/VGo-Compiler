#ifndef LINKEDLIST
#define LINKEDLIST

#define GLOBALSCOPE 0;
#define STRUCTSCOPE 1;
#define FUNCTIONSCOPE 2;

struct LinkedListNode
{
    struct Symbol *data;
    struct LinkedListNode *next;
};

struct Symbol
{
    char *name;
    int type;
    int bitSize;
    char *typeName;
    int isConst;
    int arraySize;
    struct location *address;
};

struct LinkedListNode *addToFront(struct Symbol *newData, struct LinkedListNode *head);
struct LinkedListNode *addToEnd(struct Symbol *newData, struct LinkedListNode *head);
void printData(struct Symbol *data);
void updateWithNextTypeInformation(struct LinkedListNode *current);
void handleMissingTypes(struct LinkedListNode *head);
void printLinkedList(struct LinkedListNode *head);
int isVariableInLinkedList(char *variableName, struct LinkedListNode *head);
int findTypeInLinkedList(char *variableName, struct LinkedListNode *head);
int compareLinkedLists(struct LinkedListNode *typeList, struct LinkedListNode *paramList);
char *findTypeNameInLinkedList(char *variableName, struct LinkedListNode *head);
struct location *findLocationInLinkedList(char *variableName, struct LinkedListNode *head);

#endif