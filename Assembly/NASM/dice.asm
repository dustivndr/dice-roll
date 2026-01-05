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
	push    dword 0          ; push NULL arg
	call    time             ; returns current unix timestamp in eax
	add     esp, 4           ; clean stack
	push    eax              ; push timestamp as seed
	call    srand            ; seed the random generator
	add     esp, 4           ; clean stack

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

	cmp     al, 27          ; ESC sequence for arrows (27 is escape char)
	je      handle_arrow

	cmp     al, 10          ; LF (line feed / newline)
	je      handle_enter
	cmp     al, 13          ; CR (carriage return / enter)
	je      handle_enter
	jmp     main_loop

handle_arrow:
	; Parse ESC [ A/B for up/down
	mov     bl, [keybuf+1]   ; load 2nd byte of key sequence into BL
	mov     bh, [keybuf+2]   ; load 3rd byte of key sequence into BH
	cmp     bl, '['          ; check if 2nd char is '[' (valid arrow)
	jne     main_loop        ; if not, ignore
	cmp     bh, 'A'          ; Up arrow code is ESC[A
	je      toggle_opt
	cmp     bh, 'B'          ; Down arrow code is ESC[B
	je      toggle_opt
	jmp     main_loop

toggle_opt:
	; Flip selection
	xor     dword [rollFlag], 1  ; toggle rollFlag between 0 and 1
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
	push    dword 3          ; 3rd arg: count = 3 bytes
	push    keybuf           ; 2nd arg: buffer address
	push    dword 0          ; 1st arg: fd = 0 (stdin)
	call    read             ; read up to 3 bytes from stdin
	add     esp, 12          ; clean stack (3 args × 4 bytes)
	mov     al, [keybuf]     ; load first byte into AL (return value)
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
	push    dword [diceValue]  ; 2nd arg: current dice value
	push    dice_fmt           ; 1st arg: format string
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
	sub     esp, 4           ; local: counter at [ebp-4]

	call    rand             ; get random number in EAX
	mov     ebx, 10          ; divisor = 10
	cdq                      ; sign extend EAX to EDX:EAX
	idiv    ebx              ; EAX = EAX/10, EDX = EAX%10
	lea     ecx, [edx+5]     ; ECX = (rand % 10) + 5 = 5..14 iterations
	mov     [ebp-4], ecx     ; store in local counter

shake_loop:
	call    rand             ; get random number in EAX
	mov     ebx, 6           ; divisor = 6
	cdq                      ; sign extend EAX to EDX:EAX
	idiv    ebx              ; EAX = EAX/6, EDX = EAX%6
	inc     edx              ; EDX = (rand % 6) + 1 = dice 1..6
	mov     [diceValue], edx ; store new random value

	call    clear_screen
	call    show_dice
	push    rolling_str
	call    printf
	add     esp, 4
	push    exit_unsel_str
	call    printf
	add     esp, 4

	push    dword 100000     ; 100ms
	call    usleep           ; sleep for 100ms
	add     esp, 4           ; clean stack

	dec     dword [ebp-4]    ; decrement loop counter
	jnz     shake_loop

	leave
	ret
