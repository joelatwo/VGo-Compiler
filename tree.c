#include "tree.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "nonterminal.h"
#include <string.h>
#include "location.h"

void printlocation(char *labeltype, struct location *locationData);

int treeprint(struct Node *t, int depth)
{
  if (t != NULL)
  {
    int i;
    printf("%*s %s: ", depth * 2, " ", t->categoryName);

    if (t->numberOfChildren > 0)
    {
      printf("%d\n", t->numberOfChildren);
      for (i = 0; i < t->numberOfChildren; i++)
      {
        treeprint(t->children[i], depth + 1);
      }
    }
    else if (t->numberOfChildren == 0)
    {
      if (t->data != NULL)
      {
        printf("code: %d %s\n", t->data->category, t->data->text);
      }
      else
      {
        printf("0\n");
      }
    }
  }
  return 1;
}

void treeprintlocations(struct Node *t, int depth)
{
  if (t == NULL)
  {
    // do nothing
  }
  else
  {
    if (t->address != NULL)
    {
      printf("%s %d:\t", t->categoryName, t->category);
      printlocation("address", t->address);
    }
    if (t->first != NULL)
    {
      printf("%s %d:\t", t->categoryName, t->category);
      printlocation("first", t->first);
    }
    if (t->follow != NULL)
    {
      printf("%s %d:\t", t->categoryName, t->category);
      printlocation("follow", t->follow);
    }
    if (t->ifTrue != NULL)
    {
      printf("%s %d:\t", t->categoryName, t->category);
      printlocation("ifTrue", t->ifTrue);
    }
    if (t->ifFalse != NULL)
    {
      printf("%s %d:\t", t->categoryName, t->category);
      printlocation("ifFalse", t->ifFalse);
    }
    if (t->numberOfChildren > 0)
    {
      int i = 0;
      for (i = 0; i < t->numberOfChildren; i++)
      {
        treeprintlocations(t->children[i], depth + 1);
      }
    }
  }
}

void printlocation(char *labeltype, struct location *locationData)
{
  printf("\t%s ", labeltype);
  switch (locationData->region)
  {
  case REGIONGLOBAL:
    printf("GLOBAL ");
    break;
  case REGIONLOCAL:
    printf("LOCAL ");
    break;
  case REGIONFUNCTION:
    printf("FUNCTION ");
    break;
  case REGIONLABEL:
    printf("LABEL ");
    break;
  case REGIONCONST:
    printf("CONST ");
    break;
  case REGIONSTRING:
    printf("STRING ");
    break;

  default:
    printf("%d ", locationData->region);
    break;
  }
  printf("%d\n", locationData->offset);
}
struct Node *createTree(int category, char *categoryName, int size, ...)
{
  va_list valist;
  va_start(valist, size);

  struct Node *tree = calloc(1, sizeof(struct Node));
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
