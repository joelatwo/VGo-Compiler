#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linkedlist.h"
struct Node *head = NULL;
void addToEnd(struct Token *newData)
{
    struct Node *currentNode = head;
    if (head == NULL)
    {
        struct Node *newNode = malloc(sizeof(struct Node));
        newNode->data = newData;
        newNode->next = NULL;
        head = newNode;
    }
    else
    {
        while (currentNode->next != NULL)
        {
            currentNode = currentNode->next;
        }
        struct Node *newNode = malloc(sizeof(struct Node));
        newNode->next = NULL;
        newNode->data = newData;
        currentNode->next = newNode;
    }
}

void printList()
{
    printf("Category\tText\tLineno\tFilename\tIval/Sval\n");
    printf("---------------------------------------------------------\n");
    struct Node *node = head;
    while (node != NULL)
    {
        printData(node->data);
        node = node->next;
    }
}

void printData(struct Token *data)
{
    printf("%d\t%s\t%d\t%s\t", data->category, data->text, data->linenumber, data->filename);

    if (data->category == 339 || data->category == 352 || data->category == 370)
    {
        printf("%d\t", data->ival);
    }
    else if (data->category == 355 || data->category == 371)
    {
        printf("%lf\t", data->dval);
    }
    else if (data->category == 356 || data->category == 338)
    {
        printf("%s\t", data->sval);
    }
    else
    {
        printf("\t");
    }
    printf("|\n");
}

void deleteLinkedList()
{
    struct Node *node = head;
    struct Node *toBeDeleted;
    while (node->next != NULL)
    {
        toBeDeleted = node;
        node = node->next;
        free(toBeDeleted->data);
        free(toBeDeleted);
    }
    free(node->data);
    free(node);
}