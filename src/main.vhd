library ieee;
use ieee.std_logic_1164.all;

entity trax is port (
	rxd : in std_logic := '1';
	txd : out std_logic := '1';
	led : out std_logic;
	clk : in std_logic
	);
end entity;

architecture main_arch of trax is

component clk96 is port(
	clk : in std_logic;
	enable : in std_logic;
	tick : out std_logic
	);
end component;

type state is (recv, send1, send2, send3, send4, s1, s2, s3, s4, s5, s6);

signal present_state : state := s3;
signal count : integer := 0;
signal player_color : std_logic_vector(15 downto 0);
signal output_signal : std_logic_vector(31 downto 0);

signal input : std_logic_vector (7 downto 0);
signal output : std_logic_vector(9 downto 0);

signal tick : std_logic := '0';

begin
	-- li : clk96 port map (clk, '1', tick);
	process(clk) begin
		if (rising_edge(clk)) then
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
					led <= '1';
					output <= "0110111011";
					present_state <= send1;
				when send1 =>
					if (count < 10) then
						txd <= output(count);
						led <= output(count);
						count <= count + 1;
					else
						count <= 0;
						present_state <= s4;
					end if;
				when s4 =>
					led <= '1';
					output <= "0011111011";
					present_state <= send2;
				when send2 =>
					if (count < 10) then
						txd <= output(count);
						led <= output(count);
						count <= count + 1;
					else
						count <= 0;
						present_state <= s5;
					end if;
				when s5 =>
					led <= '0';
					output <= "0010101111";
					present_state <= send3;
				when send3 =>
					if (count < 10) then
						txd <= output(count);
						led <= output(count);
						count <= count + 1;
					else
						count <= 0;
						present_state <= s6;
					end if;
				when s6 =>
					led <= '0';
					output <= "0001101011";
					present_state <= send4;
				when send4 =>
					if (count < 10) then
						txd <= output(count);
						led <= output(count);
						count <= count + 1;
					else
						count <= 0;
						present_state <= s3;
					end if;
			end case;
		end if;
	end process;
end main_arch;
