library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity my_abs is
    generic (N: integer := 8);
    port ( D   : in  std_logic_vector(N-1 downto 0);
           sgn : out std_logic;
           mag : out std_logic_vector(N-1 downto 0));
end my_abs;

architecture Behavioral of my_abs is
begin
    sgn <= D(N-1);
    mag <= D when D(N-1) = '0' else (not D) + conv_std_logic_vector(1, N);
end Behavioral;
