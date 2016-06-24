-- alt_a10_lpm_shiftreg.vhd

-- Generated using ACDS version 15.1 185

library IEEE;
library alt_a10_lpm_shiftreg_lpm_shiftreg_151;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use alt_a10_lpm_shiftreg_lpm_shiftreg_151.alt_a10_lpm_shiftreg_pkg.all;

entity alt_a10_lpm_shiftreg is
	port (
		clock    : in  std_logic := '0'; --  lpm_shiftreg_input.clock
		shiftin  : in  std_logic := '0'; --                    .shiftin
		shiftout : out std_logic         -- lpm_shiftreg_output.shiftout
	);
end entity alt_a10_lpm_shiftreg;

architecture rtl of alt_a10_lpm_shiftreg is
begin

	lpm_shiftreg_0 : component alt_a10_lpm_shiftreg_lpm_shiftreg_151.alt_a10_lpm_shiftreg_pkg.alt_a10_lpm_shiftreg_lpm_shiftreg_151_m6wkfty
		port map (
			clock    => clock,    --  lpm_shiftreg_input.clock
			shiftin  => shiftin,  --                    .shiftin
			shiftout => shiftout  -- lpm_shiftreg_output.shiftout
		);

end architecture rtl; -- of alt_a10_lpm_shiftreg