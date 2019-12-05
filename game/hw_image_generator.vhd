LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY hw_image_generator IS
	PORT(
		lbutton, rbutton, sbutton, flag, clk	:	IN		STD_LOGIC; -- push buttons, 50MHz clock, ps2_new_code
		key												:	IN		STD_LOGIC_VECTOR(7 DOWNTO 0);  -- hex code from the ps2_keyboard interface
		disp_ena											:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row, column										:	IN		INTEGER;		--row pixel coordinate & column pixel coordinate
		red												:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green												:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue												:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --blue magnitude output to DAC
		hex0, hex1, hex2, hex4, hex5, hex6		:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)); 	-- 6 hex 7 segments (0 to 2 for current score, 4 to 6 for best score)
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
	COMPONENT HEX_DISPLAY IS
		PORT(	num:	IN		INTEGER;
				hex:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;

	TYPE		STATE_TYPE IS(STANDBY, EASY, MEDIUM, HARD, SUPERHARD);
	SIGNAL	state			: STATE_TYPE := STANDBY;
	SIGNAL 	gameover		: BOOLEAN;
	SIGNAL	started		: BOOLEAN;
	
	SIGNAL 	speedx, speedy: INTEGER;
	SIGNAL	x		: INTEGER := 600;
	SIGNAL 	y		: INTEGER := 200;
	
	SIGNAL	speed	: INTEGER;
	SIGNAL 	x1		: INTEGER := 300;
	SIGNAL 	y1		: INTEGER := 300;
	SIGNAL 	x2		: INTEGER := 500;
	SIGNAL 	y2		: INTEGER := 600;
	SIGNAL 	x3		: INTEGER := 700;
	SIGNAL 	y3		: INTEGER := 900;
	SIGNAL 	x4		: INTEGER := 900;
	SIGNAL 	y4		: INTEGER := 1200;
	
	SIGNAL	rx		: INTEGER := 1085;
	SIGNAL	ry		: INTEGER := 1160;
	SIGNAL	bar	: INTEGER RANGE 0 TO 4 := 0;
	SIGNAL 	prevbar: INTEGER RANGE 0 TO 4 := 0;
	
	SIGNAL	red1, red2, red3, red4 		: STD_LOGIC;
	SIGNAL	blue1, blue2, blue3, blue4	: STD_LOGIC;
	
	SIGNAL	points: INTEGER RANGE 0 TO 10:= 0;
	SIGNAL	score	: INTEGER RANGE 0 TO 999:= 0;
	SIGNAL	digit0: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit1: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit2: INTEGER RANGE 0 TO 9:= 0;
	
	SIGNAL	bestscore: INTEGER RANGE 0 TO 999:= 0;
	SIGNAL	digit4: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit5: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit6: INTEGER RANGE 0 TO 9:= 0;
	
	SIGNAL	c		 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	CONSTANT lhex 	: STD_LOGIC_VECTOR(7 DOWNTO 0):= x"6B";
	CONSTANT rhex 	: STD_LOGIC_VECTOR(7 DOWNTO 0):= x"74";
	
	SIGNAL clk50	:	INTEGER RANGE 0 TO 1000000;
	SIGNAL rand		:	INTEGER RANGE 0 TO 920;
BEGIN
	
	GAME_STATE: PROCESS(flag, key, state, score)
	BEGIN
		IF flag = '1' THEN
			IF c = "11110000" AND key /= "11100000" THEN
				c <= c;
			ELSE
				c <= key;
			END IF;
		END IF;
		
	
		IF gameover THEN					-- Changes game state based on the score, gameover condition, and the spacebar input
			state <= STANDBY;
		ELSE
			IF score >= 160 THEN
				state <= SUPERHARD;
			ELSIF score >= 60 THEN
				state <= HARD;
			ELSIF score >= 20 THEN
				state <= MEDIUM;
			ELSIF c = "01110010" OR sbutton = '0' OR score = 16 THEN
				state <= EASY;
			END IF;
		END IF;
	END PROCESS GAME_STATE;
	
	DRAW: PROCESS(disp_ena, row, column, clk)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			IF row > 300 AND row < 1620 AND column > 0 AND column < 1080 THEN		-- Draw the frame where the game takes place
				IF state = SUPERHARD THEN
					red <= (OTHERS => '1');
					green	<= "11010111";
					blue <= (OTHERS => '0');
				ELSIF state = HARD THEN
					red <= (OTHERS => '1');
					green	<= "10001100";
					blue <= (OTHERS => '0');
				ELSIF state = MEDIUM THEN
					red <= "11101110";
					green	<= "10000010";
					blue <= "11101110";
				ELSE
					red <= (OTHERS => '0');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '1');
				END IF;
			ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			------------------------------
			IF row > x AND row < x + 50 AND column > y AND column < y + 50 THEN		-- Draw the box representing the player
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			------------------------------
			IF row > x1 AND row < x1 + 400 AND column > y1 AND column < y1 + 40 THEN		-- Draw the first bar
				red <= (OTHERS => red1);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue1);
			END IF;
			--
			IF row > x2 AND row < x2 + 400 AND column > y2 AND column < y2 + 40 THEN		-- Draw the second bar
				red <= (OTHERS => red2);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue2);
			END IF;
			--
			IF row > x3 AND row < x3 + 400 AND column > y3 AND column < y3 + 40 THEN		-- Draw the third bar
				red <= (OTHERS => red3);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue3);
			END IF;
			--
			IF row > x4 AND row < x4 + 400 AND column > y4 AND column < y4 + 40 THEN		-- Draw the fourth bar
				red <= (OTHERS => red4);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue4);
			END IF;
			------------------------------
			IF row > rx AND row < rx + 30 AND column > ry AND column < ry + 30 THEN		-- Draw the box representing the reward
				IF (bar = 1 AND y1 + 40 < y) OR (bar = 2 AND y2 + 40 < y) OR (bar = 3 AND y3 + 40 < y) OR (bar = 4 AND y4 + 40 < y)THEN
					IF state = SUPERHARD THEN
						red <= (OTHERS => '1');
						green	<= "11010111";
						blue <= (OTHERS => '0');
					ELSIF state = HARD THEN
						red <= (OTHERS => '1');
						green	<= "10001100";
						blue <= (OTHERS => '0');
					ELSIF state = MEDIUM THEN
						red <= "11101110";
						green	<= "10000010";
						blue <= "11101110";
					ELSE
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '1');
					END IF;
				ELSE
					red <= (OTHERS => '0');
					green	<= (OTHERS => '1');
					blue <= (OTHERS => '0');
				END IF;
			END IF;
			------------------------------
			IF row < 300 OR row > 1620 THEN
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	END PROCESS DRAW;
	
	SPEED_CONTROL: PROCESS(state, lbutton, rbutton)
	BEGIN
		CASE state IS			-- Control the speed of the bars and the square depending on different states
			WHEN STANDBY =>
				speed <= 0;
				speedx <= 0;
				speedy <= 0;
				points <= 0;
			WHEN EASY =>
				speed <= 3;
				speedx <= 10;
				speedy <= 7;
				points <= 1;
			WHEN MEDIUM =>
				speed <= 5;
				speedx <= 10;
				speedy <= 10;
				points <= 2;
			WHEN HARD =>
				speed <= 7;
				speedx <= 12;
				speedy <= 14;
				points <= 5;
			WHEN SUPERHARD =>
				speed <= 9;
				speedx <= 12;
				speedy <= 16;
				points <= 10;
		END CASE;
	END PROCESS SPEED_CONTROL;
	
	REWARD: PROCESS(bar)
	BEGIN
		IF bar = 1 THEN			-- Determine where the reward is
			rx <= x1 + 185;
			ry <= y1 - 40;
		ELSIF bar = 2 THEN
			rx <= x2 + 185;
			ry <= y2 - 40;
		ELSIF bar = 3 THEN
			rx <= x3 + 185;
			ry <= y3 - 40;
		ELSIF bar = 4 THEN
			rx <= x4 + 185;
			ry <= y4 - 40;
		ELSE
			rx <= 945;
			ry <= -60;
		END IF;
	END PROCESS REWARD;
	
	GAME: PROCESS(clk, state, lbutton, rbutton, c)
	BEGIN
		IF clk'event AND clk = '1' THEN
			IF NOT started THEN
				gameover <= NOT gameover;
				started <= NOT started;
			END IF;		
			
			IF clk50 < 1000000 THEN
				clk50 <= clk50 + 1;
			ELSE
				clk50 <= 0;
				IF state = STANDBY THEN
					y1 <= 400;
					y2 <= 700;
					y3 <= 1000;
					y4 <= 1300;
					bar <= 4;
					x <= 900;
					y <= 200;
					gameover <= NOT gameover;
					score <= 0;
					red1 <= '1';
					red2 <= '1';
					red3 <= '1';
					red4 <= '1';
					blue1 <= '1';
					blue2 <= '1';
					blue3 <= '1';
					blue4 <= '1';
				ELSE
					IF y1 >= -65 THEN			-- Move bars upward
						y1 <= y1 - speed after 0 ns;
					ELSE
						y1 <= y4 + 300 after 0 ns;
					END IF;
					--
					IF y2 >= -65 THEN
						y2 <= y2 - speed after 0 ns;
					ELSE
						y2 <= y1 + 300 after 0 ns;
					END IF;
					--
					IF y3 >= -65 THEN
						y3 <= y3 - speed after 0 ns;
					ELSE
						y3 <= y2 + 300 after 0 ns;
					END IF;
					--
					IF y4 >= -65 THEN
						y4 <= y4 - speed after 0 ns;
					ELSE
						y4 <= y3 + 300 after 0 ns;
					END IF;	
					--------------------------------------------------------
					IF (lbutton = '0' AND rbutton = '1') OR (c = lhex) THEN		-- Control x-coordinate of square
						IF x > 250 THEN
							x <= x - speedx after 0 ns;
						ELSE
							x <= 1620;
						END IF;
					END IF;
					IF (lbutton = '1' AND rbutton = '0') OR (c = rhex) THEN
						IF x < 1620 THEN
							x <= x + speedx after 0 ns;
						ELSE
							x <= 300;
						END IF;
					END IF;
					-------------------------------------------------------
					IF y <= y1 - 50 + speed + speedy AND y >= y1 - 52 THEN	-- Move the box with the bars when the box is on the bars
						IF x >= x1 - 50 AND x <= x1 + 400 THEN
							y <= y1 - 48 - speed after 0 ns;
							IF speed = 8 THEN
								y <= y1 - 55 after 0 ns;
							END IF;
							red1 <= '0';
							blue1 <= '0';
						END IF;
					--	
					ELSIF y <= y2 - 50 + speed + speedy AND y >= y2 - 52 THEN
						IF x >= x2 - 50 AND x <= x2 + 400 THEN
							y <= y2 - 48 - speed after 0 ns;
							IF speed = 8 THEN
								y <= y2 - 55 after 0 ns;
							END IF;
							red2 <= '0';
							blue2 <= '0';
						END IF;
					--
					ELSIF y <= y3 - 50 + speed + speedy AND y >= y3 - 52 THEN
						IF x >= x3 - 50 AND x <= x3 + 400 THEN
							y <= y3 - 48 - speed after 0 ns;
							IF speed = 8 THEN
								y <= y3 - 55 after 0 ns;
							END IF;
							red3 <= '0';
							blue3 <= '0';
						END IF;
					--
					ELSIF y <= y4 - 50 + speed + speedy AND y >= y4 - 52 THEN
						IF x >= x4 - 50 AND x <= x4 + 400 THEN
							y <= y4 - 48 - speed after 0 ns;
							IF speed = 8 THEN
								y <= y4 - 55 after 0 ns;
							END IF;
							red4 <= '0';
							blue4 <= '0';
						END IF;
					--
					ELSE											-- Let the box fall when it does not touch any bar
						y <= y + speedy after 0 ns;
						red1 <= '1';
						red2 <= '1';
						red3 <= '1';
						red4 <= '1';
						blue1 <= '1';
						blue2 <= '1';
						blue3 <= '1';
						blue4 <= '1';
					END IF;
					---------------------------------------------
					IF y <= y1 AND y >= y1 - speed - speedy THEN		-- Update score when box pass a bar
						score <= score + points after 0 ns;
					END IF;
					--
					IF y <= y2 AND y >= y2 - speed - speedy THEN
						score <= score + points after 0 ns;
					END IF;
					--
					IF y <= y3 AND y >= y3 - speed - speedy THEN
						score <= score + points after 0 ns;
					END IF;
					--
					IF y <= y4 AND y >= y4 - speed - speedy THEN
						score <= score + points after 0 ns;
					END IF;
					---------------------------------------------
					IF (rx > x AND rx < x + 50 AND ry > y AND ry < y + 50) 											-- Update score when box touches reward
						OR (rx + 30 > X AND rx + 30 < x + 50 AND ry > y AND ry < y + 50)
						OR (rx > x AND rx < x + 50 AND ry + 30 > y AND ry + 30 < y + 50)
						OR (rx + 30 > x AND rx + 30 < x + 50 AND ry + 30 > y AND ry + 30 < y + 50) THEN
						score <= score + points after 0 ns;
						prevbar <= bar;
						bar <= rand mod 5;
						IF bar = prevbar THEN
							bar <= prevbar - 1;
						END IF;
					END IF;
					IF bar = 0 AND rand mod 5 = 0 THEN
						bar <= 4;
					END IF;
					---------------------------------------------
					IF score > bestscore THEN		-- Update bestscore
						bestscore <= score;
					END IF;
					IF score >= 999 THEN
						score <= 999;
						bestscore <= 999;
					END IF;
					----------------------------------------
					IF y >= 1030 THEN		-- GAME OVER condition
						gameover <= NOT gameover;
						score <= 0;
					END IF;
					IF y <= -5 THEN
						gameover <= NOT gameover;
						score <= 0;
					END IF;
				END IF;
			END IF;
			-------
			rand <= rand + speed + 2;
		END IF;
	END PROCESS GAME;
	
	RANDOMX: PROCESS(state)
	BEGIN
		IF NOT gameover THEN
			IF y1 > -65 AND y1 < -60 THEN
				IF rand < 0 THEN
					x1 <= 300;
				ELSIF rand > 920 THEN
					x1 <= 920;
				ELSE
				x1 <= 300 + rand;
				END IF;
			END IF;
			
			IF y2 > -65 AND y2 < -60 THEN
				IF rand < 0 THEN
					x2 <= 300;
				ELSIF rand > 920 THEN
					x2 <= 920;
				ELSE
				x2 <= 300 + rand;
				END IF;
			END IF;
			
			IF y3 > -65 AND y3 < -60 THEN
				IF rand < 0 THEN
					x3 <= 300;
				ELSIF rand > 920 THEN
					x3 <= 920;
				ELSE
				x3 <= 300 + rand;
				END IF;
			END IF;
			
			IF y4 > -65 AND y4 < -60 THEN
				IF rand < 0 THEN
					x4 <= 300;
				ELSIF rand > 920 THEN
					x4 <= 920;
				ELSE
				x4 <= 300 + rand;
				END IF;
			END IF;
			
		ELSE
			x1 <= 700;
			x2 <= 300;
			x3 <= 1200;
			x4 <= 900;
		END IF;
	END PROCESS RANDOMX;
	
	DIGIT: PROCESS(score, bestscore)
	BEGIN
		digit0 <= score mod 10;
		digit1 <= score / 10 mod 10;
		digit2 <= score / 100;
		digit4 <= bestscore mod 10;
		digit5 <= bestscore / 10 mod 10;
		digit6 <= bestscore / 100;
	END PROCESS DIGIT;
	
	HD0: HEX_DISPLAY PORT MAP (digit0, hex0);
	HD1: HEX_DISPLAY PORT MAP (digit1, hex1);
	HD2: HEX_DISPLAY PORT MAP (digit2, hex2);
	HD4: HEX_DISPLAY PORT MAP (digit4, hex4);
	HD5: HEX_DISPLAY PORT MAP (digit5, hex5);
	HD6: HEX_DISPLAY PORT MAP (digit6, hex6);
END behavior;

