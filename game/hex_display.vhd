LIBRARY		IEEE;
USE			IEEE.STD_LOGIC_1164.ALL;
USE			IEEE.STD_LOGIC_ARITH.ALL;
USE			IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY HEX_DISPLAY IS
PORT(	num:	IN		INTEGER;
		hex:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END HEX_DISPLAY;

ARCHITECTURE BEHAVE OF HEX_DISPLAY IS
	CONSTANT num_0	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1000000";
	CONSTANT num_1	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1111001";
	CONSTANT num_2	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0100100";
	CONSTANT num_3	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0110000";
	CONSTANT num_4	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0011001";
	CONSTANT num_5	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0010010";
	CONSTANT num_6	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000010";
	CONSTANT num_7	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "1111000";
	CONSTANT num_8	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000000";
	CONSTANT num_9	: STD_LOGIC_VECTOR(6 DOWNTO 0):= "0010000";
BEGIN
	PROCESS(num)
	BEGIN
		IF num = 0 THEN
			hex <= num_0;
		ELSIF num = 1 THEN
			hex <= num_1;
		ELSIF num = 2 THEN
			hex <= num_2;
		ELSIF num = 3 THEN
			hex <= num_3;
		ELSIF num = 4 THEN
			hex <= num_4;
		ELSIF num = 5 THEN
			hex <= num_5;
		ELSIF num = 6 THEN
			hex <= num_6;
		ELSIF num = 7 THEN
			hex <= num_7;
		ELSIF num = 8 THEN
			hex <= num_8;
		ELSIF num = 9 THEN
			hex <= num_9;
		END IF;
	END PROCESS;
END BEHAVE;