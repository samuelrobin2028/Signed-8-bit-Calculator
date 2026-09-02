library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity my_7seg_scan is
    port ( clock, resetn : in std_logic;
           d7,d6,d5,d4,d3,d2,d1,d0 : in std_logic_vector(3 downto 0);
           AN         : out std_logic_vector(7 downto 0);
           digit_code : out std_logic_vector(3 downto 0));
end my_7seg_scan;

architecture Behavioral of my_7seg_scan is
    signal cnt : std_logic_vector(16 downto 0);
begin
    process (resetn, clock)
    begin
        if resetn = '0' then cnt <= (others => '0');
        elsif clock'event and clock = '1' then cnt <= cnt + 1;
        end if;
    end process;

    process (cnt, d7,d6,d5,d4,d3,d2,d1,d0)
    begin
        case cnt(16 downto 14) is
            when "000" => AN <= "11111110"; digit_code <= d0;  -- AN0, rightmost
            when "001" => AN <= "11111101"; digit_code <= d1;
            when "010" => AN <= "11111011"; digit_code <= d2;
            when "011" => AN <= "11110111"; digit_code <= d3;
            when "100" => AN <= "11101111"; digit_code <= d4;
            when "101" => AN <= "11011111"; digit_code <= d5;
            when "110" => AN <= "10111111"; digit_code <= d6;
            when others => AN <= "01111111"; digit_code <= d7; -- AN7, leftmost
        end case;
    end process;
end Behavioral;
