library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity encoder is
    generic (
        N : integer := 8 
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        A_left   : in  std_logic;
        B_left   : in  std_logic;
        A_right  : in  std_logic;
        B_right  : in  std_logic;
        o_leds   : out std_logic_vector(N-1 downto 0)
    );
end encoder;

architecture Behavioral of encoder is
    constant CLK_DIV_FACTOR : integer := 5000000; 

    signal clk_enable : std_logic := '0';

    signal a_lq1, a_lq2 : std_logic := '0';
    signal b_lq1, b_lq2 : std_logic := '0';
    signal a_rq1, a_rq2 : std_logic := '0';
    signal b_rq1, b_rq2 : std_logic := '0';
    
    signal a_lrising, a_lfalling : std_logic;
    signal b_lrising, b_lfalling : std_logic;
    signal a_rrising, a_rfalling : std_logic;
    signal b_rrising, b_rfalling : std_logic;
    
    signal counter_left  : unsigned(3 downto 0) := (others => '0');
    signal counter_right : unsigned(3 downto 0) := (others => '0');
begin

    process(clk, reset)
        variable prescaler_counter : integer range 0 to CLK_DIV_FACTOR - 1 := 0;
    begin
        if rising_edge(clk) then
            if reset = '0' then
                prescaler_counter := 0;
                clk_enable <= '0';
            else
                if prescaler_counter = CLK_DIV_FACTOR - 1 then
                    prescaler_counter := 0;
                    clk_enable <= '1'; 
                else
                    prescaler_counter := prescaler_counter + 1;
                    clk_enable <= '0';
                end if;
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                a_lq1 <= '0'; a_lq2 <= '0';
                b_lq1 <= '0'; b_lq2 <= '0';
                a_rq1 <= '0'; a_rq2 <= '0';
                b_rq1 <= '0'; b_rq2 <= '0';
            elsif clk_enable = '1' then
                a_lq1 <= A_left;   a_lq2 <= a_lq1;
                b_lq1 <= B_left;   b_lq2 <= b_lq1;
                a_rq1 <= A_right;  a_rq2 <= a_rq1;
                b_rq1 <= B_right;  b_rq2 <= b_rq1;
            end if;
        end if;
    end process;

    a_lrising  <= a_lq1 and not a_lq2;
    a_lfalling <= not a_lq1 and a_lq2;
    b_lrising  <= b_lq1 and not b_lq2;
    b_lfalling <= not b_lq1 and b_lq2;
    
    a_rrising  <= a_rq1 and not a_rq2;
    a_rfalling <= not a_rq1 and a_rq2;
    b_rrising  <= b_rq1 and not b_rq2;
    b_rfalling <= not b_rq1 and b_rq2;

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                counter_left  <= (others => '0');
                counter_right <= (others => '0');
            elsif clk_enable = '1' then
                -- Encodeur Gauche
                if (a_lrising and not b_lq2) = '1' or (a_lfalling and b_lq2) = '1' then
                    counter_left <= counter_left + 1;
                elsif (b_lrising and not a_lq2) = '1' or (b_lfalling and a_lq2) = '1' then
                    counter_left <= counter_left - 1;
                end if;

                -- Encodeur Droit
                if (a_rrising and not b_rq2) = '1' or (a_rfalling and b_rq2) = '1' then
                    counter_right <= counter_right + 1;
                elsif (b_rrising and not a_rq2) = '1' or (b_rfalling and a_rq2) = '1' then
                    counter_right <= counter_right - 1;
                end if;
            end if;
        end if;
    end process;

    o_leds <= std_logic_vector(counter_right) & std_logic_vector(counter_left);

end Behavioral;