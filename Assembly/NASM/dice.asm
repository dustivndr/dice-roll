; NASM x86 Linux build
; gcc -m32 dice.o -o dice
; nasm -f elf32 dice.asm -o dice.o

global  main

extern  printf
extern  srand
extern  rand
extern  time
extern  usleep
extern  read
extern  system

section .data
	; Basic strings for screen control and UI
	clear_str          db  27,'[2J',27,'[H',0
	dice_fmt           db  13,10,'    +---+',13,10,'    | %d |',13,10,'    +---+',13,10,13,10,0
	roll_sel_str       db  ' > Roll the dice',13,10,0
	roll_unsel_str     db  '   Roll the dice',13,10,0
	exit_sel_str       db  ' > Exit',13,10,0
	exit_unsel_str     db  '   Exit',13,10,0
	rolling_str        db  ' > Rolling the dice...',13,10,0
	raw_cmd            db  'stty raw -echo',0
	sane_cmd           db  'stty sane',0

section .bss
	; State: current value, selection flag, raw key buffer
	diceValue  resd 1
	rollFlag   resd 1
	keybuf     resb 3

section .text

main:
	; Prologue
	push    ebp
	mov     ebp, esp

	; Seed rand(time(0))
	push    dword 0
	call    time
	add     esp, 4
	push    eax
	call    srand
	add     esp, 4

	; Put terminal in raw mode (no echo, no buffering)
	push    raw_cmd
	call    system
	add     esp, 4

	mov     dword [diceValue], 1
	mov     dword [rollFlag], 1

main_loop:
	; Draw screen
	call    clear_screen
	call    show_dice
	call    show_menu

	; Wait for key
	call    read_key

	cmp     al, 27          ; ESC sequence for arrows
	je      handle_arrow

	cmp     al, 10          ; LF
	je      handle_enter
	cmp     al, 13          ; CR
	je      handle_enter
	jmp     main_loop

handle_arrow:
	; Parse ESC [ A/B for up/down
	mov     bl, [keybuf+1]
	mov     bh, [keybuf+2]
	cmp     bl, '['
	jne     main_loop
	cmp     bh, 'A'         ; Up
	je      toggle_opt
	cmp     bh, 'B'         ; Down
	je      toggle_opt
	jmp     main_loop

toggle_opt:
	; Flip selection
	xor     dword [rollFlag], 1
	jmp     main_loop

handle_enter:
	; Enter triggers selected action
	cmp     dword [rollFlag], 0
	je      exit_clean
	call    shake_dice
	jmp     main_loop

exit_clean:
	; Restore terminal and exit
	push    sane_cmd
	call    system
	add     esp, 4
	mov     esp, ebp
	pop     ebp
	ret

; ----------------------------------------
read_key:
	; read(0, keybuf, 3) -> AL = first byte
	push    ebp
	mov     ebp, esp
	push    dword 3
	push    keybuf
	push    dword 0
	call    read
	add     esp, 12
	mov     al, [keybuf]
	leave
	ret

clear_screen:
	; printf ANSI clear + home
	push    ebp
	mov     ebp, esp
	push    clear_str
	call    printf
	add     esp, 4
	leave
	ret

show_dice:
	; printf dice ASCII art with value
	push    ebp
	mov     ebp, esp
	push    dword [diceValue]
	push    dice_fmt
	call    printf
	add     esp, 8
	leave
	ret

show_menu:
	; Show roll/exit with selection marker
	push    ebp
	mov     ebp, esp
	cmp     dword [rollFlag], 0
	je      menu_exit_selected

	push    roll_sel_str
	call    printf
	add     esp, 4
	push    exit_unsel_str
	call    printf
	add     esp, 4
	jmp     menu_done

menu_exit_selected:
	push    roll_unsel_str
	call    printf
	add     esp, 4
	push    exit_sel_str
	call    printf
	add     esp, 4

menu_done:
	leave
	ret

shake_dice:
	; Animate rolling: 5..14 iterations with sleep
	push    ebp
	mov     ebp, esp
	sub     esp, 4          ; local: counter

	call    rand
	mov     ebx, 10
	cdq
	idiv    ebx             ; edx = rand % 10
	lea     ecx, [edx+5]    ; 5..14 iterations
	mov     [ebp-4], ecx

shake_loop:
	call    rand
	mov     ebx, 6
	cdq
	idiv    ebx             ; edx = rand % 6
	inc     edx
	mov     [diceValue], edx

	call    clear_screen
	call    show_dice
	push    rolling_str
	call    printf
	add     esp, 4
	push    exit_unsel_str
	call    printf
	add     esp, 4

	push    dword 100000    ; 100ms
	call    usleep
	add     esp, 4

	dec     dword [ebp-4]
	jnz     shake_loop

	leave
	ret
