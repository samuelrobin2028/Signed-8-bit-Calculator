library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_char7seg is
    port ( code : in  std_logic_vector(3 downto 0);  -- 0-9=digit,10=blank,11=minus,12=error
           leds : out std_logic_vector(6 downto 0));
end my_char7seg;

architecture structure of my_char7seg is
begin
    with code select
        leds <= "1111110" when "0000", "0110000" when "0001",
                "1101101" when "0010", "1111001" when "0011",
                "0110011" when "0100", "1011011" when "0101",
                "1011111" when "0110", "1110000" when "0111",
                "1111111" when "1000", "1111011" when "1001",
                "0000000" when "1010",   -- blank
                "0000001" when "1011",   -- '-'
                "1001111" when "1100",   -- 'E' error
                "0000000" when others;
end structure;






