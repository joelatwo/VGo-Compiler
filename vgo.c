#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vgo.tab.h"

char *sanitizeFile(char *filename)
{
    if (strstr(filename, ".go\0") != NULL)
    {
        // good we have the correct file extension
        return filename;
    }
    else
    {
        // add file extension .go in case the .go was ommitted
        char *newFilename = (char *)malloc(strlen(filename) + strlen(".go") + 1);
        newFilename = strcpy(newFilename, filename);
        newFilename = strcat(newFilename, ".go");
        return newFilename;
    }
}

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        int i;
        for (i = 1; i < argc; i++)
        {
            char *sanatizedFile = sanitizeFile(argv[i]);
            if (sizeof(sanatizedFile) > 0)
            {
                // valid file feel free to continue

                yyin = fopen(sanatizedFile, "r");
                currentfile = sanatizedFile;

                if (yyin == NULL)
                {
                    // do note that it is possible that this is a valid .go file but the user will resubmit if that happens
                    perror("This is not a .go file\n");
                }
                else
                {
                    while (yylex() > 0)
                    {
                    }
                    fclose(yyin);
                }
            }
            else
            {
                return 1;
            }
        }
        return 0;
    }
    else
    {
        perror("Please provide files in the command line to compile");
        return 1;
    }
}

// notes
// string escape characters char escape characters
