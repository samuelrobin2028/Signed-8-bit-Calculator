library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity top is
    port ( clock, resetn               : in  std_logic;
           BTNU, BTND, BTNL, BTNR, BTNC : in  std_logic; -- op-select + start(=BTNC)
           SW                           : in  std_logic_vector(15 downto 0); -- SW15-8=A, SW7-0=B
           done_led                    : out std_logic;
           AN                          : out std_logic_vector(7 downto 0);
           CA_CG                       : out std_logic_vector(6 downto 0));
end top;

architecture Structural of top is

    component my_rege
        generic (N: integer := 4);
        port ( clock, resetn, E : in std_logic;
               D : in std_logic_vector(N-1 downto 0);
               Q : out std_logic_vector(N-1 downto 0));
    end component;

    component my_pashiftreg_sclr
        generic (N: integer := 6);
        port ( clock, resetn, sclr, E, s_L, w : in std_logic;
               D : in std_logic_vector(N-1 downto 0);
               Q : out std_logic_vector(N-1 downto 0));
    end component;

    component my_addsub
        generic (N: integer := 5);
        port ( addsub : in std_logic;
               A, B   : in std_logic_vector(N-1 downto 0);
               cout   : out std_logic;
               S      : out std_logic_vector(N-1 downto 0));
    end component;

    component my_genpulse_sclr
        generic (COUNT: integer := 6);
        port ( clock, resetn, E, sclr : in std_logic;
               Q : out std_logic_vector(integer(ceil(log2(real(COUNT)))) - 1 downto 0);
               z : out std_logic);
    end component;

    component my_abs
        generic (N: integer := 8);
        port ( D   : in  std_logic_vector(N-1 downto 0);
               sgn : out std_logic;
               mag : out std_logic_vector(N-1 downto 0));
    end component;

    component my_arrmult
        generic (N : integer := 8);
        port ( A, B : in  std_logic_vector(N-1 downto 0);
               P    : out std_logic_vector(2*N-1 downto 0));
    end component;

    component my_bin2bcd
        generic (NBITS: integer := 8; NDIGITS: integer := 3);
        port ( bin : in  std_logic_vector(NBITS-1 downto 0);
               bcd : out std_logic_vector(NDIGITS*4-1 downto 0));
    end component;

    component my_char7seg
        port ( code : in  std_logic_vector(3 downto 0);
               leds : out std_logic_vector(6 downto 0));
    end component;

    component my_7seg_scan
        port ( clock, resetn : in std_logic;
               d7,d6,d5,d4,d3,d2,d1,d0 : in std_logic_vector(3 downto 0);
               AN         : out std_logic_vector(7 downto 0);
               digit_code : out std_logic_vector(3 downto 0));
    end component;

    component my_fsm
        port ( resetn, clock, s        : in  std_logic;
               opsel                   : in  std_logic_vector(1 downto 0);
               cout, zC, bzero         : in  std_logic;
               sclrR, ER, EC, sclrC    : out std_logic;
               LAB, EA, LR             : out std_logic;
               done, div0              : out std_logic);
    end component;

    signal opsel          : std_logic_vector(1 downto 0) := "00";
    signal A_cap, B_cap   : std_logic_vector(7 downto 0);

    signal A9, B9         : std_logic_vector(8 downto 0);
    signal addsub_ctrl    : std_logic;
    signal AS_res9        : std_logic_vector(8 downto 0);
    signal sign_AS        : std_logic;
    signal mag_AS9        : std_logic_vector(8 downto 0);

    signal magA8, magB8   : std_logic_vector(7 downto 0);
    signal sgn_unusedA, sgn_unusedB : std_logic;
    signal bzero          : std_logic;

    signal signA, signB   : std_logic;

    signal P16            : std_logic_vector(15 downto 0);
    signal sign_M         : std_logic;

    signal sclrR, ER, EC, sclrC : std_logic;
    signal LAB, EA, LR          : std_logic;
    signal done, div0           : std_logic;

    signal cout_div, zC_div     : std_logic;
    signal Adiv_reg, Bdiv_reg, Rdiv_reg : std_logic_vector(7 downto 0);
    signal a7                   : std_logic;
    signal Xdiv, Bextdiv, Tdiv  : std_logic_vector(8 downto 0);
    signal qc_div                : std_logic_vector(2 downto 0);
    signal sign_Q, sign_R        : std_logic;

    signal bcd_AS : std_logic_vector(19 downto 0);
    signal bcd_M  : std_logic_vector(19 downto 0);
    signal bcd_Q  : std_logic_vector(11 downto 0);
    signal bcd_R  : std_logic_vector(11 downto 0);

    signal hold_opsel   : std_logic_vector(1 downto 0) := "00";
    signal hold_sign_AS, hold_sign_M, hold_sign_Q, hold_sign_R, hold_div0 : std_logic := '0';
    signal hold_bcd_AS  : std_logic_vector(19 downto 0) := (others => '0');
    signal hold_bcd_M   : std_logic_vector(19 downto 0) := (others => '0');
    signal hold_bcd_Q   : std_logic_vector(11 downto 0) := (others => '0');
    signal hold_bcd_R   : std_logic_vector(11 downto 0) := (others => '0');

    signal d7,d6,d5,d4,d3,d2,d1,d0 : std_logic_vector(3 downto 0);
    signal digit_code             : std_logic_vector(3 downto 0);
    signal leds                   : std_logic_vector(6 downto 0);

