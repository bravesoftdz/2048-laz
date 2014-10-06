unit formMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Math, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
  private
  const
    DocMargin = 15;
    TileMargin = 14;
    TileWidth = 107;
    TileCountX = 4;
    TileCountY = 4;
    DirUp = 0;
    DirDown = 1;
    DirLeft = 2;
    DirRight = 3;
  var
    FromReset: boolean;
    emptycount: integer;
    baru1, baru2: TPoint;
    panel: array [0..TileCountY - 1, 0..TileCountX - 1] of TPanel;
    board: array [0..TileCountY - 1, 0..TileCountX - 1] of integer;
  private
    function Runtuhkan(Direction: integer): integer;//seperti soal tokilearning :v
    function Gabungkan(Direction: integer): integer; //yang ini bukan :v
  public
    procedure NewTiles(Count: integer);
    procedure Draw;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure swap(var x, y: integer);
var
  z: integer;
begin
  z := x;
  x := y;
  y := z;
end;

function make_point(x, y: integer): TPoint;
begin
  Result.X := x;
  Result.y := y;
end;

function antipow2(x: integer): integer;
begin
  Result := 0;
  while (x > 1) do
  begin
    Inc(Result);
    x := x div 2;
  end;
end;

function TForm1.Runtuhkan(direction: integer): integer;
var
  v, w, x, y, z: integer;
  adaswap: boolean;
begin
  v := 0;
  //agak susah dibaca tapi menghemat banyak tempat. good luck. :v
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
    until adaswap = False
  else
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
  //i don't think if i can simplying this section
  z := 0;
  if (direction = dirDown) then
    for x := 0 to TileCountX - 1 do
      for y := TileCountY - 1 downto 1 do
        if ((board[y, x] = board[y - 1, x]) and (board[y, x] <> 0)) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y - 1, x] := 0;
          Inc(EmptyCount);
          Inc(z);
        end;
  if (direction = dirUp) then
    for x := 0 to TileCountX - 1 do
      for y := 0 to TileCountY - 2 do
        if (board[y, x] = board[y + 1, x]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y + 1, x] := 0;
          Inc(EmptyCount);
          Inc(z);
        end;
  if (direction = dirRight) then
    for y := 0 to TileCountY - 1 do
      for x := TileCountX - 1 downto 1 do
        if (board[y, x] = board[y, x - 1]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y, x - 1] := 0;
          Inc(EmptyCount);
          Inc(z);
        end;
  if (direction = dirLeft) then
    for y := 0 to TileCountY - 1 do
      for x := 0 to TileCountX - 2 do
        if (board[y, x] = board[y, x + 1]) and (board[y, x] <> 0) then
        begin
          board[y, x] := 2 * board[y, x];
          board[y, x + 1] := 0;
          Inc(EmptyCount);
          Inc(z);
        end;
  Result := z;
end;

procedure TForm1.Draw;
const
  style_bgc: array [0..7] of integer =
    ($B4C0CD, $dae4ee, $c8e0ed, $79b1f2, $6395f5, $5f7cf6, $3b5ef6, $72cfed);
  style_mnc: array [0..7] of integer =
    ($656E77, $656E77, $656E77, $f2f6f9, $f2f6f9, $f2f6f9, $f2f6f9, $f2f6f9);
var
  x, y, p: integer;
begin
  try
    for y := 0 to TileCountY - 1 do
      for x := 0 to TileCountX - 1 do
      begin
        p := antipow2(Board[y, x]);

        if (p <= 7) then
        begin
          panel[y, x].Color := style_bgc[p];
          panel[y, x].Font.color := style_mnc[p];
        end
        else
        begin
          panel[y, x].Color := TColor(style_bgc[7]);
          panel[y, x].Font.color := style_mnc[7];
        end;

        if (p > 0) then
          panel[y, x].Caption := IntToStr(Board[y, x])
        else
          panel[y, x].Caption := '';
      end;

  except
    on e: Exception do
      ShowMessage('not stable as fuck.');
  end;
end;

procedure TForm1.NewTiles(Count: integer);
var
  x, y, i, cx, cy: integer;
  arr: array of TPoint;
begin
  randomize;
  for i := 0 to Count - 1 do
  begin
    while (True) do
    begin
      cx := random(TileCountX);
      cy := random(TileCountY);
      if (board[cy, cx] = 0) then
        break;
    end;
    //SetLength(arr, 0);
    //setlength(arr, emptycount);
    //idx := 0;
    //for y := 0 to TileCountY - 1 do
    //  for x := 0 to TileCountX - 1 do
    //    if Board[y, x] = 0 then
    //    begin
    //      arr[idx] := make_point(x, y);
    //      Inc(idx);
    //    end;

    //idx := Random(EmptyCount);
    Dec(EmptyCount);
    if (random < 0.9) then
      Board[cy, cx] := 2
    else
      Board[cy, cx] := 4;

    //if (random < 0.9) then
    //  Board[arr[idx].y, arr[idx].x] := 2
    //else
    //  Board[arr[idx].y, arr[idx].x] := 4;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  x, y: integer;
begin
  Width := 2 * DocMargin + (TileCountX - 1) * TileMargin + (TileCountX) * TileWidth;
  Height := Width + 80;
  emptycount := 16;
  for y := 0 to TileCountY - 1 do
    for x := 0 to TileCountX - 1 do
    begin
      Board[y, x] := 0;
      if not FromReset then
      begin
        Panel[y, x] := TPanel.Create(Self);
        with panel[y, x] do
        begin
          Parent := Self;
          Font.Size := 32;
          Color := $B4C0CD;
          BevelOuter := bvNone;
          Font.Quality := fqClearType;
          Name := 'panel' + IntToStr(x) + IntToStr(y);
          SetBounds(DocMargin + TileMargin * x + TileWidth * x,
            DocMargin + TileMargin * y + TileWidth * y,
            TileWidth,
            TileWidth);
          OnKeyDown := @FormKeyDown;
        end;
      end;
    end;
  NewTiles(2);
  Draw;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FromReset:=true;
  FormCreate(self);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  z, x, y: integer;
begin
  if (key = vk_down) then
  begin
    z := Runtuhkan(dirDown);
    Inc(z, Gabungkan(dirDown));
    Runtuhkan(dirDown);
  end
  else if (key = vk_up) then
  begin
    z := Runtuhkan(dirUp);
    Inc(z, Gabungkan(dirUp));
    Runtuhkan(dirUP);
  end
  else if (key = vk_left) then
  begin
    z := Runtuhkan(dirLeft);
    Inc(z, Gabungkan(dirLeft));
    Runtuhkan(dirLeft);
  end
  else if (key = vk_right) then
  begin
    z := Runtuhkan(dirRight);
    Inc(z, Gabungkan(dirRight));
    Runtuhkan(dirright);
  end;

  key := 0;

  if EmptyCount = 0 then begin
    Application.MessageBox('You have lost.', 'Message', mb_iconInformation);
  end;

  if (emptyCount > 0) and (Z > 0) then
    NewTiles(1);
  draw;
end;

end.
