library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Master_Slave_Top is
    Port (
        clk         : in  std_logic;
        command_in  : in  std_logic_vector(7 downto 0);
        address_in  : in  std_logic_vector(7 downto 0);
        data_in     : in  std_logic_vector(7 downto 0);
        read_data   : out std_logic_vector(7 downto 0)
    );
end SPI_Master_Slave_Top;

architecture Behavioral of SPI_Master_Slave_Top is
    signal sclk_sig, mosi_sig, miso_sig, ss_sig : std_logic;
    signal write_command_reg,read_command_reg, address_reg, data_reg   : std_logic_vector(7 downto 0);
begin

    Master_inst : entity work.SPI_Master
        port map (
            clk        => clk,
            command_in => command_in,
            address_in => address_in,
            data_in    => data_in,
            miso       => miso_sig,
            mosi       => mosi_sig,
            sclk       => sclk_sig,
            ss         => ss_sig,
            response   => read_data
        );

    Slave_inst : entity work.SPI_Slave
        port map (
            clk         => sclk_sig,
            ss          => ss_sig,
            mosi        => mosi_sig,
            miso        => miso_sig,
            write_command_reg => write_command_reg,
            read_command_reg => read_command_reg,
            address_reg => address_reg,
            data_reg    => data_reg
        );

end Behavioral;
