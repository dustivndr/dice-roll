#include <iostream>
#include <cstdlib>
#include <ctime>
#include <windows.h>
#include <conio.h>

void showDice(int diceValue)
{
    std::cout << "\n    +---+";
    std::cout << "\n    | " << diceValue << " |";
    std::cout << "\n    +---+ \n\n";
}

void shakeDice(int &diceValue)
{
    int n = rand() % 10 + 5;
    for (int i = 0; i < n; i++)
    {
        diceValue = rand() % 6 + 1;
        system("cls");
        showDice(diceValue);
        std::cout << " > Rolling the dice..." << std::endl;
        std::cout << "   Exit" << std::endl;
        Sleep(100);
    }
}

int main()
{
    srand(time(0));
    int diceValue = 1;
    bool roll = true;
    while(true)
    {
        system("cls");

        showDice(diceValue);
        
        std::cout << ( roll ? " > Roll the dice" : "   Roll the dice" ) << std::endl;
        std::cout << ( !roll ? " > Exit" : "   Exit" ) << std::endl;

        int key = _getch();
        if (key == 0 || key == 224)
        {
            int key2 = _getch();
            if (key2 == 72 || key2 == 80)
                roll = !roll;
        }
        else if (key == 13)
        {
            if (roll)
                shakeDice(diceValue);
            else
                return 0;
        }
    }

    return 0;
}