library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_Master is
    Port (
        clk        : in  std_logic;
        command_in : in  std_logic_vector(7 downto 0);
        address_in : in  std_logic_vector(7 downto 0);
        data_in    : in  std_logic_vector(7 downto 0);
        miso       : in  std_logic;
        mosi       : out std_logic;
        sclk       : out std_logic;
        ss         : out std_logic;
        response   : out std_logic_vector(7 downto 0)
    );
end SPI_Master;

architecture Behavioral of SPI_Master is
    type state_type is (IDLE, SEND_CMD, SEND_ADDR, SEND_DATA, READ_CMD, READ_ADDR, READ_DATA, DONE);
    signal state       : state_type := IDLE;
    signal clk_div     : std_logic := '0';
    signal sclk_int    : std_logic := '0';
    signal ss_int      : std_logic := '1';
    signal mosi_buf    : std_logic := '0';
    signal shift_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal recv_reg    : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_count   : integer range 0 to 7 := 0;
    signal cycle_count : integer := 0;
begin

    sclk <= sclk_int;
    mosi <= mosi_buf;
    ss   <= ss_int;

    process(clk)
    begin
        if rising_edge(clk) then
            clk_div <= not clk_div;
            if clk_div = '1' then

                case state is
                    when IDLE =>
                        ss_int <= '0';
                        shift_reg <= command_in;
                        state <= SEND_CMD;
                        bit_count <= 0;

                    when SEND_CMD | SEND_ADDR | SEND_DATA | READ_CMD | READ_ADDR =>
                        sclk_int <= not sclk_int;

                        if sclk_int = '0' then  -- output data on falling edge
                            mosi_buf <= shift_reg(7);
                            shift_reg <= shift_reg(6 downto 0) & '0';
                        else -- rising edge, count bits
                            bit_count <= bit_count + 1;
                            if bit_count = 7 then
                                bit_count <= 0;
                                case state is
                                    when SEND_CMD =>
                                        shift_reg <= address_in;
                                        state <= SEND_ADDR;
                                    when SEND_ADDR =>
                                        shift_reg <= data_in;
                                        state <= SEND_DATA;
                                    when SEND_DATA =>
                                        shift_reg <= x"03";
                                        state <= READ_CMD;
                                    when READ_CMD =>
                                        shift_reg <= address_in;
                                        state <= READ_ADDR;
                                    when READ_ADDR =>
                                        shift_reg <= (others => '0');
                                        state <= READ_DATA;
                                    when others => null;
                                end case;
                            end if;
                        end if;

                    when READ_DATA =>
                        sclk_int <= not sclk_int;
                        if sclk_int = '1' then  -- sample on rising edge
                            recv_reg <= recv_reg(6 downto 0) & miso;
                            bit_count <= bit_count + 1;
                            if bit_count = 7 then
                                response <= recv_reg(6 downto 0) & miso;
                                ss_int <= '1';
                                state <= DONE;
                            end if;
                        end if;

                    when DONE =>
                        -- Hold state
                        sclk_int <= '0';
                        mosi_buf <= '0';

                    when others => null;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