begin

    done_led <= done;

    OPSEL_LATCH: process (resetn, clock)
    begin
        if resetn = '0' then
            opsel <= "00";
        elsif (clock'event and clock = '1') then
            if    BTNU = '1' then opsel <= "00";  -- add
            elsif BTND = '1' then opsel <= "01";  -- sub
            elsif BTNL = '1' then opsel <= "10";  -- mult
            elsif BTNR = '1' then opsel <= "11";  -- div
            end if;
        end if;
    end process;

    CAP_A: my_rege generic map (N => 8)
        port map (clock => clock, resetn => resetn, E => LAB, D => SW(15 downto 8), Q => A_cap);
    CAP_B: my_rege generic map (N => 8)
        port map (clock => clock, resetn => resetn, E => LAB, D => SW(7 downto 0),  Q => B_cap);

    signA <= A_cap(7);
    signB <= B_cap(7);

    A9 <= A_cap(7) & A_cap;
    B9 <= B_cap(7) & B_cap;
    addsub_ctrl <= opsel(0);

    ADDSUB: my_addsub generic map (N => 9)
        port map (addsub => addsub_ctrl, A => A9, B => B9, cout => open, S => AS_res9);

    ABS_AS: my_abs generic map (N => 9)
        port map (D => AS_res9, sgn => sign_AS, mag => mag_AS9);

    ABS_A: my_abs generic map (N => 8) port map (D => SW(15 downto 8), sgn => sgn_unusedA, mag => magA8);
    ABS_B: my_abs generic map (N => 8) port map (D => SW(7 downto 0),  sgn => sgn_unusedB, mag => magB8);
    bzero <= '1' when SW(7 downto 0) = "00000000" else '0';

    a7 <= Adiv_reg(7);
    Xdiv    <= Rdiv_reg & a7;
    Bextdiv <= '0' & Bdiv_reg;

    REG_A_DIV: my_pashiftreg_sclr generic map (N => 8)
        port map (clock => clock, resetn => resetn, sclr => '0',
                   E => EA, s_L => LAB, w => LR, D => magA8, Q => Adiv_reg);

    REG_B_DIV: my_rege generic map (N => 8)
        port map (clock => clock, resetn => resetn, E => LAB, D => magB8, Q => Bdiv_reg);

    REG_R_DIV: my_pashiftreg_sclr generic map (N => 8)
        port map (clock => clock, resetn => resetn, sclr => sclrR,
                   E => ER, s_L => LR, w => a7, D => Tdiv(7 downto 0), Q => Rdiv_reg);

    SUB_DIV: my_addsub generic map (N => 9)
        port map (addsub => '1', A => Xdiv, B => Bextdiv, cout => cout_div, S => Tdiv);

    CNT_DIV: my_genpulse_sclr generic map (COUNT => 8)
        port map (clock => clock, resetn => resetn, E => EC, sclr => sclrC, Q => qc_div, z => zC_div);

    MULT: my_arrmult generic map (N => 8) port map (A => Adiv_reg, B => Bdiv_reg, P => P16);
    sign_M <= signA xor signB;

    sign_Q <= signA xor signB;
    sign_R <= signA;

    FSM: my_fsm
        port map (resetn => resetn, clock => clock, s => BTNC, opsel => opsel,
                   cout => cout_div, zC => zC_div, bzero => bzero,
                   sclrR => sclrR, ER => ER, EC => EC, sclrC => sclrC,
                   LAB => LAB, EA => EA, LR => LR, done => done, div0 => div0);

    BCDCONV_AS: my_bin2bcd generic map (NBITS => 9,  NDIGITS => 5) port map (bin => mag_AS9,  bcd => bcd_AS);
    BCDCONV_M:  my_bin2bcd generic map (NBITS => 16, NDIGITS => 5) port map (bin => P16,      bcd => bcd_M);
    BCDCONV_Q:  my_bin2bcd generic map (NBITS => 8,  NDIGITS => 3) port map (bin => Adiv_reg, bcd => bcd_Q);
    BCDCONV_R:  my_bin2bcd generic map (NBITS => 8,  NDIGITS => 3) port map (bin => Rdiv_reg, bcd => bcd_R);

    HOLD: process (resetn, clock)
    begin
        if resetn = '0' then
            hold_opsel <= "00"; hold_div0 <= '0';
            hold_sign_AS <= '0'; hold_bcd_AS <= (others => '0');
            hold_sign_M  <= '0'; hold_bcd_M  <= (others => '0');
            hold_sign_Q  <= '0'; hold_bcd_Q  <= (others => '0');
            hold_sign_R  <= '0'; hold_bcd_R  <= (others => '0');
        elsif (clock'event and clock = '1') then
            if done = '1' then
                hold_opsel   <= opsel;
                hold_div0    <= div0;
                hold_sign_AS <= sign_AS; hold_bcd_AS <= bcd_AS;
                hold_sign_M  <= sign_M;  hold_bcd_M  <= bcd_M;
                hold_sign_Q  <= sign_Q;  hold_bcd_Q  <= bcd_Q;
                hold_sign_R  <= sign_R;  hold_bcd_R  <= bcd_R;
            end if;
        end if;
    end process;

    -- Display mux -> 8 digit codes -> scanner -> 7-seg decoder
    DISP_MUX: process (hold_opsel, hold_div0, hold_sign_AS, hold_bcd_AS,
                        hold_sign_M, hold_bcd_M, hold_sign_Q, hold_bcd_Q,
                        hold_sign_R, hold_bcd_R)
    begin
        if hold_opsel = "11" and hold_div0 = '1' then
            d7 <= "1100"; d6 <= "1100"; d5 <= "1100"; d4 <= "1100";
            d3 <= "1100"; d2 <= "1100"; d1 <= "1100"; d0 <= "1100";
        elsif hold_opsel = "11" then
            if hold_sign_Q = '1' then d7 <= "1011"; else d7 <= "1010"; end if;
            d6 <= hold_bcd_Q(11 downto 8);
            d5 <= hold_bcd_Q(7  downto 4);
            d4 <= hold_bcd_Q(3  downto 0);
            if hold_sign_R = '1' then d3 <= "1011"; else d3 <= "1010"; end if;
            d2 <= hold_bcd_R(11 downto 8);
            d1 <= hold_bcd_R(7  downto 4);
            d0 <= hold_bcd_R(3  downto 0);
        elsif hold_opsel = "10" then
            d7 <= "1010"; d6 <= "1010";
            if hold_sign_M = '1' then d5 <= "1011"; else d5 <= "1010"; end if;
            d4 <= hold_bcd_M(19 downto 16);
            d3 <= hold_bcd_M(15 downto 12);
            d2 <= hold_bcd_M(11 downto 8);
            d1 <= hold_bcd_M(7  downto 4);
            d0 <= hold_bcd_M(3  downto 0);
        else
            d7 <= "1010"; d6 <= "1010";
            if hold_sign_AS = '1' then d5 <= "1011"; else d5 <= "1010"; end if;
            d4 <= hold_bcd_AS(19 downto 16);
            d3 <= hold_bcd_AS(15 downto 12);
            d2 <= hold_bcd_AS(11 downto 8);
            d1 <= hold_bcd_AS(7  downto 4);
            d0 <= hold_bcd_AS(3  downto 0);
        end if;
    end process;

    SCAN: my_7seg_scan
        port map (clock => clock, resetn => resetn,
                   d7=>d7, d6=>d6, d5=>d5, d4=>d4, d3=>d3, d2=>d2, d1=>d1, d0=>d0,
                   AN => AN, digit_code => digit_code);

    DEC: my_char7seg port map (code => digit_code, leds => leds);

    CA_CG <= not(leds);

end Structural;
