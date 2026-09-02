library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity my_bin2bcd is
    generic (NBITS: integer := 8; NDIGITS: integer := 3);
    port ( bin : in  std_logic_vector(NBITS-1 downto 0);
           bcd : out std_logic_vector(NDIGITS*4-1 downto 0));
end my_bin2bcd;

architecture Behavioral of my_bin2bcd is
begin
    process (bin)
        variable reg : std_logic_vector(NDIGITS*4+NBITS-1 downto 0);
    begin
        reg := (others => '0');
        reg(NBITS-1 downto 0) := bin;

        for i in 0 to NBITS-1 loop
            for d in 0 to NDIGITS-1 loop
                if reg(NBITS+d*4+3 downto NBITS+d*4) > "0100" then
                    reg(NBITS+d*4+3 downto NBITS+d*4) :=
                        reg(NBITS+d*4+3 downto NBITS+d*4) + "0011";
                end if;
            end loop;
            reg := reg(reg'high-1 downto 0) & '0';
        end loop;

        bcd <= reg(NDIGITS*4+NBITS-1 downto NBITS);
    end process;
end Behavioral;
