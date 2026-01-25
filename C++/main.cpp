#include <iostream>
#include <cstdlib>
#include <ctime>
#include <chrono>
#include <thread>

#ifdef _WIN32
    #include <windows.h>
    #include <conio.h>
#else
    #include <unistd.h>
    #include <termios.h>
    #include <sys/ioctl.h>
#endif

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
        #ifdef _WIN32
            system("cls");
        #else
            system("clear");
        #endif
        showDice(diceValue);
        std::cout << " > Rolling the dice..." << std::endl;
        std::cout << "   Exit" << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

#ifndef _WIN32
static struct termios old_settings, new_settings;
static bool term_initialized = false;

void initTerminal()
{
    if (!term_initialized) {
        tcgetattr(STDIN_FILENO, &old_settings);
        new_settings = old_settings;
        new_settings.c_lflag &= ~(ICANON | ECHO);
        new_settings.c_cc[VMIN] = 1;
        new_settings.c_cc[VTIME] = 0;
        tcsetattr(STDIN_FILENO, TCSANOW, &new_settings);
        term_initialized = true;
    }
}

void restoreTerminal()
{
    if (term_initialized) {
        tcsetattr(STDIN_FILENO, TCSANOW, &old_settings);
        term_initialized = false;
    }
}

int getKeyLinux()
{
    int ch = getchar();
    
    if (ch == 27) {  // ESC sequence
        int ch2 = getchar();
        if (ch2 == 91) {  // '['
            int ch3 = getchar();
            if (ch3 == 65)      // Up arrow
                return 1001;
            else if (ch3 == 66) // Down arrow
                return 1002;
        }
    }
    return ch;
}
#endif

int main()
{
    #ifndef _WIN32
        initTerminal();
    #endif
    
    srand(time(0));
    int diceValue = 1;
    bool roll = true;
    while(true)
    {
        #ifdef _WIN32
            system("cls");
        #else
            system("clear");
        #endif

        showDice(diceValue);
        
        std::cout << ( roll ? " > Roll the dice" : "   Roll the dice" ) << std::endl;
        std::cout << ( !roll ? " > Exit" : "   Exit" ) << std::endl;

        #ifdef _WIN32
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
                {
                    restoreTerminal();
                    return 0;
                }
            }
        #else
            int key = getKeyLinux();
            if (key == 1001 || key == 1002)  // Up or Down arrow
            {
                roll = !roll;
            }
            else if (key == 10 || key == 13)  // Enter
            {
                if (roll)
                    shakeDice(diceValue);
                else
                {
                    restoreTerminal();
                    return 0;
                }
            }
        #endif
    }

    return 0;
}