#include "location.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int counter = 0;

struct operation *createOperation(int opcode, struct location *left, struct location *right, struct location *destination)
{
    struct operation *newOperation = calloc(1, sizeof(struct operation));
    newOperation->opcode = opcode;
    newOperation->leftAddress = left;
    newOperation->rightAddress = right;
    newOperation->outAddress = destination;
    newOperation->next = NULL;

    return newOperation;
}

struct operation *combineLinkedList(struct operation *head, struct operation *tail)
{
    if (head == NULL)
    {
        if (tail != NULL)
        {
            return tail;
        }
        else
        {
            return NULL;
        }
    }
    if (tail != NULL)
    {
        struct operation *endOfHead = findLastOperation(head);
        endOfHead->next = tail;
    }
    return head;
}

struct operation *findLastOperation(struct operation *head)
{
    struct operation *current = head;
    while (current->next != NULL)
    {
        current = current->next;
    }
    return current;
}

void printOperationLinkedList(struct operation *head, char *filename)
{
    FILE *fp;
    int index = strlen(filename);
    filename[index - 2] = 'i';
    filename[index - 1] = 'c';
    fp = fopen(filename, "w");
    struct operation *current = head;
    while (current != NULL)
    {
        printOperationData(current, fp);
        current = current->next;
    }
    fclose(fp);
}

void printOperationData(struct operation *head, FILE *fp)
{
    if (head == NULL)
    {
        // do nothing
    }
    if (head->opcode != 0)
    {
        fprintf(fp, "%s\t", convertCodeToString(head->opcode));
    }

    if (head->leftAddress != NULL)
    {
        fprintf(fp, "leftAddress: %d %d\t", head->leftAddress->region, head->leftAddress->offset);
    }

    if (head->rightAddress != NULL)
    {
        fprintf(fp, "rightAddress: %d %d\t", head->rightAddress->region, head->rightAddress->offset);
    }

    if (head->outAddress != NULL)
    {
        fprintf(fp, "outAddress: %d %d\t", head->outAddress->region, head->outAddress->offset);
    }

    fprintf(fp, "\n");
}

char *convertCodeToString(int code)
{
    switch (code)
    {
    case O_ADD:
        return "ADD";
    case O_SUB:
        return "SUB";
    case O_MUL:
        return "MUL";
    case O_DIV:
        return "DIV";
    case O_NEG:
        return "NEG";
    case O_ASN:
        return "ASN";
    case O_ADDR:
        return "ADDR";
    case O_LCONT:
        return "LCONT";
    case O_SCONT:
        return "SCONT";
    case O_GOTO:
        return "GOTO";
    case O_BLT:
        return "BLT";
    case O_BLE:
        return "BLE";
    case O_BGT:
        return "BGT";
    case O_BGE:
        return "BGE";
    case O_BEQ:
        return "BEQ";
    case O_BNE:
        return "BNE";
    case O_BIF:
        return "BIF";
    case O_BNIF:
        return "BNIF";
    case O_PARM:
        return "PARM";
    case O_CALL:
        return "CALL";
    case O_RET:
        return "RET";

    case D_LABEL:
        return "LABEL";
    case O_ADD1:
        return "++";

    case O_SUB1:
        return "--";

    default:
        printf("ERROR CODE %d NOT DEFINED\n", code);
        exit(4);
        return "ERROR CODE NOT DEFINED";
    }
}

struct location *createLocation(int region, int *offset)
{
    struct location *newLocation = calloc(1, sizeof(struct location));
    newLocation->region = region;
    newLocation->offset = *offset;
    *offset += 8;
    return newLocation;
}
