library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity my_arrmult is
    generic (N : integer := 8);
    port ( A : in  std_logic_vector(N-1 downto 0);
           B : in  std_logic_vector(N-1 downto 0);
           P : out std_logic_vector(2*N-1 downto 0));
end my_arrmult;

architecture Structural of my_arrmult is
    component PU
        port ( aj, bi, cin, x_in : in  std_logic;
               sum, cout         : out std_logic);
    end component;

    type row_t is array (0 to N-1) of std_logic_vector(N-1 downto 0);
    signal s, c, xin : row_t;  -- s(row)(col), c(row)(col), xin(row)(col)
begin

    ROWS: for r in 0 to N-1 generate
        COLS: for cc in 0 to N-1 generate

            ROW0: if r = 0 generate
                xin(r)(cc) <= '0';
            end generate;
            LASTCOL: if r > 0 and cc = N-1 generate
                xin(r)(cc) <= c(r-1)(N-1);
            end generate;
            MIDCOL: if r > 0 and cc < N-1 generate
                xin(r)(cc) <= s(r-1)(cc+1);
            end generate;

            CIN0: if cc = 0 generate
                PUx: PU port map (aj => A(cc), bi => B(r), cin => '0',
                                   x_in => xin(r)(cc), sum => s(r)(cc), cout => c(r)(cc));
            end generate;
            CINN: if cc > 0 generate
                PUx: PU port map (aj => A(cc), bi => B(r), cin => c(r)(cc-1),
                                   x_in => xin(r)(cc), sum => s(r)(cc), cout => c(r)(cc));
            end generate;

        end generate COLS;
    end generate ROWS;

    OUT_LOW: for r in 0 to N-1 generate
        P(r) <= s(r)(0);
    end generate;
    OUT_HIGH: for k in 1 to N-1 generate
        P(N-1+k) <= s(N-1)(k);
    end generate;
    P(2*N-1) <= c(N-1)(N-1);

end Structural;
