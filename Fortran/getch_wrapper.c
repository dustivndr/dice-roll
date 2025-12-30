#include <conio.h>
#include <windows.h>

char getch_wrapper() {
    return _getch();
}

void sleep_ms(int ms) {
    Sleep(ms);
}