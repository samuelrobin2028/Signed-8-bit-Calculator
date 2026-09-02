library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_fsm is
    port ( resetn, clock, s        : in  std_logic;
           opsel                   : in  std_logic_vector(1 downto 0); -- 00 add,01 sub,10 mult,11 div
           cout, zC, bzero         : in  std_logic;
           sclrR, ER, EC, sclrC    : out std_logic;
           LAB, EA, LR             : out std_logic;
           done, div0              : out std_logic);
end my_fsm;

architecture Behavioral of my_fsm is
    type state_type is (S1, S2, S3, S4);
    signal state : state_type;
begin

    Transitions: process (resetn, clock)
    begin
        if resetn = '0' then
            state <= S1;
        elsif (clock'event and clock = '1') then
            case state is
                when S1 =>
                    if s = '0' then
                        state <= S1;
                    elsif opsel = "11" and bzero = '1' then
                        state <= S4;
                    elsif opsel = "11" then
                        state <= S2;
                    else
                        state <= S3;
                    end if;
                when S2 =>
                    if zC = '1' then state <= S3; else state <= S2; end if;
                when S3 =>
                    if s = '0' then state <= S1; else state <= S3; end if;
                when S4 =>
                    if s = '0' then state <= S1; else state <= S4; end if;
            end case;
        end if;
    end process;

    Outputs: process (state, s, cout, zC, opsel, bzero)
    begin
        sclrR <= '0'; ER <= '0'; EC <= '0'; sclrC <= '0';
        LAB   <= '0'; EA <= '0'; LR <= '0'; done <= '0'; div0 <= '0';

        case state is
            when S1 =>
                sclrR <= '1'; ER <= '1'; EC <= '1'; sclrC <= '1';
                if s = '1' then
                    LAB <= '1'; EA <= '1';
                end if;
            when S2 =>
                ER <= '1'; EA <= '1';
                if cout = '1' then
                    LR <= '1';
                end if;
                if zC = '0' then
                    EC <= '1';
                end if;
            when S3 =>
                done <= '1';
            when S4 =>
                done <= '1';
                div0 <= '1';
        end case;
    end process;

end Behavioral;

