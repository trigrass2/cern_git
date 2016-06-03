-- alt_sv_gx_txpll.vhd

-- Generated using ACDS version 14.0 200 at 2014.08.31.12:29:43

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alt_sv_gx_txpll is
	port (
		pll_powerdown      : in  std_logic                     := '0';             --      pll_powerdown.pll_powerdown
		pll_refclk         : in  std_logic_vector(0 downto 0)  := (others => '0'); --         pll_refclk.pll_refclk
		pll_fbclk          : in  std_logic                     := '0';             --          pll_fbclk.pll_fbclk
		pll_clkout         : out std_logic;                                        --         pll_clkout.pll_clkout
		pll_locked         : out std_logic;                                        --         pll_locked.pll_locked
		reconfig_to_xcvr   : in  std_logic_vector(69 downto 0) := (others => '0'); --   reconfig_to_xcvr.reconfig_to_xcvr
		reconfig_from_xcvr : out std_logic_vector(45 downto 0)                     -- reconfig_from_xcvr.reconfig_from_xcvr
	);
end entity alt_sv_gx_txpll;

architecture rtl of alt_sv_gx_txpll is
	component sv_xcvr_plls is
		generic (
			plls                                 : integer := 1;
			pll_type                             : string  := "CMU";
			pll_reconfig                         : integer := 0;
			refclks                              : integer := 1;
			reference_clock_frequency            : string  := "125.0 MHz";
			reference_clock_select               : string  := "0";
			output_clock_datarate                : string  := "";
			output_clock_frequency               : string  := "0 ps";
			feedback_clk                         : string  := "internal";
			sim_additional_refclk_cycles_to_lock : integer := 0;
			duty_cycle                           : integer := 50;
			phase_shift                          : string  := "0 ps";
			enable_hclk                          : string  := "0";
			enable_avmm                          : integer := 1;
			use_generic_pll                      : integer := 0;
			att_mode                             : integer := 0;
			enable_mux                           : integer := 1
		);
		port (
			rst                : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- pll_powerdown
			refclk             : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- pll_refclk
			fbclk              : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- pll_fbclk
			outclk             : out std_logic_vector(0 downto 0);                     -- pll_clkout
			locked             : out std_logic_vector(0 downto 0);                     -- pll_locked
			reconfig_to_xcvr   : in  std_logic_vector(69 downto 0) := (others => 'X'); -- reconfig_to_xcvr
			reconfig_from_xcvr : out std_logic_vector(45 downto 0);                    -- reconfig_from_xcvr
			pll_fb_sw          : in  std_logic                     := 'X';             -- pll_fb_sw
			fboutclk           : out std_logic;                                        -- fboutclk
			hclk               : out std_logic                                         -- hclk
		);
	end component sv_xcvr_plls;

	signal alt_sv_gx_txpll_inst_outclk : std_logic_vector(0 downto 0); -- port fragment
	signal alt_sv_gx_txpll_inst_locked : std_logic_vector(0 downto 0); -- port fragment

begin

	alt_sv_gx_txpll_inst : component sv_xcvr_plls
		generic map (
			plls                                 => 1,
			pll_type                             => "ATX",
			pll_reconfig                         => 0,
			refclks                              => 1,
			reference_clock_frequency            => "120.0 MHz",
			reference_clock_select               => "0",
			output_clock_datarate                => "4800 Mbps",
			output_clock_frequency               => "0 ps",
			feedback_clk                         => "internal",
			sim_additional_refclk_cycles_to_lock => 0,
			duty_cycle                           => 50,
			phase_shift                          => "0 ps",
			enable_hclk                          => "0",
			enable_avmm                          => 1,
			use_generic_pll                      => 0,
			att_mode                             => 0,
			enable_mux                           => 1
		)
		port map (
			rst(0)             => pll_powerdown,               --      pll_powerdown.pll_powerdown
			refclk(0 downto 0) => pll_refclk(0 downto 0),      --         pll_refclk.pll_refclk
			fbclk(0)           => pll_fbclk,                   --          pll_fbclk.pll_fbclk
			outclk             => alt_sv_gx_txpll_inst_outclk, --         pll_clkout.pll_clkout
			locked             => alt_sv_gx_txpll_inst_locked, --         pll_locked.pll_locked
			reconfig_to_xcvr   => reconfig_to_xcvr,            --   reconfig_to_xcvr.reconfig_to_xcvr
			reconfig_from_xcvr => reconfig_from_xcvr,          -- reconfig_from_xcvr.reconfig_from_xcvr
			pll_fb_sw          => '0',                         --        (terminated)
			fboutclk           => open,                        --        (terminated)
			hclk               => open                         --        (terminated)
		);

	pll_locked <= alt_sv_gx_txpll_inst_locked(0);

	pll_clkout <= alt_sv_gx_txpll_inst_outclk(0);

end architecture rtl; -- of alt_sv_gx_txpll
