library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk_ref100mhz : in    std_logic;                    --! External reference clock
        i_resetn      : in    std_logic;                    --! Active low async reset button
        o_led         : out   std_logic_vector(2 downto 0); --! Green LEDs
        o_seg_an      : out   std_logic_vector(7 downto 0); --! 7 Segment selection
        o_seg         : out   std_logic_vector(6 downto 0)  --! 7 Segment symbol
    );
end entity top;

architecture behav of top is

    signal clk_logic : std_logic;                    --! 200 MHz Logic Clock
    signal s_led     : std_logic_vector(2 downto 0); --! Green LEDs

    signal s_sevenseg_wr   : std_logic;            --! Wr EN 7 seg
    signal s_sevenseg_addr : unsigned(2 downto 0); --! 7 segment select
    signal s_sevenseg_data : unsigned(3 downto 0); --! 7 segment symbol

begin

    -- Instantiate the MMCM
    mmcm : entity work.mmcm
        port map (
            clk_logic       => clk_logic,
            i_clk_ref100mhz => clk_ref100mhz
        );

    o_led <= s_led;

    p_led : process (clk_logic, i_resetn) is
    begin

        if (i_resetn = '0') then
            s_led <= (others => '0');
        elsif (rising_edge(clk_logic)) then
            -- 50% duty cycle to save my eyes from burning
            s_led(0) <= not s_led(0);
            s_led(1) <= not s_led(1);
            s_led(2) <= not s_led(2);
        end if;

    end process p_led;

    p_test : process (clk_logic, i_resetn) is

        variable s_hold_rst : std_logic;
        variable cntr       : unsigned(2 downto 0);

    begin

        -- Wonky test: cpu_resetn probably starts at 0 after boot
        if (i_resetn = '0') then
            s_hold_rst := '1';
        elsif (rising_edge(clk_logic)) then
            s_sevenseg_wr <= '0';

            if (s_hold_rst = '1') then
                s_hold_rst      := '0';
                s_sevenseg_wr   <= '1';
                s_sevenseg_addr <= cntr;
                cntr            := cntr + 1;
                s_sevenseg_data <= x"4";
            end if;
        end if;

    end process p_test;

    sevenseg : entity work.sevenseg
        port map (
            clk_logic => clk_logic,
            i_wr      => s_sevenseg_wr,
            i_addr    => s_sevenseg_addr,
            i_data    => s_sevenseg_data,
            o_seg_an  => o_seg_an,
            o_seg     => o_seg
        );

end architecture behav;
