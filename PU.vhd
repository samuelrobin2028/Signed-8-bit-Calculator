library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PU is
    port (
        aj   : in  std_logic;
        bi   : in  std_logic;
        cin  : in  std_logic;
        x_in : in  std_logic;
        sum  : out std_logic;
        cout : out std_logic
    );
end PU;

architecture structural of PU is
    component fa is
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            sum  : out std_logic;
            cout : out std_logic
        );
    end component;

    signal and_out : std_logic;
begin
    and_out <= aj and bi;

    FA1: fa port map (
        a    => and_out,
        b    => x_in,
        cin  => cin,
        sum  => sum,
        cout => cout
    );
end structural;


 






