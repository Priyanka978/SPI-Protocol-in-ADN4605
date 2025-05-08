library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_Slave is
    Port (
        clk                  : in  std_logic;
        ss                   : in  std_logic;
        mosi                 : in  std_logic;
        miso                 : out std_logic;
        write_command_reg    : out std_logic_vector(7 downto 0);
        read_command_reg     : out std_logic_vector(7 downto 0);
        address_reg          : out std_logic_vector(7 downto 0);
        data_reg             : out std_logic_vector(7 downto 0)
    );
end SPI_Slave;

architecture Behavioral of SPI_Slave is
    signal bit_count   : integer range 0 to 7 := 0;
    signal byte_count  : integer range 0 to 3 := 0;
    signal shift_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal shift_out   : std_logic_vector(7 downto 0) := (others => '0');
    signal write_cmd_buf  : std_logic_vector(7 downto 0) := (others => '0');
    signal read_cmd_buf   : std_logic_vector(7 downto 0) := (others => '0');
    signal addr_buf    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_buf    : std_logic_vector(7 downto 0) := (others => '0');
    signal sending     : boolean := false;
    signal miso_int    : std_logic := 'Z';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if ss = '0' then
                -- Shift in bit from MOSI
                shift_in <= shift_in(6 downto 0) & mosi;
                bit_count <= bit_count + 1;

                -- Shift out bit to MISO if sending
                if sending = true then
                    miso_int <= shift_out(7);
                    shift_out <= shift_out(6 downto 0) & '0';
                else
                    miso_int <= 'Z';  -- High impedance if not sending
                end if;

                -- Handle full byte (8 bits)
                if bit_count = 7 then
                    case byte_count is
                        when 0 =>
                            write_cmd_buf <= shift_in(6 downto 0) & mosi;
                        when 1 =>
                            addr_buf <= shift_in(6 downto 0) & mosi;
                        when 2 =>
                            if write_cmd_buf = x"02" then
                                data_buf <= shift_in(6 downto 0) & mosi;
                            end if;
                        when 3 =>
                            read_cmd_buf <= shift_in(6 downto 0) & mosi;
                            if shift_in(6 downto 0) & mosi = x"03" then
                                sending <= true;
                                shift_out <= data_buf;
                            end if;
                        when others =>
                            null;
                    end case;

                    byte_count <= byte_count + 1;
                    bit_count <= 0;
                end if;

            else
                -- Reset logic when SS is inactive
                bit_count   <= 0;
                byte_count  <= 0;
                sending     <= false;
                miso_int    <= 'Z';
            end if;
        end if;
    end process;

    -- Outputs
    write_command_reg <= write_cmd_buf;
    read_command_reg  <= read_cmd_buf;
    address_reg       <= addr_buf;
    data_reg          <= data_buf;
    miso              <= miso_int;

end Behavioral;
