library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity phaligner_std_pll is
  Port ( 
      RX_WORDCLK_I          : in  std_logic;
      RX_FRAMECLK_O         : out std_logic;
		
      RESET_I               : in  std_logic;
      
      SHIFT_DONE            : out std_logic;
      PHASE_SHIFT           : in  std_logic;
      
      LOCKED                : out std_logic
  );
end phaligner_std_pll;

architecture Behavioral of phaligner_std_pll is
	component rx_frameclk_pll is
		port (
			cntsel           : in  std_logic_vector(4 downto 0) := (others => 'X'); -- cntsel
			locked           : out std_logic;                                       -- export
			num_phase_shifts : in  std_logic_vector(2 downto 0) := (others => 'X'); -- num_phase_shifts
			outclk_0         : out std_logic;                                       -- clk
			phase_done       : out std_logic;                                       -- phase_done
			phase_en         : in  std_logic                    := 'X';             -- phase_en
			refclk           : in  std_logic                    := 'X';             -- clk
			rst              : in  std_logic                    := 'X';             -- reset
			scanclk          : in  std_logic                    := 'X';             -- scanclk
			updn             : in  std_logic                    := 'X'              -- updn
		);
	end component rx_frameclk_pll;
begin
	
	pll_inst: rx_frameclk_pll
		port map(
			cntsel           => (others => '0'),
			locked           => LOCKED,
			num_phase_shifts => "001",
			outclk_0         => RX_FRAMECLK_O,
			phase_done       => SHIFT_DONE,
			phase_en         => PHASE_SHIFT,
			refclk           => RX_WORDCLK_I,
			rst              => RESET_I,
			scanclk          => RX_WORDCLK_I,
			updn             => '1'
		);
		
end;