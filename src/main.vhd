library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk_ref100mhz : in    std_logic;                    --! External reference clock
        i_resetn      : in    std_logic;                    --! Active low async reset button
        i_btnc        : in    std_logic;                    --! Center Button
        o_led         : out   std_logic_vector(2 downto 0); --! Green LEDs
        o_seg_an      : out   std_logic_vector(7 downto 0); --! 7 Segment selection (anode)
        o_seg         : out   std_logic_vector(6 downto 0)  --! 7 Segment symbol
    );
end entity top;

architecture behav of top is

    signal clk_logic : std_logic;                    --! 200 MHz Logic Clock
    signal s_led     : std_logic_vector(2 downto 0); --! Green LEDs

    signal s_sevenseg_wr   : std_logic;            --! Wr EN 7 seg
    signal s_sevenseg_addr : unsigned(2 downto 0); --! 7 segment select
    signal s_sevenseg_data : unsigned(3 downto 0); --! 7 segment symbol

    signal s_btnc   : std_logic; --! Center Button (post debouncer)
    signal s_btnc_r : std_logic; --! Shift register (used to capture rising edge)

begin

    -- MMCM
    mmcm : entity work.mmcm
        port map (
            clk_logic     => clk_logic,
            clk_ref100mhz => clk_ref100mhz
        );

    -- Seven Segment
    sevenseg : entity work.sevenseg
        port map (
            clk      => clk_logic,
            i_wr     => s_sevenseg_wr,
            i_addr   => s_sevenseg_addr,
            i_data   => s_sevenseg_data,
            o_seg_an => o_seg_an,
            o_seg    => o_seg
        );

    -- Center Button debouncer
    debouncer : entity work.debouncer
        port map (
            clk        => clk_logic,
            i_resetn   => i_resetn,
            i_sw       => i_btnc,
            o_sw_clean => s_btnc
        );

    -- LED Toggle Logic
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

    -- Center Button controls 7 segment display
    p_cbutton : process (clk_logic, i_resetn) is

        variable v_cntr : unsigned(2 downto 0);

    begin

        -- Wonky test: cpu_resetn probably starts at 0 after boot
        if (rising_edge(clk_logic)) then
            s_sevenseg_wr <= '0';
            s_btnc_r      <= s_btnc;

            -- On rising edge of button press increment cntr and write new symbol
            if (s_btnc = '1' and s_btnc_r = '0') then
                -- s_hold_rst      <= '0';
                s_sevenseg_wr   <= '1';
                s_sevenseg_addr <= v_cntr;
                v_cntr          := v_cntr + 1;
                s_sevenseg_data <= x"4";
            end if;
        end if;

    end process p_cbutton;

end architecture behav;
