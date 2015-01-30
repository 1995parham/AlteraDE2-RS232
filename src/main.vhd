library ieee;
use ieee.std_logic_1164.all;

entity serial is port (
	rxd : in std_logic := '1';
	txd : out std_logic := '1';
	led : out std_logic;
	clk : in std_logic
);
end entity;

architecture main_arch of serial is

component sender is port (
	clk_sender : in std_logic;
	TxD_start : in std_logic;
	TxD_data : in std_logic_vector(7 downto 0);
	TxD : out std_logic;
	TxD_busy : out std_logic
);
end component;

type state is (recv, send1, send2, send3, send4, s1, s2, s3, s4, s5, s6);

signal present_state : state := s3;
signal player_color : std_logic_vector(15 downto 0);

signal input : std_logic_vector (7 downto 0);

signal tick : std_logic := '0';

begin
	-- set senders port
	txd <= TxD;
	clk_sender <= clk;

	process(clk) begin
		if (clk'event and clk = '1') then
			case present_state is
				when s1 =>
					if (rxd = '0') then
						present_state <= recv;
					end if;
				when recv =>
					if (count < 8) then
						input(count) <= rxd;
						count <= count + 1;
					else
						count <= 0;
						present_state <= s2;
					end if;
				when s2 =>
					if (input(7 downto 0) = "00001010") then
						present_state <= s3;
					else
						player_color(7 downto 0) <= input(7 downto 0);
						player_color(15 downto 8) <= player_color(7 downto 0);
						present_state <= s2;
					end if;
				when s3 =>
					-- start send @
					TxD_data <= "01000000";
					TxD_start <= '1';
					present_state <= send1;
				when send1 =>
					if (TxD_busy = '0') then
						present_state <= s4;
					else
						TxD_start <= '0';
					end if;
				when s4 =>
					-- start send 0
					TxD_data <= "00110000";
					TxD_start <= '1';
					present_state <= send2;
				when send2 =>
					if (TxD_busy = '0') then
						present_state <= s5;
					else
						TxD_start <= '0';
					end if;
				when s5 =>
					-- start send /
					TxD_data <= "00101111";
					TxD_start <= '1';
					present_state <= send3;
				when send3 =>
					if (TxD_busy = '0') then
						present_state <= s6;
					else
						TxD_start <= '0';
					end if;
				when s6 =>
					-- start send \n
					TxD_data <= "00001010";
					TxD_start <= '1';
					present_state <= send4;
				when send4 =>
					if (TxD_busy = '0') then
						present_state <= s3;
					else
						TxD_start <= '0';
					end if;
			end case;
		end if;
	end process;
end main_arch;
