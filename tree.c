#include "tree.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "nonterminal.h"
#include <string.h>

int treeprint(struct Node *t, int depth)
{
  if(t != NULL){
    int i;
    printf("%*s %s: ", depth * 2, " ", t->categoryName);

    if(t->numberOfChildren > 0){
      printf("%d\n", t->numberOfChildren);
      for (i = 0; i < t->numberOfChildren; i++)
	{
	  treeprint(t->children[i], depth + 1);
	}
    }else if(t->numberOfChildren == 0){
      if(t->data != NULL){
	printf("code: %d %s\n",t->data->category,  t->data->text);
      }else{
        printf("0\n");
      }
    }
  }
  return 1;
}

struct Node *createTree(int category, char *categoryName, int size, ...)
{
    va_list valist;
    va_start(valist, size);

    struct Node *tree = malloc(sizeof(struct Node));
    tree->category = category;
    char *newString = malloc(strlen(categoryName) + 1);
    newString = strcpy(newString, categoryName);
    tree->categoryName = newString;
    tree->numberOfChildren = size;

    int i = 0;
    for (i = 0; i < size; i++)
    {
        tree->children[i] = va_arg(valist, struct Node *);
    }

    va_end(valist);

    return tree;
}
