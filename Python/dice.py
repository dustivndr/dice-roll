from enum import Enum
from random import randint
from time import sleep
from os import system, name

# pip install keyboard
import keyboard as kb

class State(Enum):
    ROLL = 1
    EXIT = 2

def clear_screen():
    system(f'{'cls' if name == 'nt' else 'clear'}')

def show_dice(value):
    print('\n    +---+')
    print(f'    | {value} |')
    print('    +---+\n')

def display(dice, state):
    clear_screen()
    show_dice(dice)
    print(f' {'>' if state == State.ROLL else ' '} Roll the dice')
    print(f' {'>' if state == State.EXIT else ' '} Exit')

def shake_dice():
    new = 0
    for i in range(randint(5, 14)):
        new = randint(1, 6)
        clear_screen()
        show_dice(new)
        print(' > Rolling the dice...\n   Exit')
        sleep(0.1)

    return new

def main():
    val = 1
    state = State.ROLL
    while True:
        display(val, state)

        event = kb.read_event()
        if event.event_type != kb.KEY_DOWN:
            continue

        key = event.name.lower()
        if key in ('up', 'down', 'w', 's'):
            state = State.ROLL if state == State.EXIT else State.EXIT
        elif key == 'enter':
            if state == State.ROLL:
                val = shake_dice()
            else:
                return

if __name__ == '__main__':
    main()