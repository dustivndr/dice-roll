#include <stdlib.h>
#include <time.h>

void showDice(I64 diceValue)
{
    Print("\n    +---+");
    Print("\n    | %d |", diceValue);
    Print("\n    +---+ \n\n");
}

void shakeDice(I64 *diceValue)
{
    I64 n = rand() % 10 + 5;
    I64 i;
    for (i = 0; i < n; i++)
    {
        *diceValue = rand() % 6 + 1;
        system("cls");
        showDice(*diceValue);
        Print(" > Rolling the dice...\n");
        Print("   Exit\n");
        Sleep(100);
    }
}

void main()
{
    srand(time(NULL));
    I64 diceValue = 1;
    Bool roll = TRUE;
    
    while(TRUE)
    {
        system("cls");

        showDice(diceValue);
        
        Print(roll ? " > Roll the dice\n" : "   Roll the dice\n");
        Print(!roll ? " > Exit\n" : "   Exit\n");

        U8 key = GetKey();
        
        if (key == 0 || key == 224)
        {
            U8 key2 = GetKey();
            if (key2 == 72 || key2 == 80)
                roll = !roll;
        }
        else if (key == 13)
        {
            if (roll)
                shakeDice(&diceValue);
            else
                return;
        }
    }
}
