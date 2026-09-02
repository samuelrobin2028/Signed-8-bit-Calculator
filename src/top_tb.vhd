library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is

    component top
        port ( clock, resetn               : in  std_logic;
               BTNU, BTND, BTNL, BTNR, BTNC : in  std_logic;
               SW                           : in  std_logic_vector(15 downto 0);
               done_led                     : out std_logic;
               AN                           : out std_logic_vector(7 downto 0);
               CA_CG                        : out std_logic_vector(6 downto 0));
    end component;

    signal clock, resetn                : std_logic := '0';
    signal BTNU, BTND, BTNL, BTNR, BTNC  : std_logic := '0';
    signal SW                            : std_logic_vector(15 downto 0) := (others => '0');
    signal done_led                      : std_logic;
    signal AN                            : std_logic_vector(7 downto 0);
    signal CA_CG                         : std_logic_vector(6 downto 0);

    constant clk_period : time := 10 ns; -- 100 MHz

begin

    UUT: top port map (clock => clock, resetn => resetn,
                        BTNU => BTNU, BTND => BTND, BTNL => BTNL, BTNR => BTNR, BTNC => BTNC,
                        SW => SW, done_led => done_led, AN => AN, CA_CG => CA_CG);

    CLK_GEN: process
    begin
        clock <= '0'; wait for clk_period/2;
        clock <= '1'; wait for clk_period/2;
    end process;

    STIM: process
    begin
        resetn <= '0';
        wait for 20 ns;
        resetn <= '1';
        wait for 20 ns;

        SW <= std_logic_vector(to_signed(45, 8)) & std_logic_vector(to_signed(30, 8));
        BTNU <= '1'; wait for clk_period; BTNU <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(-128, 8)) & std_logic_vector(to_signed(-128, 8));
        BTNU <= '1'; wait for clk_period; BTNU <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(50, 8)) & std_logic_vector(to_signed(90, 8));
        BTND <= '1'; wait for clk_period; BTND <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(127, 8)) & std_logic_vector(to_signed(-128, 8));
        BTND <= '1'; wait for clk_period; BTND <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(12, 8)) & std_logic_vector(to_signed(-10, 8));
        BTNL <= '1'; wait for clk_period; BTNL <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(-128, 8)) & std_logic_vector(to_signed(-128, 8));
        BTNL <= '1'; wait for clk_period; BTNL <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        SW <= std_logic_vector(to_signed(100, 8)) & std_logic_vector(to_signed(7, 8));
        BTNR <= '1'; wait for clk_period; BTNR <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 300 ns;

        SW <= std_logic_vector(to_signed(-100, 8)) & std_logic_vector(to_signed(7, 8));
        BTNR <= '1'; wait for clk_period; BTNR <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 300 ns;

        SW <= std_logic_vector(to_signed(50, 8)) & std_logic_vector(to_signed(0, 8));
        BTNR <= '1'; wait for clk_period; BTNR <= '0';
        wait for clk_period;
        BTNC <= '1'; wait for 2*clk_period; BTNC <= '0';
        wait for 200 ns;

        report "Simulation complete." severity note;
        wait;
    end process;

end Behavioral;


