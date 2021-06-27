program Game;

const
	ScreenW = 64;
	ScreenH = 22;
	PaddleStartW = 10;
	BlockW = 8;
	BlockH = 1;
	BlockRowCount = 5;
	BlockColCount = 8;
	BallTimer = 5;

var
	ballX: Byte;
	ballY: Byte;
	ballDX: Byte;
	ballDY: Byte;
	ballCounter: Byte;

	paddleX: Byte;
	paddleW: Byte;
	paddleChar: Byte;

	i: Byte;
	j: Byte;
	x: Byte;
	y: Byte;
	colorCounter: Byte;
	blockCounter: Byte;

	key1: Byte;
	key2: Byte;

	blocks: array[1..8, 1..5] of byte;

procedure DrawBall;
begin
	Color($47);
	{
	GotoXY(ballX, ballY);
	Write('O');
	}
	WindowSet(ballX/2,ballY,1,1);
	WindowGet;
	SpritePutXor(BallSprite, $47, ballX/2, ballY);
end;

procedure DrawPaddle;
begin
	Color($47);
	GotoXY(paddleX, ScreenH);
	for i := 1 to paddleW do
		Write('=');
end;

procedure DrawBlock;
begin
	for y := 1 to BlockH do begin
		GotoXY((j - 1) * BlockW, (i - 1) * BlockH + y - 1);
		for x := 1 to BlockW do begin
			Write(' ');
		end;
	end;
end;

procedure Reset;
begin
	Color($47);
	ClrScr;

	ballX := ScreenW / 2;
	ballY := ScreenH - 1;
	ballDX := 1;
	ballDY := $ff;
	ballCounter := BallTimer;

	paddleW := PaddleStartW;
	paddleX := (ScreenW - PaddleStartW) / 2;

	colorCounter := $4f;
	for i := 1 to BlockRowCount do begin
		for j := 1 to BlockColCount do begin
			blocks[j, i] := 1;
			Color(colorCounter);
			DrawBlock;
			if colorCounter = $7f then
				colorCounter := $4f
			else
				colorCounter := colorCounter + $08;
		end;
	end;

	DrawBall;
	DrawPaddle;
end;

procedure GameOver;
begin
	Color($57);
	ClrScr;
	repeat
		ReadKey(key1, key2);
	until key1 <> 0;
	Reset;
end;

procedure GameWin;
begin
	Color($67);
	ClrScr;
	repeat
		ReadKey(key1, key2);
	until key1 <> 0;
	Reset;
end;

procedure MoveBall;
begin
	if ballY = (ScreenH-1) then begin
		if (ballX >= paddleX) and (ballX < (paddleX + paddleW)) then begin
			ballDY := $ff
			if ballDX < $80 then begin
				ballDX := 1 + Random(1);
			end else begin
				ballDX := $ff - Random(1);
			end
		end else
			GameOver;
	end;

	{
	GotoXY(ballX, ballY);
	Write(' ');
	}
	WindowSet(ballX/2,ballY,1,1);
	WindowPut;

	blockCounter := 0;
	for i := 1 to BlockRowCount do begin
		for j := 1 to BlockColCount do begin
			if blocks[j, i] <> 0 then begin
				blockCounter := blockCounter + 1;
				x := (j - 1) * BlockW;
				y := (i - 1) * BlockH;
				if (ballX >= x) and (ballX < (x + BlockW)) and (ballY >= y) and (ballY < (y + BlockH)) then begin
					blocks[j, i] := 0;
					Color($47);
					DrawBlock;

					if ballX = x then ballDX := $ff;
					if ballX = (x + BlockW - 1) then ballDX := 1;

					if ballDY = $ff then
						ballDY := 1
					else
						if (ballDY = 1) and (ballY > 0) then
							ballDY := $ff;

					SoundEffect(1,100,255);
				end;
			end;
		end;
	end;

	ballX := ballX + ballDX;
	ballY := ballY + ballDY;
	if ballX = 0 or ballX = $ff then begin
		ballDX := 1;
		ballX := 0;
	end;
	if ballX >= (ScreenW-1) then begin
		ballX := ScreenW-1;
		ballDX := $ff;
	end;

	if ballY = 0 then ballDY := 1;

	DrawBall;

	if blockCounter = 0 then
		GameWin;
end

procedure ClearPaddle;
begin
	GotoXY(paddleX, ScreenH);
	for i := 1 to paddleW do
		Write(' ');
end;

begin
	Reset;

	while 1 do begin
		Asm(Halt);

		ballCounter := ballCounter - 1;
		if ballCounter = 0 then begin
			ballCounter := BallTimer;
			MoveBall;
		end;

		ReadKey(key1, key2);
		case key1 of
			79: begin
				ClearPaddle;
				if paddleX > 0 then paddleX := paddleX - 1;
				DrawPaddle;
				end;

			80: begin
				ClearPaddle;
				if (paddleX + paddleW) < ScreenW then paddleX := paddleX + 1;
				DrawPaddle;
				end;
		end;
	end;
end.

HALT:		halt
			ret

BALLSPRITE:
    DEFB 1
    DEFB 0,0, 60,66,129,165,129,153,66,60
