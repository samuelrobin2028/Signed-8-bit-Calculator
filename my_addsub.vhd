library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_addsub is
    generic (N: integer := 5);
    port ( addsub : in std_logic;  -- 0: add, 1: subtract
           A, B   : in std_logic_vector(N-1 downto 0);
           cout   : out std_logic;
           S      : out std_logic_vector(N-1 downto 0));
end my_addsub;

architecture Structural of my_addsub is
    component fa
        port ( a, b, cin : in std_logic;
               sum, cout : out std_logic);
    end component;
    signal c    : std_logic_vector(N downto 0);
    signal Bxor : std_logic_vector(N-1 downto 0);
begin
    c(0) <= addsub;

    XORGEN: for i in 0 to N-1 generate
        Bxor(i) <= B(i) xor addsub;
    end generate;

    ADD_SUB: for i in 0 to N-1 generate
        FAx: fa port map (a => A(i), b => Bxor(i), cin => c(i), sum => S(i), cout => c(i+1));
    end generate;

    cout <= c(N);
end Structural;
