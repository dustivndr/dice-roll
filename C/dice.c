#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef enum {
    KEY_UP,
    KEY_DOWN,
    KEY_ENTER,
    KEY_W,
    KEY_S,
    KEY_OTHER,
    KEY_NONE,
} Key;

// for windows
#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#define ossleep(ms) Sleep(ms)

Key get_input(void) {
    int inp = _getch();
    switch (inp) {
        case 0:
        case 224:
            inp = _getch();
            if (inp == 72) {
                return KEY_UP;
            } else if (inp == 80) {
                return KEY_DOWN;
            }
            break;
        case 'W':
        case 'w':
            return KEY_W;
        case 'S':
        case 's':
            return KEY_S;
        case 13:
            return KEY_ENTER;
    }

    return KEY_OTHER;
}

void clear_screen(void) {system("cls");};

#else

// jika memakai linux ato macos hrs pake enter key
// gara2 aku gk paham cara buat tanpa perlu :)
#include <unistd.h>
#define ossleep(ms) sleep((ms) / 1000)

Key get_input(void) {
    char inp;
    scanf(" %c[^\n]", &inp);

    switch (inp) {
        case 0:
        case 224:
            scanf(" %c[^\n]", &inp);
            if (inp == 72) {
                return KEY_UP;
            } else if (inp == 80) {
                return KEY_DOWN;
            }
            break;
        case 'W':
        case 'w':
            return KEY_W;
        case 'S':
        case 's':
            return KEY_S;
        case 13:
            return KEY_ENTER;
    }

    return KEY_OTHER;
}

void clear_screen(void) {system("clear")};

#endif

typedef enum {
    ROLL, EXIT
} State;

void clear_screen(void);
void show_dice(const int dice);
void shake_dice(int* dice);
void display(const int dice, const State state);
void handle_input(State* state, const Key inp, int* dice);

int main(int argc, char** argv) {
    srand(time(NULL));
    int dice = 1;
    State state = ROLL;
    while (TRUE) {
        display(dice, state);

        inp_start:
        Key key = get_input();
        if (key == KEY_OTHER)
            goto inp_start;
        handle_input(&state, key, &dice);
    }
}

void show_dice(const int dice) {
    printf("\n    +---+");
    printf("\n    | %d |", dice);
    printf("\n    +---+\n\n");
}

void shake_dice(int* dice) {
    for (int i = 0, n = rand() % 10 + 5; i < n; ++i) {
        *dice = rand() % 6 + 1;
        clear_screen();
        show_dice(*dice);
        printf(" > Rolling the dice...\n");
        printf("   Exit\n");
        ossleep(100);
    }
}

void display(const int dice, const State state) {
    clear_screen();
    show_dice(dice);
    printf(" %c Rolling the dice...\n", (state == ROLL ? '>' : ' '));
    printf(" %c Exit\n", (state == EXIT ? '>' : ' '));
}

void handle_input(State* state, const Key inp, int* dice) {
    switch (inp) {
        case KEY_UP:
        case KEY_DOWN:
        case KEY_W:
        case KEY_S:
            if (*state == ROLL)
                *state = EXIT;
            else
                *state = ROLL;
            return;
        case KEY_ENTER:
            if (*state == ROLL)
                shake_dice(dice);
            else
                exit(0);
    }
}