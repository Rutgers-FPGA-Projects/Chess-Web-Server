LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY paddle_image IS
	PORT(
		clock	:	IN	STD_LOGIC;	--ball clock
		RST	:	IN	STD_LOGIC;	--start button for when ball misses paddle
		disp_ena:	IN	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row	:	IN	INTEGER;	--row pixel coordinate
		column	:	IN	INTEGER;	--column pixel coordinate
		move_r	:	IN	STD_LOGIC;	--signal that indicates paddle movement right
		move_l	:	IN	STD_LOGIC;	--signal that indicates paddle movement left
		red	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END paddle_image;

ARCHITECTURE behavior OF paddle_image IS


-- Initializing a 2d array to hold the blocks for the game
-- 5 rows for 10 blocks
-- array element holding '1' for block present, '0' otherwise
type blocks is array (0 to 4, 0 to 9) of std_LOGIC;
signal BLOCK_ARRAY : blocks := ("1111111111", "1111111111", "1111111111", "1111111111", "1111111111");

-- Initial position of paddle and movements
signal paddle : integer :=296;
signal r_movement, l_movement : integer :=0;

--ball signals
SIGNAL SIZEY : INTEGER := 6; --HEIGHT
SIGNAL SIZEX : INTEGER := 4; --WIDTH
SIGNAL MOVEX : INTEGER RANGE -4 TO 4:= 0; --PIXELS PER CLOCK IN X
SIGNAL MOVEY : INTEGER RANGE -4 TO 4:= 0; --PIXELS PER CLOCK IN Y
SIGNAL BALL_POS_Y : INTEGER RANGE 0 TO 480 :=450; --INITIAL POSITION
SIGNAL BALL_POS_X : INTEGER RANGE 0 TO 640 :=320;

BEGIN
----------------------------------------------
-- Image mapping process
-- Sections for certaintion row / column cases (where row is vertical pixels and column is horizontal pixels)


	PROCESS(disp_ena, row, column,l_movement,r_movement)
	BEGIN
	
-- Draws blocks, initially implemented with a double for loop making the code more concise
-- however, made it difficult to add color.
		IF disp_ena = '1' THEN
			IF(row > 1 AND row < 20) THEN
				for J in 0 to 9 loop
					IF (column > J*64 AND column < J*64 + 63) THEN
						IF (BLOCK_ARRAY(0, J) = '1') THEN
							red <= (others => '1');
							green <= (others => '0'); 
							blue <= (OTHERS => '0'); 
						ELSE
							red <= (OTHERS => '0');
							green <= (OTHERS => '0');
							blue <= (OTHERS => '0');
						END IF;
					ELSIF(COLUMN = (J+1)*64) THEN
						red <= (OTHERS => '0');
						green <= (OTHERS => '0');
						blue <= (OTHERS => '0');
					END IF;
				end loop;
			ELSIF(row > 21 AND row < 40) THEN
				for J in 0 to 9 loop
					IF (column > J*64 AND column < J*64 + 63) THEN
						IF (BLOCK_ARRAY(1, J) = '1') THEN
							red <= (others => '1');
							green <= (others => '1');
							blue <= (OTHERS => '0');
						ELSE
							red <= (OTHERS => '0');
							green <= (OTHERS => '0');
							blue <= (OTHERS => '0');
						END IF;
					ELSIF(COLUMN = (J+1)*64) THEN
						red <= (OTHERS => '0');
						green <= (OTHERS => '0');
						blue <= (OTHERS => '0');
					END IF;
				end loop;
			ELSIF(row > 41 AND row < 60) THEN
				for J in 0 to 9 loop
					IF (column > J*64 AND column < J*64 + 63) THEN
						IF (BLOCK_ARRAY(2, J) = '1') THEN
							red <= (OTHERS => '0');
							green <= (others => '1');
							blue <= (OTHERS => '0');
						ELSE
							red <= (OTHERS => '0');
							green <= (OTHERS => '0');
							blue <= (OTHERS => '0');
						END IF;
					ELSIF(COLUMN = (J+1)*64) THEN
						red <= (OTHERS => '0');
						green <= (OTHERS => '0');
						blue <= (OTHERS => '0');
					END IF;
				end loop;
			ELSIF(row > 61 AND row < 80) THEN
				for J in 0 to 9 loop
					IF (column > J*64 AND column < J*64 + 63) THEN
						IF (BLOCK_ARRAY(3, J) = '1') THEN
							red <= (others => '1');
							green <= (OTHERS => '0');
							blue <= (others => '1');
						ELSE
							red <= (OTHERS => '0');
							green <= (OTHERS => '0');
							blue <= (OTHERS => '0');
						END IF;
					ELSIF(COLUMN = (J+1)*64) THEN
						red <= (OTHERS => '0');
						green <= (OTHERS => '0');
						blue <= (OTHERS => '0');
					END IF;
				end loop;
			ELSIF(row > 81 AND row < 100) THEN
				for J in 0 to 9 loop
					IF (column > J*64 AND column < J*64 + 63) THEN
						IF (BLOCK_ARRAY(4, J) = '1') THEN
							red <= (OTHERS => '0');
							green <= (others => '1');
							blue <= (others => '1');
						ELSE
							red <= (OTHERS => '0');
							green <= (OTHERS => '0');
							blue <= (OTHERS => '0');
						END IF;
					ELSIF(COLUMN = (J+1)*64) THEN
						red <= (OTHERS => '0');
						green <= (OTHERS => '0');
						blue <= (OTHERS => '0');
					END IF;
				end loop;
	-- end of block drawing segment
	
	-- Ball drawing, rows 5 - 469 for potential rows ball can be
			ELSIF (row > 5 AND ROW <469) THEN
				IF( row > (BALL_POS_Y - SIZEY)  AND row < (BALL_POS_Y + SIZEY) AND COLUMN > (BALL_POS_X - SIZEX) AND COLUMN < (BALL_POS_X + SIZEX) ) THEN
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '0');
				ELSE
					red <= (OTHERS => '0');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '0');
				END IF;
				
	-- Paddle drawing, only present at the bottom of the screen, therefore between rows 470 and 479
			ELSIF((row > 470 AND row < 479) AND (column >(paddle - l_movement + r_movement) AND column<(paddle - l_movement + r_movement + 48))) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			ELSE
				red <= (OTHERS => '0');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	END PROCESS;
	
	
