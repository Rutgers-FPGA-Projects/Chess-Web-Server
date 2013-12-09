LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity VGAtest is
port(
	CLOCK_50		: in std_logic;
	VGA_CLK 		: OUT STD_LOGIC;
	KEY			: in std_logic_vector(3 downto 0);
	VGA_R			: out std_logic_vector(7 downto 0):= (OTHERS => '0');
	VGA_G			: out std_logic_vector(7 downto 0):= (OTHERS => '0');
	VGA_B			: out std_logic_vector(7 downto 0):= (OTHERS => '0');
	VGA_HS		: out std_logic; 
	VGA_VS		: out std_logic;
	VGA_BLANK_N	: out std_logic;
	VGA_SYNC_N	: out std_logic
);
end VGAtest;

ARCHITECTURE rtl OF VGAtest IS

COMPONENT vga_controller IS
GENERIC (
h_bp : INTEGER;
h_fp : INTEGER;
h_pixels : INTEGER;
h_pol : STD_LOGIC;
h_pulse : INTEGER;
v_bp : INTEGER;
v_fp : INTEGER;
v_pixels : INTEGER;
v_pol : STD_LOGIC;
v_pulse : INTEGER
);
PORT(
	pixel_clk	:	IN		STD_LOGIC;	--25 mhz pixel clock at frequency of VGA mode being used
	reset_n		:	IN		STD_LOGIC;	--active low asycnchronous reset
	h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
	v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
	disp_ena		:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
	column		:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);		--horizontal pixel coordinate
	row			:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);		--vertical pixel coordinate
	n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
	n_sync		:	OUT	STD_LOGIC
); --sync-on-green output to DAC
END COMPONENT;

COMPONENT paddle_image IS

PORT(
		CLOCK			:	IN		STD_LOGIC;
		RST			: 	IN		STD_LOGIC;
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		STD_LOGIC_VECTOR(31 DOWNTO 0);		--row pixel coordinate
		column		:	IN		STD_LOGIC_VECTOR(31 DOWNTO 0);		--column pixel coordinate
		move_r		:	IN		STD_LOGIC;
		move_l		:	IN		STD_LOGIC;
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
); 

END COMPONENT;

component clock_10pll is
port(
	clk_in_clk  : in  std_logic := 'X'; -- clk
	reset_reset : in  std_logic := 'X'; -- reset
	clk_out_clk : out std_logic         -- clk
);
end component clock_10pll;

component clock_25pll is
port (
	clk_in_clk  : in  std_logic := 'X'; -- clk
	reset_reset : in  std_logic := 'X'; -- reset
	clk_out_clk : out std_logic         -- clk
);
end component clock_25pll;
	
SIGNAL RST, BALLCLOCK, CLOCK_25, CLOCK_10, disp_ena : std_logic;
SIGNAL column, row : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL counter : INTEGER RANGE 0 TO 50000 := 0;

BEGIN
RST <= NOT KEY(3);
VGA_CLK <= CLOCK_25;

CLK25 : clock_25pll port map(CLOCK_50, '0', CLOCK_25);
CLK10 : clock_10pll port map(CLOCK_50, '0', CLOCK_10);

PROCESS(CLOCK_10)
BEGIN
	IF(CLOCK_10 = '1' and CLOCK_10'EVENT) THEN
		counter <= counter + 1;
		IF(COUNTER = 50000) THEN
			BALLCLOCK <= NOT BALLCLOCK;
		END IF;
  END IF;
END PROCESS;	

VGA : vga_controller
GENERIC MAP(h_bp => 48, h_fp => 16, h_pixels => 640, h_pol => '0', h_pulse => 96, v_bp => 33,  v_fp => 10, v_pixels => 480, v_pol => '0', v_pulse => 2 )
port map(CLOCK_25, '1', VGA_HS, VGA_VS, disp_ena, column, row, VGA_BLANK_N,  VGA_SYNC_N);

IMGSRC : paddle_image port map(BALLCLOCK, RST, disp_ena, row, column,NOT key(0),NOT key(1), VGA_R, VGA_G, VGA_B);

END;