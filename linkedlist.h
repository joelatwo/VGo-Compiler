#ifndef LINKEDLIST
#define LINKEDLIST

struct Node
{
    struct Token *data;
    struct Node *next;
};

void createToken(int category);
void addToEnd(struct Token *newData);
void printList();
void printData(struct Token *data);
void deleteLinkedList();

struct Token
{
    int category;
    char *text;
    int linenumber;
    int column;
    char *filename;
    int ival;
    double dval;
    char *sval;
};

#endif