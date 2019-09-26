#ifndef TREE
#define TREE

struct Token
{
    int category;
    char *text;
    int linenumber;
    char *filename;
    int ival;
    double dval;
    char *sval;
};

struct Node
{
    int category;
    char *categoryName;
    int numberOfChildren;
    struct Node *children[9];
    struct Token *data;
};

struct Node *createTree(int category, char *categoryName, int size, ...);
int treeprint(struct Node *t, int depth);

#endif
