library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_rege is
    generic (N: integer := 4);
    port ( clock, resetn, E : in std_logic;
           D : in std_logic_vector(N-1 downto 0);
           Q : out std_logic_vector(N-1 downto 0));
end my_rege;

architecture Behavioral of my_rege is
begin
    process (resetn, clock)
    begin
        if resetn = '0' then
            Q <= (others => '0');
        elsif (clock'event and clock = '1') then
            if E = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end Behavioral;
