-- Debouncing FSM for physical buttons to reduce erronous double taps
-- Based upon an example from the book FPGA Prototyping by VHDL examples (Pong. P. Chu)

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity debouncer is
    port (
        clk        : in    std_logic; --! Logic clock
        i_resetn   : in    std_logic; --! Active low async reset button
        i_sw       : in    std_logic; --! Raw Button/switch
        o_sw_clean : out   std_logic  --! Debounced Button/switch
    );
end entity debouncer;

architecture behav of debouncer is

    constant n : integer := 20;

    type t_state is (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3);

    signal s_cntr  : unsigned(n - 1 downto 0); --! Check for next state every tick: 2**n * 10ns = 10ms ticks
    signal s_tick  : std_logic;                --! State transitions on tick
    signal st_reg  : t_state;                  --! Current state
    signal st_next : t_state;                  --! Next State

begin

    p_cntr : process (clk, i_resetn) is
    begin

        if (i_resetn = '0') then
            s_cntr <= (others => '0');
        elsif (rising_edge(clk)) then
            s_cntr <= s_cntr + 1;
        end if;

    end process p_cntr;

    s_tick <= '1' when s_cntr = 0 else
              '0';

    p_state_transition : process (clk, i_resetn) is
    begin

        if (i_resetn = '0') then
            st_reg <= zero;
        elsif (rising_edge(clk)) then
            st_reg <= st_next;
        end if;

    end process p_state_transition;

    p_fsm : process (st_reg, i_sw, s_tick) is
    begin

        st_next    <= st_reg;               -- default
        o_sw_clean <= '0';                  -- default

        case st_reg is

            when zero =>

                if (i_sw = '1') then
                    st_next <= wait1_1;
                end if;

            when wait1_1 =>

                if (i_sw = '0') then
                    st_next <= zero;
                else
                    if (s_tick = '1') then
                        st_next <= wait1_2;
                    end if;
                end if;

            when wait1_2 =>

                if (i_sw = '0') then
                    st_next <= zero;
                else
                    if (s_tick = '1') then
                        st_next <= wait1_3;
                    end if;
                end if;

            when wait1_3 =>

                if (i_sw = '0') then
                    st_next <= zero;
                else
                    if (s_tick = '1') then
                        st_next <= one;
                    end if;
                end if;

            when one =>

                o_sw_clean <= '1';

                if (i_sw = '0') then
                    st_next <= wait0_1;
                end if;

            when wait0_1 =>

                o_sw_clean <= '1';

                if (i_sw = '1') then
                    st_next <= one;
                else
                    if (s_tick = '1') then
                        st_next <= wait0_2;
                    end if;
                end if;

            when wait0_2 =>

                o_sw_clean <= '1';

                if (i_sw = '1') then
                    st_next <= one;
                else
                    if (s_tick = '1') then
                        st_next <= wait0_3;
                    end if;
                end if;

            when wait0_3 =>

                o_sw_clean <= '1';

                if (i_sw = '1') then
                    st_next <= one;
                else
                    if (s_tick = '1') then
                        st_next <= zero;
                    end if;
                end if;

        end case;

    end process p_fsm;

end architecture behav;
