--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY hw_image_generator IS
	PORT(
		lbutton, rbutton, sbutton, flag, clk				:	IN		STD_LOGIC;
		key															:	IN		STD_LOGIC_VECTOR(7 DOWNTO 0);
		disp_ena														:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row, column													:	IN		INTEGER;		--row pixel coordinate & column pixel coordinate
		red															:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green															:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue															:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
		hex0, hex1, hex2, hex4, hex5, hex6					:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
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
	
	SIGNAL	red1, red2, red3, red4 		: STD_LOGIC;
	SIGNAL	blue1, blue2, blue3, blue4	: STD_LOGIC;
		
	SIGNAL	score	: INTEGER RANGE 0 TO 999:= 0;
	SIGNAL	digit0: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit1: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit2: INTEGER RANGE 0 TO 9:= 0;
	
	SIGNAL	bestscore: INTEGER RANGE 0 TO 999:= 0;
	SIGNAL	digit4: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit5: INTEGER RANGE 0 TO 9:= 0;
	SIGNAL	digit6: INTEGER RANGE 0 TO 9:= 0;
	
	SIGNAL	c		 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL	lastkey: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	CONSTANT num_0	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1000000";
	CONSTANT num_1	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1111001";
	CONSTANT num_2	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0100100";
	CONSTANT num_3	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0110000";
	CONSTANT num_4	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0011001";
	CONSTANT num_5	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0010010";
	CONSTANT num_6	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000010";
	CONSTANT num_7	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1111000";
	CONSTANT num_8	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000000";
	CONSTANT num_9	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0011000";
	
	CONSTANT lhex 	: STD_LOGIC_VECTOR(7 DOWNTO 0):= x"6B";
	CONSTANT rhex 	: STD_LOGIC_VECTOR(7 DOWNTO 0):= x"74";
	
	SIGNAL clk50:	STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL rand:	INTEGER RANGE 0 TO 903;
BEGIN
	
	GAME_STATE: PROCESS(flag, key, state, score)
	BEGIN
		IF flag = '0' THEN
			c<= key;
		END IF;
	
		IF gameover THEN					-- Changes game state based on the score, gameover condition, and the spacebar input
			state <= STANDBY;
		ELSE
			IF score >= 100 THEN
				state <= SUPERHARD;
			ELSIF score >= 50 THEN
				state <= HARD;
			ELSIF score >= 20 THEN
				state <= MEDIUM;
			ELSIF c = "01110010" OR sbutton = '0' THEN
				state <= EASY;
			END IF;
		END IF;
	END PROCESS GAME_STATE;
	
	DRAW: PROCESS(disp_ena, row, column, clk)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			IF row > 300 AND row < 1620 AND column > 0 AND column < 1080 THEN		-- Draw the frame where the game takes place
				IF state = EASY OR state = STANDBY THEN
					red <= (OTHERS => '0');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '1');
				END IF;
				IF state = MEDIUM THEN
					red <= "11101110";
					green	<= "10000010";
					blue <= "11101110";
				END IF;
				IF state = HARD THEN
					red <= (OTHERS => '1');
					green	<= "10001100";
					blue <= (OTHERS => '0');
				END IF;
				IF state = SUPERHARD THEN
					red <= (OTHERS => '1');
					green	<= "11010111";
					blue <= (OTHERS => '0');
				END IF;
			ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			
			IF row > x AND row < x + 50 AND column > y AND column < y + 50 THEN		-- Draw the box representing the player
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			
			IF row > x1 AND row < x1 + 400 AND column > y1 AND column < y1 + 40 THEN		-- Draw the first bar
				red <= (OTHERS => red1);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue1);
			END IF;
			
			IF row > x2 AND row < x2 + 400 AND column > y2 AND column < y2 + 40 THEN		-- Draw the second bar
				red <= (OTHERS => red2);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue2);
			END IF;
			
			IF row > x3 AND row < x3 + 400 AND column > y3 AND column < y3 + 40 THEN		-- Draw the third bar
				red <= (OTHERS => red3);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue3);
			END IF;
			
			IF row > x4 AND row < x4 + 400 AND column > y4 AND column < y4 + 40 THEN		-- Draw the fourth bar
				red <= (OTHERS => red4);
				green	<= (OTHERS => '1');
				blue <= (OTHERS => blue4);
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
			WHEN EASY =>
				speed <= 3;
				speedx <= 10;
				speedy <= 7;
			WHEN MEDIUM =>
				speed <= 5;
				speedx <= 10;
				speedy <= 10;
			WHEN HARD =>
				speed <= 8;
				speedx <= 12;
				speedy <= 14;
			WHEN SUPERHARD =>
				speed <= 10;
				speedx <= 12;
				speedy <= 17;
		END CASE;
	END PROCESS SPEED_CONTROL;
	
	GAME: PROCESS(clk, state, lbutton, rbutton, c)
	BEGIN
		IF clk'event AND clk = '1' THEN
			IF NOT started THEN
				gameover <= NOT gameover;
				started <= NOT started;
			END IF;
		
			IF NOT gameover THEN
				IF clk50 < "11110100001001000000" THEN
					clk50 <= clk50 + 1;
				ELSE
					IF y1 > -60 THEN			-- Move bars upward
						y1 <= y1 - speed after 0 ns;
					ELSE
						y1 <= y4 + 300 after 0 ns;
					END IF;
					
					IF y2 > -60 THEN
						y2 <= y2 - speed after 0 ns;
					ELSE
						y2 <= y1 + 300 after 0 ns;
					END IF;
					
					IF y3 > -60 THEN
						y3 <= y3 - speed after 0 ns;
					ELSE
						y3 <= y2 + 300 after 0 ns;
					END IF;
					
					IF y4 > -60 THEN
						y4 <= y4 - speed after 0 ns;
					ELSE
						y4 <= y3 + 300 after 0 ns;
					END IF;
					----------------------------------------
					IF (lbutton = '0' AND rbutton = '1') OR (c = lhex) THEN		-- Control x-coordinate of square
						IF x > 300 THEN
							x <= x - speedx after 0 ns;
						ELSE
							x <= 300;
						END IF;
					END IF;
					IF (lbutton = '1' AND rbutton = '0') OR (c = rhex) THEN
						IF x < 1570 THEN
							x <= x + speedx after 0 ns;
						ELSE
							x <= 1570;
						END IF;
					END IF;
					----------------------------------------
					IF y <= y1 - 50 + speed + speedy AND y >= y1 - 52 THEN	-- Move the box with the bars when the box is on the bars
						IF x >= x1 - 50 AND x <= x1 + 400 THEN
							y <= y1 - 53 after 0 ns;
							IF speed = 8 THEN
								y <= y1 - 55 after 0 ns;
							END IF;
							red1 <= '0';
							blue1 <= '0';
							
						END IF;
					--	
					ELSIF y <= y2 - 50 + speed + speedy AND y >= y2 - 52 THEN
						IF x >= x2 - 50 AND x <= x2 + 400 THEN
							y <= y2 - 53 after 0 ns;
							IF speed = 8 THEN
								y <= y2 - 55 after 0 ns;
							END IF;
							red2 <= '0';
							blue2 <= '0';
						END IF;
					--
					ELSIF y <= y3 - 50 + speed + speedy AND y >= y3 - 52 THEN
						IF x >= x3 - 50 AND x <= x3 + 400 THEN
							y <= y3 - 53 after 0 ns;
							IF speed = 8 THEN
								y <= y3 - 55 after 0 ns;
							END IF;
							red3 <= '0';
							blue3 <= '0';
						END IF;
					--
					ELSIF y <= y4 - 50 + speed + speedy AND y >= y4 - 52 THEN
						IF x >= x4 - 50 AND x <= x4 + 400 THEN
							y <= y4 - 53 after 0 ns;
							IF speed = 8 THEN
								y <= y4 - 55 after 0 ns;
							END IF;
							red4 <= '0';
							blue4 <= '0';
						END IF;
					--
					ELSE														-- Let the box fall when it does not touch any bar
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
					----------------------------------------
					IF y <= y1 AND y >= y1 - speed - speedy THEN
						score <= score + 1 after 0 ns;
					END IF;
					IF y <= y2 AND y >= y2 - speed - speedy THEN
						score <= score + 1 after 0 ns;
					END IF;
					IF y <= y3 AND y >= y3 - speed - speedy THEN
						score <= score + 1 after 0 ns;
					END IF;
					IF y <= y4 AND y >= y4 - speed - speedy THEN
						score <= score + 1 after 0 ns;
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
					
					clk50 <= (others => '0');
				END IF;
				-------
				IF score > bestscore THEN		-- Update bestscore
					bestscore <= score;
				END IF;
				-------
				IF rand <= 903 THEN					-- Random counter used for the x-coordinate of the bars to generate new bars
					rand <= rand + speedy;
				ELSE
					rand <= 0;
				END IF;
		
			ELSE
				y1 <= 400;
				y2 <= 700;
				y3 <= 1000;
				y4 <= 1300;
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
			END IF;
		END IF;
	END PROCESS GAME;
	
	RANDOMX: PROCESS(state)
	BEGIN
		IF NOT gameover THEN
			IF y1 = -60 THEN
				x1 <= 300 + rand;
			END IF;
			
			IF y2 = -60 THEN
				x2 <= 300 + rand;
			END IF;
			
			IF y3 = -60 THEN
				x3 <= 300 + rand;
			END IF;
			
			IF y4 = -60 THEN
				x4 <= 300 + rand;
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
	
	HEXDISPLAY: PROCESS(digit0, digit1, digit2, digit4, digit5, digit6)
	BEGIN
		IF digit0 = 0 THEN		-- Display the rightmost digit of score
			hex0 <= num_0;
		ELSIF digit0 = 1 THEN
			hex0 <= num_1;
		ELSIF digit0 = 2 THEN
			hex0 <= num_2;
		ELSIF digit0 = 3 THEN
			hex0 <= num_3;
		ELSIF digit0 = 4 THEN
			hex0 <= num_4;
		ELSIF digit0 = 5 THEN
			hex0 <= num_5;
		ELSIF digit0 = 6 THEN
			hex0 <= num_6;
		ELSIF digit0 = 7 THEN
			hex0 <= num_7;
		ELSIF digit0 = 8 THEN
			hex0 <= num_8;
		ELSIF digit0 = 9 THEN
			hex0 <= num_9;
		END IF;
		
		IF digit1 = 0 THEN		-- Display the second rightmost digit of score
			hex1 <= num_0;
		ELSIF digit1 = 1 THEN
			hex1 <= num_1;
		ELSIF digit1 = 2 THEN
			hex1 <= num_2;
		ELSIF digit1 = 3 THEN
			hex1 <= num_3;
		ELSIF digit1 = 4 THEN
			hex1 <= num_4;
		ELSIF digit1 = 5 THEN
			hex1 <= num_5;
		ELSIF digit1 = 6 THEN
			hex1 <= num_6;
		ELSIF digit1 = 7 THEN
			hex1 <= num_7;
		ELSIF digit1 = 8 THEN
			hex1 <= num_8;
		ELSIF digit1 = 9 THEN
			hex1 <= num_9;
		END IF;
		
		IF digit2 = 0 THEN		-- Display the leftmost digit of score
			hex2 <= num_0;
		ELSIF digit2 = 1 THEN
			hex2 <= num_1;
		ELSIF digit2 = 2 THEN
			hex2 <= num_2;
		ELSIF digit2 = 3 THEN
			hex2 <= num_3;
		ELSIF digit2 = 4 THEN
			hex2 <= num_4;
		ELSIF digit2 = 5 THEN
			hex2 <= num_5;
		ELSIF digit2 = 6 THEN
			hex2 <= num_6;
		ELSIF digit2 = 7 THEN
			hex2 <= num_7;
		ELSIF digit2 = 8 THEN
			hex2 <= num_8;
		ELSIF digit2 = 9 THEN
			hex2 <= num_9;
		END IF;
		
		---------------------
		
		IF digit4 = 0 THEN		-- Display the rightmost digit of best score
			hex4 <= num_0;
		ELSIF digit4 = 1 THEN
			hex4 <= num_1;
		ELSIF digit4 = 2 THEN
			hex4 <= num_2;
		ELSIF digit4 = 3 THEN
			hex4 <= num_3;
		ELSIF digit4 = 4 THEN
			hex4 <= num_4;
		ELSIF digit4 = 5 THEN
			hex4 <= num_5;
		ELSIF digit4 = 6 THEN
			hex4 <= num_6;
		ELSIF digit4 = 7 THEN
			hex4 <= num_7;
		ELSIF digit4 = 8 THEN
			hex4 <= num_8;
		ELSIF digit4 = 9 THEN
			hex4 <= num_9;
		END IF;
		
		IF digit5 = 0 THEN		-- Display the second rightmost digit of best score
			hex5 <= num_0;
		ELSIF digit5 = 1 THEN
			hex5 <= num_1;
		ELSIF digit5 = 2 THEN
			hex5 <= num_2;
		ELSIF digit5 = 3 THEN
			hex5 <= num_3;
		ELSIF digit5 = 4 THEN
			hex5 <= num_4;
		ELSIF digit5 = 5 THEN
			hex5 <= num_5;
		ELSIF digit5 = 6 THEN
			hex5 <= num_6;
		ELSIF digit5 = 7 THEN
			hex5 <= num_7;
		ELSIF digit5 = 8 THEN
			hex5 <= num_8;
		ELSIF digit5 = 9 THEN
			hex5 <= num_9;
		END IF;
		
		IF digit6 = 0 THEN		-- Display the leftmost digit of best score
			hex6 <= num_0;
		ELSIF digit6 = 1 THEN
			hex6 <= num_1;
		ELSIF digit6 = 2 THEN
			hex6 <= num_2;
		ELSIF digit6 = 3 THEN
			hex6 <= num_3;
		ELSIF digit6 = 4 THEN
			hex6 <= num_4;
		ELSIF digit6 = 5 THEN
			hex6 <= num_5;
		ELSIF digit6 = 6 THEN
			hex6 <= num_6;
		ELSIF digit6 = 7 THEN
			hex6 <= num_7;
		ELSIF digit6 = 8 THEN
			hex6 <= num_8;
		ELSIF digit6 = 9 THEN
			hex6 <= num_9;
		END IF;
		
	END PROCESS HEXDISPLAY;
END behavior;

