#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linkedlist.h"

struct LinkedListNode *addToFront(struct Symbol *newData, struct LinkedListNode *head)
{
    struct LinkedListNode *newLinkedListNode = malloc(sizeof(struct LinkedListNode));
    newLinkedListNode->data = newData;
    if (head == NULL)
    {
        newLinkedListNode->next = NULL;
    }
    else
    {
        newLinkedListNode->next = head;
    }
    head = newLinkedListNode;
    return head;
}

struct LinkedListNode *addToEnd(struct Symbol *newData, struct LinkedListNode *head)
{
    struct LinkedListNode *currentNode = head;
    struct LinkedListNode *newNode = malloc(sizeof(struct LinkedListNode));
    newNode->data = newData;
    newNode->next = NULL;
    if (head == NULL)
    {
        head = newNode;
    }
    else
    {
        while (currentNode->next != NULL)
        {
            currentNode = currentNode->next;
        }
        currentNode->next = newNode;
    }
    return head;
}

void printLinkedList(struct LinkedListNode *head)
{
    struct LinkedListNode *current = head;
    while (current != NULL)
    {
        printData(current->data);
        current = current->next;
    }
}

void handleMissingTypes(struct LinkedListNode *head)
{

    if (head != NULL)
    {
        struct LinkedListNode *current = head;
        while (current != NULL)
        {
            if (current->data->type == -1)
            {
                updateWithNextTypeInformation(current);
            }
            current = current->next;
        }
    }
}

void updateWithNextTypeInformation(struct LinkedListNode *current)
{
    if (current->next == NULL)
    {
        // Do nothing
    }
    else
    {
        // Go to the end
        updateWithNextTypeInformation(current->next);
        // check to see if we need to pull the data from the next one
        if (current->next->data->type != -1 && current->data->type == -1)
        {
            current->data->type = current->next->data->type;
            current->data->typeName = strdup(current->next->data->typeName);
        }
    }
}

void printData(struct Symbol *data)
{
    if (data == NULL)
    {
        printf("Empty Linked List Found\n");
    }
    else
    {

        printf("\t%s %s", data->name, data->typeName);
        if (data->isConst)
        {
            printf(" const");
        }
        else if (data->arraySize >= 0)
        {
            printf(" array with size %d", data->arraySize);
        }
        printf("\n");
    }
}

int isVariableInLinkedList(char *variableName, struct LinkedListNode *head)
{
    struct LinkedListNode *current = head;
    if (head == NULL)
    {
        return 0;
    }
    else
    {
        if (strcmp(current->data->name, variableName) == 0)
        {
            return 1;
        }
        // traverse to end
        while (current->next != NULL)
        {
            if (strcmp(current->data->name, variableName) == 0)
            {
                // found it
                return 1;
            }
            else
            {
                current = current->next;
            }
        }
    }
    return 0;
}

int findTypeInLinkedList(char *variableName, struct LinkedListNode *head)
{
    struct LinkedListNode *current = head;
    if (head == NULL)
    {
        return -1;
    }
    else
    {
        if (strcmp(current->data->name, variableName) == 0)
        {
            return current->data->type;
        }
        // traverse to end
        while (current->next != NULL)
        {
            if (strcmp(current->data->name, variableName) == 0)
            {
                // found it
                return current->data->type;
            }
            else
            {
                current = current->next;
            }
        }
    }
    return -1;
}

int compareLinkedLists(struct LinkedListNode *typeList, struct LinkedListNode *paramList)
{
    if (typeList != NULL && paramList != NULL)
    {
        struct LinkedListNode *currentType = typeList;
        struct LinkedListNode *currentParam = paramList;

        while (currentType != NULL && currentParam != NULL)
        {
            if (currentType->data->type == currentParam->data->type)
            {
                currentType = currentType->next;
                currentParam = currentParam->next;
            }

            else
            {
                return 0;
            }
        }
        return 1;
    }
    else
    {
        return 0;
    }
}

char *findTypeNameInLinkedList(char *variableName, struct LinkedListNode *head)
{
    struct LinkedListNode *current = head;
    if (head == NULL)
    {
        printf("Table with name %s is not found\n", variableName);
        exit(3);
    }
    else
    {
        if (strcmp(current->data->name, variableName) == 0)
        {
            return current->data->typeName;
        }
        // traverse to end
        while (current->next != NULL)
        {
            if (strcmp(current->data->name, variableName) == 0)
            {
                // found it
                return current->data->typeName;
            }
            else
            {
                current = current->next;
            }
        }
    }
    printf("Table with name %s is not found\n", variableName);
    exit(3);
    return "";
}