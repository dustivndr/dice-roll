program DiceRoll;

uses crt; { Standart unit for terminal control }

var
  key: Char;
  isRollingSelected: Boolean;
  diceValue: Integer;

procedure ShowDice(val: Integer);
begin
  Writeln('    +---+');
  Writeln('    | ', val, ' |');
  Writeln('    +---+');
  Writeln;
end;

procedure ShakeDice(var val: Integer);
var
  i, iterations: Integer;
begin
  { Randomize roll duration }
  iterations := Random(10) + 5;
  for i := 1 to iterations do
  begin
    val := Random(6) + 1; { Random num 1-6 }
    ClrScr;
    ShowDice(val);
    Writeln(' > Rolling the dice...');
    Writeln('   Exit');
    Delay(100);
  end;
end;

procedure DisplayMenu(val: Integer; rollSelected: Boolean);
begin
  ClrScr;
  ShowDice(val);
  if rollSelected then
  begin
    Writeln(' > Roll the dice');
    Writeln('   Exit');
  end
  
  else
  begin
    Writeln('   Roll the dice');
    Writeln(' > Exit');
  end;
end;

begin
  Randomize;
  diceValue := 1;
  isRollingSelected := True;
  
  repeat
    DisplayMenu(diceValue, isRollingSelected);
    
    key := ReadKey;
    if key = #0 then { Arrow Keys }
    begin
      key := ReadKey;
      case key of
        #72, #80: isRollingSelected := not isRollingSelected; { Up & Down }
      end;
    end
    
    else if (key = 'w') or (key = 's') or (key = 'W') or (key = 'S') then
    begin
        isRollingSelected := not isRollingSelected;
      end
  
    else if (key = #13) then
    begin
      if isRollingSelected then
        ShakeDice(diceValue)
      else
        Break;
      end;
    
  until False;
  
  ClrScr;

end.