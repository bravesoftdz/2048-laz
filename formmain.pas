unit formMain; {$mode objfpc} {$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Math, LCLType;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnReset: TButton;
    procedure btnResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
  const
    DirUp = 0;
    DirDown = 1;
    DirLeft = 2;
    DirRight = 3;
    DocMargin = 15;
    TileMargin = 14;
    TileWidth = 107;
    TileCountX = 4;
    TileCountY = 4;
    StyleBackgr: array [0..7] of integer = ($B4C0CD, $dae4ee, $c8e0ed, $79b1f2, $6395f5, $5f7cf6, $3b5ef6, $72cfed);
    StyleFColor: array [0..7] of integer = ($656e77, $656e77, $656e77, $f2f6f9, $f2f6f9, $f2f6f9, $f2f6f9, $f2f6f9);
  var
    EmptyCount: integer;
    Initialised: boolean;
    panel: array [0..TileCountY - 1, 0..TileCountX - 1] of TPanel;
    board: array [0..TileCountY - 1, 0..TileCountX - 1] of integer;
  private
    function Runtuhkan(Direction: integer): integer;
    function Gabungkan(Direction: integer): integer;
    procedure NewTiles;
    procedure Draw;
  end;

var
  Form1: TForm1;

implementation {$R *.lfm}

procedure swap(var x, y: integer);
var
  z: integer;
begin
  z := x;
  x := y;
  y := z;
end;

function TForm1.Runtuhkan(direction: integer): integer;
var
  v, w, x, y, z: integer;
  adaswap: boolean;
begin
  v := 0;

  if (direction = dirDown) or (direction = dirright) then
  begin
    w := 1;
    z := -1;
  end;

  if (direction = dirup) or (direction = dirleft) then
  begin
    w := -1;
    z := 0;
  end;

  if (Direction = dirDown) or (Direction = dirUp) then
    repeat
      adaswap := False;
      for x := 0 to TileCountX - 1 do
        for y := TileCountY - 1 + z downto 1 + z do
          if (board[y + w, x] = 0) and (board[y, x] <> 0) then
          begin
            swap(board[y + w, x], board[y, x]);
            adaswap := True;
            Inc(v);
          end;
    until adaswap = False;

  if (Direction = dirRight) or (Direction = dirLeft) then
    repeat
      adaswap := False;
      for y := 0 to TileCountY - 1 do
        for x := TileCountX - 1 + z downto 1 + z do
          if (board[y, x + w] = 0) and (board[y, x] <> 0) then
          begin
            swap(board[y, x + w], board[y, x]);
            adaswap := True;
            Inc(v);
          end;
    until adaswap = False;

  Result := v;
end;

function TForm1.Gabungkan(Direction: integer): integer;
var
  x, y, z: integer;
begin
  z := 0;
  if (direction = dirDown) then
    for x := 0 to TileCountX - 1 do
      for y := TileCountY - 1 downto 1 do
        if ((board[y, x] = board[y - 1, x]) and (board[y, x] <> 0)) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y - 1, x] := 0;
          Inc(EmptyCount);
          Inc(z, 2 * board[y, x]);
        end;

  if (direction = dirUp) then
    for x := 0 to TileCountX - 1 do
      for y := 0 to TileCountY - 2 do
        if (board[y, x] = board[y + 1, x]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y + 1, x] := 0;
          Inc(EmptyCount);
          Inc(z, 2 * board[y, x]);
        end;

  if (direction = dirRight) then
    for y := 0 to TileCountY - 1 do
      for x := TileCountX - 1 downto 1 do
        if (board[y, x] = board[y, x - 1]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y, x - 1] := 0;
          Inc(EmptyCount);
          Inc(z, 2 * board[y, x]);
        end;

  if (direction = dirLeft) then
    for y := 0 to TileCountY - 1 do
      for x := 0 to TileCountX - 2 do
        if (board[y, x] = board[y, x + 1]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y, x + 1] := 0;
          Inc(EmptyCount);
          Inc(z, 2 * board[y, x]);
        end;

  Result := z;
end;

procedure TForm1.Draw;
var
  x, y, z: integer;
begin
  for y := 0 to TileCountY - 1 do
    for x := 0 to TileCountX - 1 do
    begin
      z := 0;
      while ((Board[y, x] div Round(Power(2, z)) > 1) and (z <= 7)) do
        Inc(z);

      panel[y, x].Color := StyleBackgr[z];
      panel[y, x].Font.color := StyleFColor[z];

      if (z > 0) then
        panel[y, x].Caption := IntToStr(Board[y, x])
      else
        panel[y, x].Caption := '';
    end;
end;

procedure TForm1.NewTiles;
var
  x, y: integer;
begin
  Randomize;
  Dec(EmptyCount);
  repeat
    x := Random(TileCountX);
    y := Random(TileCountY);
  until (Board[y, x] = 0);

  if (Random < 0.9) then
    Board[y, x] := 2
  else
    Board[y, x] := 4;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Initialised := False;
end;

procedure TForm1.btnResetClick(Sender: TObject);
begin
  FormShow(self);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  swaps, score: integer;
begin
  if (key = vk_down) then
  begin
    swaps := Runtuhkan(dirDown);
    score := Gabungkan(dirDown);
    Runtuhkan(dirDown);
  end
  else if (key = vk_up) then
  begin
    swaps := Runtuhkan(dirUp);
    score := Gabungkan(dirUp);
    Runtuhkan(dirUP);
  end
  else if (key = vk_left) then
  begin
    swaps := Runtuhkan(dirLeft);
    score := Gabungkan(dirLeft);
    Runtuhkan(dirLeft);
  end
  else if (key = vk_right) then
  begin
    swaps := Runtuhkan(dirRight);
    score := Gabungkan(dirRight);
    Runtuhkan(dirRight);
  end;

  key := 0;

  if EmptyCount = 0 then //TODO: Check any possibilities
    Application.MessageBox('You have lost.', 'Message', mb_iconInformation);

  if (emptyCount > 0) and (Z > 0) then
    NewTiles;

  Draw;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  x, y: integer;
begin
  Width := 2 * DocMargin + (TileCountX - 1) * TileMargin + (TileCountX) * TileWidth;
  Height := Width + 80;

  EmptyCount := TileCountY * TileCountX;

  for y := 0 to TileCountY - 1 do
    for x := 0 to TileCountX - 1 do
    begin
      Board[y, x] := 0;
      if not initialised then
      begin
        Panel[y, x] := TPanel.Create(Self);
        with panel[y, x] do
        begin
          Parent := Self;
          Font.Size := 32;
          BevelOuter := bvNone;
          Font.Quality := fqClearType;
          Name := 'Panel' + IntToStr(x) + IntToStr(y);
          SetBounds(DocMargin + TileMargin * x + TileWidth * x,
            DocMargin + TileMargin * y + TileWidth * y,
            TileWidth,
            TileWidth);
          OnKeyDown := @FormKeyDown;
        end;
      end;
    end;

  Initialised := True;
  NewTiles;
  NewTiles;
  Draw;
end;

end.