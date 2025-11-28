library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-- use work.util.all;

entity sevenseg is
    port (
        clk_logic : in    std_logic;
        i_wr      : in    std_logic;                    --! Write new symbol to 7 segment
        i_addr    : in    unsigned(2 downto 0);         --! Which 7 segment to update
        i_data    : in    unsigned(3 downto 0);         --! Which symbol to update with
        o_seg_an  : out   std_logic_vector(7 downto 0); --! Select a 7 segment to illuminate
        o_seg     : out   std_logic_vector(6 downto 0)  --! 7 Segment encodings
    );
end entity sevenseg;

architecture behav of sevenseg is

    -- Clock made in logic because it drives only 1 signal. A slower clock will dim
    -- the segment displays Vivado Implementation has a HIGH warning for this logic,
    -- but way better than fiddling with MMCM cascading or CLK EN
    signal clk_slow : std_logic;             --! Very slow 7 segment clock (Should be 60 Hz to 1 KHz)
    signal s_cntr   : unsigned(17 downto 0); --! Counter to derive slow clock (200 MHz / 2**18 / 8 displays = 95 Hz)

    signal s_sig : std_logic_vector(6 downto 0); --! 7 segment symbol

    type t_seg_array is array (0 to 7) of std_logic_vector(6 downto 0);

    --! BRAM that stores symbols for all 7 segment display
    signal s_seg_list : t_seg_array := (
                                        not "1111111",
                                        not "1101111",
                                        not "1110111",
                                        not "1111100",
                                        not "0111001",
                                        not "1011110",
                                        not "1111001",
                                        not "1010010"
                                       );

begin

    p_slow_clk : process (clk_logic) is
    begin

        if (rising_edge(clk_logic)) then
            s_cntr <= s_cntr + 1;

            clk_slow <= '0';
            if (s_cntr(s_cntr'high) = '1') then
                clk_slow <= '1';
            end if;
        end if;

    end process p_slow_clk;

    p_strobe : process (clk_slow) is

        -- Active low selects which seven segment is to be illuminated
        -- Strobe and index initialized to start writing from 7 segment AN0
        variable strobe : std_logic_vector(7 downto 0) := "01111111";
        variable index  : unsigned(3 downto 0)         := x"0";

    begin

        if (rising_edge(clk_slow)) then
            strobe   := strobe(strobe'high - 1 downto 0) & strobe(strobe'high);
            o_seg_an <= strobe;

            o_seg <= s_seg_list(to_integer(index));
            index := index + 1; -- Overflow is desired
        end if;

    end process p_strobe;

    p_wr : process (clk_logic) is
    begin

        if (rising_edge(clk_logic)) then
            if (i_wr = '1') then
                s_seg_list(to_integer(i_addr)) <= s_sig;
            end if;
        end if;

    end process p_wr;

    -- Combinational logic: converts Symbol into 7 segment code
    p_sym : process (i_data) is
    begin

        case i_data is

            when X"0" =>

                s_sig <= not "0111111";  -- 0

            when X"1" =>

                s_sig <= not "0000110";  -- 1

            when X"2" =>

                s_sig <= not "1011011";  -- 2

            when X"3" =>

                s_sig <= not "1001111";  -- 3

            when X"4" =>

                s_sig <= not "1100110";  -- 4

            when X"5" =>

                s_sig <= not "1101101";  -- 5

            when X"6" =>

                s_sig <= not "1111101";  -- 6

            when X"7" =>

                s_sig <= not "0000111";  -- 7

            when X"8" =>

                s_sig <= not "1111111";  -- 8

            when X"9" =>

                s_sig <= not "1101111";  -- 9

            when X"A" =>

                s_sig <= not "1110111";  -- A

            when X"B" =>

                s_sig <= not "1111100";  -- B

            when X"C" =>

                s_sig <= not "0111001";  -- C

            when X"D" =>

                s_sig <= not  "1011110"; -- D

            when X"E" =>

                s_sig <= not  "1111001"; -- E

            when X"F" =>

                s_sig <= not  "1010010"; -- / (Slash symbol)

            when others =>

                s_sig <= not  "1111111"; -- / (Slash symbol)

        end case;

    end process p_sym;

end architecture behav;
