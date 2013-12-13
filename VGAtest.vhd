LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------
-- Top level entity of Brick Breaker program --
-----------------------------------------------

entity VGAtest is
port(
	CLOCK_50	: in std_logic;		--Input CLOCK to PLLs to drive VGA components
	VGA_CLK 	: OUT STD_LOGIC;	--Pin signal to sync to pixel clock (25.175 mhz)
	KEY		: in std_logic_vector(3 downto 0);	--Input buttons to control the game
	VGA_R		: out std_logic_vector(7 downto 0):= (OTHERS => '0');	--Pin signal for intensity of red to be displayed
	VGA_G		: out std_logic_vector(7 downto 0):= (OTHERS => '0');	--Pin signal for intensity of green to be displayed
	VGA_B		: out std_logic_vector(7 downto 0):= (OTHERS => '0');	--Pin signal for intensity of blue to be displayed
	VGA_HS		: out std_logic;	--Pin signal for horizontal sync
	VGA_VS		: out std_logic;	--Pin signal for verticcal sync
	VGA_BLANK_N	: out std_logic;	--Pin signal for blanking period
	VGA_SYNC_N	: out std_logic		--Pin signal for syncing period
);
end VGAtest;

ARCHITECTURE rtl OF VGAtest IS

-----------------------------------------------
-- vga_controller: --
-- drives the scanlines along the screen

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

-----------------------------------------------
-- paddle_image:--
--the source image where brick breaker is held

COMPONENT paddle_image IS

PORT(
		CLOCK	:	IN	STD_LOGIC;
		RST	: 	IN	STD_LOGIC;
		disp_ena:	IN	STD_LOGIC;	
		row	:	IN	STD_LOGIC_VECTOR(31 DOWNTO 0);	
		column	:	IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		move_r	:	IN	STD_LOGIC;
		move_l	:	IN	STD_LOGIC;
		red	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); 
		green	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  
		blue	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')
); 

END COMPONENT;

-----------------------------------------------
-- clock_10pll --
-- PLL used for a separate ballclock

component clock_10pll is
port(
	clk_in_clk  : in  std_logic := 'X'; -- clk
	reset_reset : in  std_logic := 'X'; -- reset
	clk_out_clk : out std_logic         -- clk
);
end component clock_10pll;

-----------------------------------------------
-- clock_25pll --
-- PLL used for the pixel clock (25.175 mHz)

component clock_25pll is
port (
	clk_in_clk  : in  std_logic := 'X'; -- clk
	reset_reset : in  std_logic := 'X'; -- reset
	clk_out_clk : out std_logic         -- clk
);
end component clock_25pll;

-----------------------------------------------
-- SIGNALS--
-- RST is a soft reset, if the ball misses the paddle it will allow it to start again. 
-- CLOCK_25 and CLOCK_10 hold the PLL clocks
-- column, row, and dis_ena are intermediate signals for the VGA port mapping
-- BALLCLOCK and counter both used to modify a slower clock for the ball

SIGNAL RST, BALLCLOCK, CLOCK_25, CLOCK_10, disp_ena : std_logic;
SIGNAL column, row : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL counter : INTEGER RANGE 0 TO 50000 := 0;

BEGIN
RST <= NOT KEY(3); -- reset set to a key
VGA_CLK <= CLOCK_25; -- pixel clock set to 25.175 mHz 

-- port mapping input clock to PLLs
CLK25 : clock_25pll port map(CLOCK_50, '0', CLOCK_25);
CLK10 : clock_10pll port map(CLOCK_50, '0', CLOCK_10);

-- Ball clock process, pulse BALLCLOCK every 50000 counter increments
-- where counter is incremented every 10 mHz, essentially a 100 Hz clock
-- (pulses up on the first 50000 and down on the next: 10 mHz / 100000 counter increments = 100 Hz)

PROCESS(CLOCK_10)
BEGIN
	IF(CLOCK_10 = '1' and CLOCK_10'EVENT) THEN
		counter <= counter + 1;
		IF(COUNTER = 50000) THEN
			BALLCLOCK <= NOT BALLCLOCK;
		END IF;
  END IF;
END PROCESS;	

-- port mapping to components with generic mapping being specifications for VGA 640x480, 60 Hz refresh rate

VGA : vga_controller
GENERIC MAP(h_bp => 48, h_fp => 16, h_pixels => 640, h_pol => '0', h_pulse => 96, v_bp => 33,  v_fp => 10, v_pixels => 480, v_pol => '0', v_pulse => 2 )
port map(CLOCK_25, '1', VGA_HS, VGA_VS, disp_ena, column, row, VGA_BLANK_N,  VGA_SYNC_N);

IMGSRC : paddle_image port map(BALLCLOCK, RST, disp_ena, row, column,NOT key(0),NOT key(1), VGA_R, VGA_G, VGA_B);

END;
