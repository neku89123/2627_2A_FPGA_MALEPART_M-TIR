library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_tb is
end entity;

architecture sim of encoder_tb is
    -- Constantes et signaux
    constant N : integer := 8;
    
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal A_left   : std_logic := '0';
    signal B_left   : std_logic := '0';
    signal A_right  : std_logic := '0';
    signal B_right  : std_logic := '0';
    
    signal o_leds   : std_logic_vector(N-1 downto 0);
    signal o_x      : natural;
    signal o_y      : natural;

    -- Période d'horloge (ex: 20 ns -> 50 MHz)
    constant CLK_PERIOD : time := 20 ns;

begin

    -- Instanciation de l'unité sous test (UUT)
    uut: entity work.encoder
        generic map (
            N => N
        )
        port map (
            clk      => clk,
            reset    => reset,
            A_left   => A_left,
            B_left   => B_left,
            A_right  => A_right,
            B_right  => B_right,
            o_leds   => o_leds,
            o_x      => o_x,
            o_y      => o_y
        );

    -- Générateur d'horloge
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processus de simulation des stimuli pour les deux encodeurs
    stim_process : process
    begin
        -- 1. Phase de reset initial
        reset <= '0';
        A_left <= '0'; B_left <= '0';
        A_right <= '0'; B_right <= '0';
        wait for 100 ns;
        reset <= '1'; -- Désactivation du reset
        wait for 200 ns;

        -- 2. Test de l'encodeur GAUCHE (Incrémentation - sens horaire)
        -- Séquence : 00 -> 10 -> 11 -> 01 -> 00
        A_left <= '1'; B_left <= '0'; wait for 500 ns;
        A_left <= '1'; B_left <= '1'; wait for 500 ns;
        A_left <= '0'; B_left <= '1'; wait for 500 ns;
        A_left <= '0'; B_left <= '0'; wait for 500 ns;

        -- 3. Test de l'encodeur DROIT (Décrémentation - sens anti-horaire)
        -- Séquence inverse : 00 -> 01 -> 11 -> 10 -> 00
        A_right <= '0'; B_right <= '1'; wait for 500 ns;
        A_right <= '1'; B_right <= '1'; wait for 500 ns;
        A_right <= '1'; B_right <= '0'; wait for 500 ns;
        A_right <= '0'; B_right <= '0'; wait for 500 ns;

        -- Fin de la simulation
        wait;
    end process;

end architecture;