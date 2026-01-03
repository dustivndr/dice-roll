program DiceRoll;

uses crt; { Standard unit for terminal control }

{ Basic procedure to draw the dice based on view.txt template }
procedure ShowDice(val: Integer);
begin
    Writeln('    +---+');
    Writeln('    | ', val, ' |');
    Writeln('    +---+');
    Writeln;
end;

begin
    ClrScr; { Clear screen }
    ShowDice(1);
    Writeln(' > Roll the dice');
    Writeln('   Exit');
    
    Writeln;
    Write('Press any key to exit setup test...');
    ReadKey;
end.