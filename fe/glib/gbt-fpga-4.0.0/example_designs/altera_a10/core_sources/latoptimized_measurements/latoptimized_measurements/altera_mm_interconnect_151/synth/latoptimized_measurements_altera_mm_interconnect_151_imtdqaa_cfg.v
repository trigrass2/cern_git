config latoptimized_measurements_altera_mm_interconnect_151_imtdqaa_cfg;
		design latoptimized_measurements_altera_mm_interconnect_151_imtdqaa;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.master_0_master_translator use latoptimized_measurements_altera_merlin_master_translator_151.altera_merlin_master_translator;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.latmeas_s1_translator use latoptimized_measurements_altera_merlin_slave_translator_151.altera_merlin_slave_translator;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.resetctrl_s1_translator use latoptimized_measurements_altera_merlin_slave_translator_151.altera_merlin_slave_translator;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.master_0_master_agent use latoptimized_measurements_altera_merlin_master_agent_151.altera_merlin_master_agent;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.latmeas_s1_agent use latoptimized_measurements_altera_merlin_slave_agent_151.altera_merlin_slave_agent;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.latmeas_s1_agent_rsp_fifo use latoptimized_measurements_altera_avalon_sc_fifo_151.altera_avalon_sc_fifo;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.resetctrl_s1_agent use latoptimized_measurements_altera_merlin_slave_agent_151.altera_merlin_slave_agent;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.resetctrl_s1_agent_rsp_fifo use latoptimized_measurements_altera_avalon_sc_fifo_151.altera_avalon_sc_fifo;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.router use latoptimized_measurements_altera_merlin_router_151.latoptimized_measurements_altera_merlin_router_151_6mbt73i;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.router_001 use latoptimized_measurements_altera_merlin_router_151.latoptimized_measurements_altera_merlin_router_151_j5iewqi;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.router_002 use latoptimized_measurements_altera_merlin_router_151.latoptimized_measurements_altera_merlin_router_151_j5iewqi;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.master_0_master_limiter use latoptimized_measurements_altera_merlin_traffic_limiter_151.altera_merlin_traffic_limiter;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.cmd_demux use latoptimized_measurements_altera_merlin_demultiplexer_151.latoptimized_measurements_altera_merlin_demultiplexer_151_5mdxrjy;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.cmd_mux use latoptimized_measurements_altera_merlin_multiplexer_151.latoptimized_measurements_altera_merlin_multiplexer_151_xo7b33q;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.cmd_mux_001 use latoptimized_measurements_altera_merlin_multiplexer_151.latoptimized_measurements_altera_merlin_multiplexer_151_xo7b33q;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.rsp_demux use latoptimized_measurements_altera_merlin_demultiplexer_151.latoptimized_measurements_altera_merlin_demultiplexer_151_rnnmf7a;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.rsp_demux_001 use latoptimized_measurements_altera_merlin_demultiplexer_151.latoptimized_measurements_altera_merlin_demultiplexer_151_rnnmf7a;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.rsp_mux use latoptimized_measurements_altera_merlin_multiplexer_151.latoptimized_measurements_altera_merlin_multiplexer_151_rhljhga;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.avalon_st_adapter use latoptimized_measurements_altera_avalon_st_adapter_151.latoptimized_measurements_altera_avalon_st_adapter_151_f4k6yuq;
		instance latoptimized_measurements_altera_mm_interconnect_151_imtdqaa.avalon_st_adapter_001 use latoptimized_measurements_altera_avalon_st_adapter_151.latoptimized_measurements_altera_avalon_st_adapter_151_f4k6yuq;
endconfig

