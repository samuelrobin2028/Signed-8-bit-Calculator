library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_pashiftreg_sclr is
    generic (N: integer := 6);
    port ( clock, resetn, sclr, E, s_L, w : in std_logic;
           D : in std_logic_vector(N-1 downto 0);
           Q : out std_logic_vector(N-1 downto 0));
end my_pashiftreg_sclr;

architecture Behavioral of my_pashiftreg_sclr is
    signal Qt : std_logic_vector(N-1 downto 0);
begin
    process (resetn, clock)
    begin
        if resetn = '0' then
            Qt <= (others => '0');
        elsif (clock'event and clock = '1') then
            if E = '1' then
                if sclr = '1' then
                    Qt <= (others => '0');
                elsif s_L = '1' then
                    Qt <= D;
                else
                    Qt <= Qt(N-2 downto 0) & w;
                end if;
            end if;
        end if;
    end process;

    Q <= Qt;
end Behavioral;

