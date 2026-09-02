library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fa is
    port (
        a    : in  std_logic;
        b    : in  std_logic;
        cin  : in  std_logic;
        sum  : out std_logic;
        cout : out std_logic
    );
end fa;

architecture structural of fa is
begin
    sum  <= a xor b xor cin;
    cout <= (a and b) or (a and cin) or (b and cin);
end structural;
