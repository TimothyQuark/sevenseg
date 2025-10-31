library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk100mhz : in    std_logic
    );
end entity top;

architecture behav of top is

    signal logic_clk : std_logic;
    signal clk_rst   : std_logic;
    signal clk_lock  : std_logic;

begin

    -- Instantiate the MMCM
    mmcm : entity work.mmcm
        port map (
            logic_clk => logic_clk,
            reset     => clk_rst,
            locked    => clk_lock,
            clk100mhz => clk100mhz
        );

end architecture behav;
