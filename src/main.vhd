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

component async_transmitter is port (
	clk : in std_logic;
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

-- sender ports
signal snd_data : std_logic_vector (7 downto 0);
signal snd_start : std_logic;
signal snd_busy : std_logic;

begin
	-- set senders port
	snd: async_transmitter port map (clk, snd_start, snd_data, txd, snd_busy);

	process(clk) begin
		if (clk'event and clk = '1') then
			case present_state is
				when s1 =>
					if (rxd = '0') then
						present_state <= recv;
					end if;
				when recv =>
					-- nothing
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
					snd_data <= "01000000";
					snd_start <= '1';
					present_state <= send1;
				when send1 =>
					if (snd_busy = '0') then
						present_state <= s4;
						snd_start <= '0';
					end if;
				when s4 =>
					-- start send 0
					snd_data <= "00110000";
					snd_start <= '1';
					present_state <= send2;
				when send2 =>
					if (snd_busy = '0') then
						present_state <= s5;
						snd_start <= '0';
					end if;
				when s5 =>
					-- start send /
					snd_data <= "00101111";
					snd_start <= '1';
					present_state <= send3;
				when send3 =>
					if (snd_busy = '0') then
						present_state <= s6;
						snd_start <= '0';
					end if;
				when s6 =>
					-- start send \n
					snd_data <= "00001010";
					snd_start <= '1';
					present_state <= send4;
				when send4 =>
					if (snd_busy = '0') then
						present_state <= s3;
						snd_start <= '0';
					end if;
			end case;
		end if;
	end process;
end main_arch;
