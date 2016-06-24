-- ax_issp.vhd

-- Generated using ACDS version 15.1 185

library IEEE;
library ax_issp_altera_in_system_sources_probes_151;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ax_issp_altera_in_system_sources_probes_151.ax_issp_pkg.all;

entity ax_issp is
	port (
		probe  : in  std_logic_vector(14 downto 0) := (others => '0'); --  probes.probe
		source : out std_logic_vector(8 downto 0)                      -- sources.source
	);
end entity ax_issp;

architecture rtl of ax_issp is
begin

	in_system_sources_probes_0 : component ax_issp_altera_in_system_sources_probes_151.ax_issp_pkg.altsource_probe
		generic map (
			sld_auto_instance_index => "YES",
			sld_instance_index      => 0,
			instance_id             => "NONE",
			probe_width             => 15,
			source_width            => 9,
			source_initial_value    => "0",
			enable_metastability    => "NO"
		)
		port map (
			source     => source, -- sources.source
			probe      => probe,  --  probes.probe
			source_ena => '1'     -- (terminated)
		);

end architecture rtl; -- of ax_issp