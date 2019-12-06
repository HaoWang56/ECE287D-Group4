	component altpll0 is
		port (
			areset_reset : in  std_logic := 'X'; -- reset
			inclk0_clk   : in  std_logic := 'X'; -- clk
			c0_clk       : out std_logic         -- clk
		);
	end component altpll0;

	u0 : component altpll0
		port map (
			areset_reset => CONNECTED_TO_areset_reset, -- areset.reset
			inclk0_clk   => CONNECTED_TO_inclk0_clk,   -- inclk0.clk
			c0_clk       => CONNECTED_TO_c0_clk        --     c0.clk
		);

