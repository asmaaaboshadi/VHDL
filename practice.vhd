library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity practice is
  port(
    din, clk: in std_logic;
    data_valid: out std_logic;
	 err:buffer std_logic;
    data: out std_logic_vector(6 downto 0)
  );
end practice;

architecture behavior of practice is
  type stateType is (idle, receive_data,parity_check ,receive_stop);
  signal state: stateType := idle;
  signal q: std_logic_vector(9 downto 0);
  signal parity: std_logic;

  begin
    process (clk)
    variable bit_count: integer := 0;
    begin
      if rising_edge(clk) then
        case state is
          when idle =>
            if din = '1' then
				  data_valid <= '0';
              err <= '0';
				  parity <= '0';
				  q <= din & q(9 downto 1);
				  state <= receive_data;
            end if;
          when receive_data =>
			   parity <= parity xor din;
            q <= din & q(9 downto 1);
            bit_count := bit_count + 1;
            if bit_count = 7 then
              state <= parity_check;
            end if;
			 when parity_check =>
            if parity /= din then
                err <= '1';
            end if;
				q <= din & q(9 downto 1);
				state <= receive_stop;
          when receive_stop =>
            if (err = '0') and (din = '1') then
                data <= q(8 downto 2);
                data_valid <= '1';
                err <= '0';
            else
				    data_valid <= '0';
                err <= '1';
            end if;
				q <= din & q(9 downto 1);
            state <= idle;
				bit_count := 0;
        end case;
      end if;
    end process;
	 
  end behavior;