--This process controls left paddle movement
	PROCESS(move_l)
	BEGIN
		IF move_l = '1' THEN
			IF r_movement-l_movement+paddle < -24 THEN
				l_movement <= l_movement;
			ELSE
				l_movement <= l_movement+16;
			END IF;
		END IF;
	END PROCESS;
--This process controls right paddle movement
	PROCESS(move_r)
	BEGIN
		IF move_r = '1' THEN		
			IF r_movement-l_movement+paddle+48>664 THEN
				r_movement <= r_movement;
			ELSE
				r_movement <= r_movement+16;
			END IF;
		END IF;
	END PROCESS;
	
	
--Ball movement process
	PROCESS(CLOCK, RST, l_movement, r_movement)
	begin
	
	-- If RST, move the ball up and right
		IF(RST = '1') THEN
			MOVEX <= 1;
			MOVEY <= -1;
		ELSIF	(CLOCK ='1' AND CLOCK'EVENT) then
	
	-- if the ball is within the portion of the screen where there
	-- aren't blocks, boundaries, or paddle, move as previous
			if((BALL_POS_X - SIZEX > 1) and (BALL_POS_X + SIZEX < 639) and (BALL_POS_Y - SIZEY > 100) and (BALL_POS_Y + SIZEY < 479) ) THEN
				BALL_POS_Y <= BALL_POS_Y + moveY;
				BALL_POS_X <= BALL_POS_X + moveX;
				
	-- if the bottom of the ball is within the paddle potential vertically,
			elsif(BALL_POS_Y + SIZEY  >= 479) then
			
	-- check if the paddle is within the ball horizontally. 
	-- if it is, "bounce" the ball (change Y movement to up) and continue ball movement
				IF(BALL_POS_X >(paddle - l_movement + r_movement) AND BALL_POS_X<(paddle - l_movement + r_movement + 48)) THEN
					MOVEY <= -1;
					BALL_POS_Y <= BALL_POS_Y + moveY;
					BALL_POS_X <= BALL_POS_X + moveX;
					
	-- else position the ball at a starting position
	-- and freeze it there
				ELSE
					BALL_POS_X <= 320;
					BALL_POS_Y <= 450;
					MOVEX <= 0;
					MOVEY <= 0;
				END IF;
	-- if the ball reaches the right side of the screen, have it move left
			elsif(BALL_POS_X + SIZEX >= 639) then
				moveX <= -1;
				BALL_POS_Y <= BALL_POS_Y + moveY;
				BALL_POS_X <= BALL_POS_X + moveX;
	
	-- if the ball if within potential block positions
	-- check if the array is '1': if '1' change to '0' and
	-- change vertical movement to down.
	-- else continue ball movement
	
			elsif(BALL_POS_Y - SIZEY <= 100 AND BALL_POS_Y - SIZEY > 80 ) then
							
			for J in 0 to 9 loop
				IF (BALL_POS_X > J*64 AND BALL_POS_X < J*64 + 63) THEN
					IF(block_array(4,J) = '1') THEN
						moveY <= 1 ;
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
						block_array(4,J) <= '0';
					ELSE
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					END IF;
				END IF;
			END LOOP;
			BALL_POS_Y <= BALL_POS_Y + moveY;
			BALL_POS_X <= BALL_POS_X + moveX;
			
			elsif(BALL_POS_Y - SIZEY <= 80 AND BALL_POS_Y - SIZEY > 60) then
							
			for J in 0 to 9 loop
				IF (BALL_POS_X - SIZEX > J*64 AND BALL_POS_X + SIZEX < J*64 + 63) THEN
					IF(block_array(3,J) = '1') THEN
						moveY <= 1;
						block_array(3,J) <= '0';
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					ELSE
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					END IF;
				END IF;
			END LOOP;
			BALL_POS_Y <= BALL_POS_Y + moveY;
			BALL_POS_X <= BALL_POS_X + moveX;
			
			elsif(BALL_POS_Y - SIZEY <= 60 AND BALL_POS_Y - SIZEY > 40) then
							
			for J in 0 to 9 loop
				IF (BALL_POS_X - SIZEX > J*64 AND BALL_POS_X + SIZEX < J*64 + 63) THEN
					IF(block_array(2,J) = '1') THEN
						moveY <= 1;
						block_array(2,J) <= '0';
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					ELSE
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					END IF;
				END IF;
			END LOOP;
			BALL_POS_Y <= BALL_POS_Y + moveY;
			BALL_POS_X <= BALL_POS_X + moveX;

			elsif(BALL_POS_Y - SIZEY <= 40 AND BALL_POS_Y - SIZEY > 20) then
							
			for J in 0 to 9 loop
				IF (BALL_POS_X - SIZEX > J*64 AND BALL_POS_X + SIZEX < J*64 + 63) THEN
					IF(block_array(1,J) = '1') THEN
						moveY <= 1;
						block_array(1,J) <= '0';
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					ELSE
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					END IF;
				END IF;
			END LOOP;
			BALL_POS_Y <= BALL_POS_Y + moveY;
			BALL_POS_X <= BALL_POS_X + moveX;

			elsif(BALL_POS_Y - SIZEY <= 20 AND BALL_POS_Y - SIZEY > 1) then
							
			for J in 0 to 9 loop
				IF (BALL_POS_X - SIZEX > J*64 AND BALL_POS_X + SIZEX < J*64 + 63) THEN
					IF(block_array(0,J) = '1') THEN
						moveY <= 1;
						block_array(0,J) <= '0';
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					ELSE
						BALL_POS_Y <= BALL_POS_Y + moveY;
						BALL_POS_X <= BALL_POS_X + moveX;
					END IF;
				END IF;
			END LOOP;
			BALL_POS_Y <= BALL_POS_Y + moveY;
			BALL_POS_X <= BALL_POS_X + moveX;
	-- end of ball collision with block segment
	
	-- Boundary for top of the screen
			ELSIF ( BALL_POS_Y - SIZEY <=1 ) THEN
				MOVEY <= 1;
				BALL_POS_Y <= BALL_POS_Y + moveY;
				BALL_POS_X <= BALL_POS_X + moveX;
				
	-- Boundary for left side of the screen
			elsif(BALL_POS_X - SIZEX  <= 1) then
				moveX <= 1;
				BALL_POS_Y <= BALL_POS_Y + moveY;
				BALL_POS_X <= BALL_POS_X + moveX;
			end if;
		END IF;
	END PROCESS;
END behavior;
