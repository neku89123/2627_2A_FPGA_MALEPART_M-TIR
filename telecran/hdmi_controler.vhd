library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hdmi_controler is
    generic (
        h_res  : natural := 720;
        v_res  : natural := 480;
        h_sync : natural := 61;
        h_fp   : natural := 58;
        h_bp   : natural := 18;
        v_sync : natural := 5;
        v_fp   : natural := 30;
        v_bp   : natural := 9
    );
    port (
        clk            : in  std_logic;
        reset          : in  std_logic;
        o_hdmi_hs      : out std_logic;
        o_hdmi_vs      : out std_logic;
        o_hdmi_de      : out std_logic;
        o_pixel_en     : out std_logic;
        o_x_counter    : out natural;
        o_y_counter    : out natural;
        o_pixel_adress : out natural
    );
end entity hdmi_controler;

architecture Behavioral of hdmi_controler is

    constant h_total : natural := h_res + h_sync + h_fp + h_bp;
    constant h_start : natural := h_sync + h_bp;        
    constant h_end   : natural := h_sync + h_bp + h_res;  

    signal r_h_count  : natural := 0;
    signal r_h_active : std_logic := '0';

    constant v_total : natural := v_res + v_sync + v_fp + v_bp;
    constant v_start : natural := v_sync + v_bp;        
    constant v_end   : natural := v_sync + v_bp + v_res;  

    signal r_v_count  : natural := 0;
    signal r_v_active : std_logic := '0';

begin

    process(clk, reset)
    begin
        if rising_edge(clk) then
            -- Horizontal
            if reset = '1' then
                r_h_count  <= 0;
                o_hdmi_hs  <= '1';
                r_h_active <= '0';
            else
                if r_h_count = h_total then
                    r_h_count <= 0;
                else
                    r_h_count <= r_h_count + 1;
                end if;
                if (r_h_count >= h_sync) and (r_h_count /= h_total) then
                    o_hdmi_hs <= '1';
                else
                    o_hdmi_hs <= '0';
                end if;
                if r_h_count = h_start then
                    r_h_active <= '1';
                elsif r_h_count = h_end then
                    r_h_active <= '0';
                end if;
            end if;

            -- Verticale
            if reset = '1' then
                r_v_count  <= 0;
                o_hdmi_vs  <= '1';
                r_v_active <= '0';
            else
                if r_h_count = h_total then
                    if r_v_count = v_total then
                        r_v_count <= 0;
                    else
                        r_v_count <= r_v_count + 1;
                    end if;
                end if;
                if (r_v_count >= v_sync) and (r_v_count /= v_total) then
                    o_hdmi_vs <= '1';
                else
                    o_hdmi_vs <= '0';
                end if;
                if r_v_count = v_start then
                    r_v_active <= '1';
                elsif r_v_count = v_end then
                    r_v_active <= '0';
                end if;
            end if;

            -- Coordonnees, Pixel Enable et Adresse du Pixel
            if reset = '1' then
                o_pixel_en     <= '0';
                o_hdmi_de      <= '0';
                o_x_counter    <= 0;
                o_y_counter    <= 0;
                o_pixel_adress <= 0;
            else
                if (r_h_active = '1' and r_v_active = '1') then
                    o_pixel_en     <= '1';
                    o_hdmi_de      <= '1';
                    o_x_counter    <= r_h_count - h_start;
                    o_y_counter    <= r_v_count - v_start;
                    o_pixel_adress <= ((r_v_count - v_start) * h_res) + (r_h_count - h_start);
                else
                    o_pixel_en     <= '0';
                    o_hdmi_de      <= '0';
                    o_x_counter    <= 0;
                    o_y_counter    <= 0;
                    o_pixel_adress <= 0;
                end if;
            end if;

        end if;
    end process;
end architecture Behavioral;