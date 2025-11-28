-- Debouncing FSM for physical buttons to reduce erronous double taps
-- Based upon an example from the book FPGA Prototyping by VHDL examples (Pong. P. Chu)

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity debouncer is
    port (
        clk   : in    std_logic;
        i_rst : in    std_logic;
        i_sw  : in    std_logic;
        o_db  : out   std_logic
    );
end entity debouncer;

architecture behav of debouncer is

begin

end architecture behav;
