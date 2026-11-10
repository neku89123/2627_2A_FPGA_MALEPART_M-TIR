library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library pll;
use pll.all;

entity telecran is
    port (
        
        i_clk_50: in std_logic;

        
        io_hdmi_i2c_scl       : inout std_logic;
        io_hdmi_i2c_sda       : inout std_logic;
        o_hdmi_tx_clk        : out std_logic;
        o_hdmi_tx_d          : out std_logic_vector(23 downto 0);
        o_hdmi_tx_de         : out std_logic;
        o_hdmi_tx_hs         : out std_logic;
        i_hdmi_tx_int        : in std_logic;
        o_hdmi_tx_vs         : out std_logic;

        
        i_rst_n : in std_logic;
		
        
        o_leds : out std_logic_vector(9 downto 0);
        o_de10_leds : out std_logic_vector(7 downto 0);

       
        i_left_ch_a : in std_logic;
        i_left_ch_b : in std_logic;
        i_left_pb : in std_logic;
        i_right_ch_a : in std_logic;
        i_right_ch_b : in std_logic;
        i_right_pb : in std_logic;
		  rst : in std_logic
    );
end entity telecran;

architecture rtl of telecran is
    component I2C_HDMI_Config
        port (
            iCLK : in std_logic;
            iRST_N : in std_logic;
            I2C_SCLK : out std_logic;
            I2C_SDAT : inout std_logic;
            HDMI_TX_INT  : in std_logic
        );
    end component;

    component pll
        port (
            refclk : in std_logic;
            rst : in std_logic;
            outclk_0 : out std_logic;
            locked : out std_logic
        );
    end component;

    component hdmi_controler
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
    end component;

    component encoder
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
            o_leds   : out std_logic_vector(N-1 downto 0);
            o_x      : out natural;
            o_y      : out natural
        );
    end component;

	 component dpram
		  generic   (
        mem_size    : natural := 720 * 480;
        data_width  : natural := 8
    );
	  port 
   (   
        i_clk_a        : in std_logic;
        i_clk_b        : in std_logic;

        i_data_a    : in std_logic_vector(data_width-1 downto 0);
        i_data_b    : in std_logic_vector(data_width-1 downto 0);
        i_addr_a    : in natural range 0 to mem_size-1;
        i_addr_b    : in natural range 0 to mem_size-1;
        i_we_a      : in std_logic := '1';
        i_we_b      : in std_logic := '1';
        o_q_a       : out std_logic_vector(data_width-1 downto 0);
        o_q_b       : out std_logic_vector(data_width-1 downto 0)
   );
	end component;
	
	
    constant h_res : natural := 720;
    constant v_res : natural := 480;

    signal s_clk_27 : std_logic;
    signal s_rst_n  : std_logic;  

    signal s_x_counter : natural;
    signal s_y_counter : natural;

    signal s_enc_leds : std_logic_vector(7 downto 0);
    signal s_enc_x    : natural;
    signal s_enc_y    : natural;
	 
	 signal s_pixel_adress : natural range 0 to 720*480-1;
    signal s_addr_a       : natural range 0 to 720*480-1 := 0;
    signal s_we_a         : std_logic;
    signal s_q_b          : std_logic_vector(7 downto 0);
	 
	 signal s_clear   : std_logic := '1';  
    signal s_clear_addr : natural range 0 to 720*480-1 := 0;

    signal s_addr_mux : natural range 0 to 720*480-1;
    signal s_data_mux : std_logic_vector(7 downto 0);
    signal s_we_mux   : std_logic;
	 
begin
    o_leds      <= "00" & s_enc_leds;
    o_de10_leds <= s_enc_leds;
	 
    s_we_a   <= '1' when (s_enc_x < h_res and s_enc_y < v_res) else '0';
    s_addr_a <= s_enc_y * h_res + s_enc_x when (s_enc_x < h_res and s_enc_y < v_res) else 0;

	 
    pll0 : component pll
        port map (
            refclk => i_clk_50,
            rst => not(i_rst_n),
            outclk_0 => s_clk_27,
            locked => s_rst_n
        );

   
    I2C_HDMI_Config0 : component I2C_HDMI_Config
        port map (
            iCLK => i_clk_50,
            iRST_N => i_rst_n,
            I2C_SCLK => io_hdmi_i2c_scl,
            I2C_SDAT => io_hdmi_i2c_sda,
            HDMI_TX_INT => i_hdmi_tx_int
        );

   
    hdmi_controler0 : component hdmi_controler
        generic map (
            h_res  => h_res,
            v_res  => v_res
        )
        port map (
            clk            => s_clk_27,
            reset          => not(s_rst_n),  
            o_hdmi_hs      => o_hdmi_tx_hs,
            o_hdmi_vs      => o_hdmi_tx_vs,
            o_hdmi_de      => o_hdmi_tx_de,
            o_pixel_en     => open,
            o_x_counter    => s_x_counter,
            o_y_counter    => s_y_counter,
            o_pixel_adress => s_pixel_adress
        );

    encoder0 : component encoder
        generic map (
            N => 8
        )
        port map (
            clk     => i_clk_50,
            reset   => i_rst_n,        
            A_left  => i_left_ch_a,
            B_left  => i_left_ch_b,
            A_right => i_right_ch_a,
            B_right => i_right_ch_b,
            o_leds  => s_enc_leds,
            o_x     => s_enc_x,
            o_y     => s_enc_y
        );
		  
		      dpram0 : component dpram
        port map (
            i_clk_a  => i_clk_50,
            i_clk_b  => s_clk_27,
				i_data_a => s_data_mux,  
            i_data_b => x"00",
            i_addr_a => s_addr_mux,     
            i_addr_b => s_pixel_adress,
            i_we_a   => s_we_mux,       
            i_we_b   => '0',
            o_q_a    => open,
            o_q_b    => s_q_b
        );

    o_hdmi_tx_clk <= s_clk_27;

        o_hdmi_tx_d <= s_q_b & s_q_b & s_q_b;
		  
    process(i_clk_50)
    begin
        if rising_edge(i_clk_50) then
            if rst = '0' then             
                s_clear  <= '1';
                s_clear_addr <= 0;
            elsif s_clear = '1' then
                if s_clear_addr = h_res * v_res - 1 then
                    s_clear <= '0';         
                else
                    s_clear_addr <= s_clear_addr + 1;
                end if;
            end if;
        end if;
    end process;

    s_addr_mux <= s_clear_addr when s_clear = '1' else s_addr_a;
    s_data_mux <= x"00"        when s_clear = '1' else x"FF";
    s_we_mux   <= '1'          when s_clear = '1' else s_we_a;
end architecture rtl;