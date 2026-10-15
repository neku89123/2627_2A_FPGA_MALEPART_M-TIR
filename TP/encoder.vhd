library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity encoder is
    generic (
        N : integer := 10 
    );
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        A     : in  std_logic;
        B     : in  std_logic;
        o_leds   : out std_logic_vector(N-1 downto 0)
    );
end encoder;

architecture Behavioral of encoder is
    constant CLK_DIV_FACTOR : integer := 5000000; 

    signal clk_enable : std_logic := '0';

    signal a_q1, a_q2 : std_logic := '0';
    signal b_q1, b_q2 : std_logic := '0';
    
    signal a_rising, a_falling : std_logic;
    signal b_rising, b_falling : std_logic;
    
    signal counter_reg : unsigned(N-1 downto 0) := (others => '0');
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
                a_q1 <= '0';
                a_q2 <= '0';
                b_q1 <= '0';
                b_q2 <= '0';
            elsif clk_enable = '1' then
                a_q1 <= A;
                a_q2 <= a_q1;
                b_q1 <= B;
                b_q2 <= b_q1;
            end if;
        end if;
    end process;

    a_rising  <= a_q1 and not a_q2;
    a_falling <= not a_q1 and a_q2;
    b_rising  <= b_q1 and not b_q2;
    b_falling <= not b_q1 and a_q2; -- (ou b_q2)

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                counter_reg <= (others => '0');
            elsif clk_enable = '1' then
                if (a_rising and not b_q2) = '1' or (a_falling and b_q2) = '1' then
                    counter_reg <= counter_reg + 1;
                elsif (b_rising and not a_q2) = '1' or (b_falling and a_q2) = '1' then
                    counter_reg <= counter_reg - 1;
                end if;
            end if;
        end if;
    end process;

    o_leds <= std_logic_vector(counter_reg);

end Behavioral;