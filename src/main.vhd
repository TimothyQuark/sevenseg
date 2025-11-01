library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        cpu_resetn : in    std_logic;                    -- Active low async reset button
        clk100mhz  : in    std_logic;                    -- External reference clock
        led        : out   std_logic_vector(2 downto 0); -- Green LEDs
        seg        : out   std_logic_vector(6 downto 0);
        seg_an     : out   std_logic_vector(7 downto 0)
    );
end entity top;

architecture behav of top is

    signal clk_logic : std_logic; -- 200 MHz Logic Clock
    signal s_led     : std_logic_vector(2 downto 0);

begin

    -- Instantiate the MMCM
    mmcm : entity work.mmcm
        port map (
            clk_logic => clk_logic,
            clk100mhz => clk100mhz
        );

    led <= s_led;

    p_led : process (clk_logic, cpu_resetn) is
    begin

        if (cpu_resetn = '0') then
            s_led <= (others => '0');
        elsif (rising_edge(clk_logic)) then
            s_led(0) <= not s_led(0);
            s_led(1) <= not s_led(1);
            s_led(2) <= not s_led(2);
        end if;

    end process p_led;

    sevenseg : entity work.sevenseg
        port map (
            clk_logic => clk_logic,
            wr        => '0',
            sym       => X"A",
            seg       => seg,
            sel       => seg_an
        );

end architecture behav;
