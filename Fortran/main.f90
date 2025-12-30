program rollDice
    use iso_c_binding
    implicit none

    integer :: diceValue
    logical :: roll
    character :: ch

    interface
        function getch_wrapper() bind(C, name="getch_wrapper")
            use iso_c_binding
            character(kind=c_char) :: getch_wrapper
        end function getch_wrapper
        subroutine sleep_ms(ms) bind(C, name="sleep_ms")
            use iso_c_binding
            integer(kind=c_int), value :: ms
        end subroutine sleep_ms
    end interface

    call random_seed()
    diceValue = 1
    roll = .true.

    do
        call clearScreen()
        call showDice(diceValue)
        if (roll) then
            print *, "> Roll the dice"
            print *, "  Exit"
        else
            print *, "  Roll the dice"
            print *, "> Exit"
        end if

        ch = getch_wrapper()

        if (ichar(ch) == 224) then ! Special key
            ch = getch_wrapper()
            select case (ichar(ch))
            case (72)  ! Up arrow
                roll = .not. roll
            case (80)  ! Down arrow
                roll = .not. roll
            end select
        else
            select case (ichar(ch))
            case (13)  ! Enter (CR)
                if (roll) then
                    call shakeDice(diceValue)
                else
                    stop
                end if
            end select
        end if
    end do

contains

    subroutine showDice(val)
        integer, intent(in) :: val
        print *, "   +---+"
        write(*, '(A,I0,A)') "    | ", val, " |"
        print *, "   +---+"
        print *, ""
    end subroutine showDice

    subroutine shakeDice(val)
        integer, intent(inout) :: val
        integer :: n, i
        real :: r
        call random_number(r)
        n = int(r * 10.0) + 5
        do i = 1, n
            call random_number(r)
            val = int(r * 6.0) + 1
            call clearScreen()
            call showDice(val)
            print *, "> Rolling the dice..."
            print *, "  Exit"
            call sleep_ms(100) 
        end do
    end subroutine shakeDice

    subroutine clearScreen()
        print '(A)', char(27)//"[2J"//char(27)//"[H"
    end subroutine clearScreen

end program rollDice
