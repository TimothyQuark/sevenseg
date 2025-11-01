library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.util.all;

entity sevenseg is
    port (
        clk_logic : in    std_logic;
        wr        : in    std_logic;                    -- New Symbol is being written
        sym       : in    unsigned(3 downto 0);         -- Which symbol to output
        seg       : out   std_logic_vector(6 downto 0); -- 7 Segment encoding
        sel       : out   std_logic_vector(7 downto 0)  -- Select a 7 segment to draw
    );
end entity sevenseg;

architecture behav of sevenseg is

    signal clk_slow   : std_logic;             -- Very slow 7 segment clock
    signal s_cntr     : unsigned(16 downto 0); -- Counter to derive slow clock (200 MHz / 2**27 = 1.5s)
    signal s_seg_code : std_logic_vector(6 downto 0);

    type seg_array_t is array (0 to 7) of std_logic_vector(6 downto 0);

    signal s_seg_list : seg_array_t := (
                                        not "0111111",
                                        not "0000110",
                                        not "1011011",
                                        not "1001111",
                                        not "1100110",
                                        not "1101101",
                                        not "1111101",
                                        not "0000111"
                                       );

begin

    p_cntr : process (clk_logic) is
    begin

        if (rising_edge(clk_logic)) then
            s_cntr <= s_cntr + 1;

            clk_slow <= '0';
            if (s_cntr(s_cntr'high) = '1') then
                clk_slow <= '1';
            end if;
        end if;

    end process p_cntr;

    p_strobe : process (clk_slow) is

        -- Strobe and index initialized to start writing from 7 segment AN0
        variable strobe : std_logic_vector(7 downto 0) := "01111111";
        variable index  : unsigned(3 downto 0)         := x"0";

    begin

        if (rising_edge(clk_slow)) then
            strobe := strobe(strobe'high - 1 downto 0) & strobe(strobe'high);
            sel    <= strobe;

            seg   <= s_seg_list(to_integer(index));
            index := index + 1; -- Overflow is desired
        end if;

    end process p_strobe;

-- p_strobe : process (clk_slow) is

--     variable strobe : std_logic_vector(7 downto 0) := "11111110";

-- begin

--     if (rising_edge(clk_slow)) then
--         strobe := strobe(strobe'high - 1 downto 0) & strobe(strobe'high);
--         sel    <= strobe;

--         seg <= s_seg_list(0);

--     end if;

-- end process p_strobe;

-- -- Combinational logic: converts Symbol into 7 segment code
-- p_sym : process (sym) is
-- begin

--     case sym is

--         when X"0" =>

--             s_seg_code <= not "0111111"; -- 0

--         when X"1" =>

--             s_seg_code <= not "0000110"; -- 1

--         when X"2" =>

--             s_seg_code <= not "1011011"; -- 2

--         when X"3" =>

--             s_seg_code <= not "1001111"; -- 3

--         when X"4" =>

--             s_seg_code <= not "1100110"; -- 4

--         when X"5" =>

--             s_seg_code <= not "1101101"; -- 5

--         when X"6" =>

--             s_seg_code <= not "1111101"; -- 6

--         when X"7" =>

--             s_seg_code <= not "0000111"; -- 7

--         when X"8" =>

--             s_seg_code <= not "1111111"; -- 8

--         when X"9" =>

--             s_seg_code <= not "1111011" "1101111"; -- 9

--         when X"A" =>

--             s_seg_code <= not "1110111" "1110111"; -- A

--         when X"B" =>

--             s_seg_code <= not "0011111" "1111100"; -- B

--         when X"C" =>

--             s_seg_code <= not "1001110"; -- C

--         when X"D" =>

--             s_seg_code <= not "0111101"; -- D

--         when X"E" =>

--             s_seg_code <= not "1001111"; -- E

--         when X"F" =>

--             s_seg_code <= not "0100101"; -- / (Slash symbol)

--     end case;

-- end process p_sym;

-- -- Register the 7 segment output
-- p_seg : process (clk_slow) is
-- begin

--     if (rising_edge(clk_slow)) then
--         seg <= s_seg_code;
--     end if;

-- end process p_seg;

end architecture behav;
