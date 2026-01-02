#include <conio.h>
#include <windows.h>

// Things Fortran can't

char getch_wrapper() {
    return _getch();
}

void sleep_ms(int ms) {
    Sleep(ms);
}