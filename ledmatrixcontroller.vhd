--Written by Adam Reed
--Contact at areed@csus.edu
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY ledmatrixcontroller IS
PORT
(
  clk: in std_logic;
  clockout : out std_logic;
  dout : out std_logic;
  ce   : out std_logic;
  r1	 : in std_logic_vector(7 downto 0);
  r2 	 : in std_logic_vector(7 downto 0);
  r3   : in std_logic_vector(7 downto 0);
  r4 	 : in std_logic_vector(7 downto 0);
  r5	 : in std_logic_vector(7 downto 0);
  r6 	 : in std_logic_vector(7 downto 0);
  r7	 : in std_logic_vector(7 downto 0);
  r8	 : in std_logic_Vector(7 downto 0)
  
);
END ledmatrixcontroller;

ARCHITECTURE beh OF ledmatrixcontroller IS

--Signals
signal counter : std_logic_vector(31 downto 0);
signal clockbuffer : std_logic;
signal ld, sh, q, cebuffer: std_logic;
signal writeval : std_logic_vector(15 downto 0);
signal setupCounter : std_logic_vector(3 downto 0);
signal reset : std_logic;
signal fsmdone : std_logic;
signal matrixready : boolean;

--Set up/import FSM component
component fsm IS
PORT
(
  reset, clk : IN STD_LOGIC;
  ld : OUT STD_LOGIC;
  sh : OUT std_logic;
  ce : OUT std_logic;
  done : out std_logic);
end component;

--Set up/import 16 bit shift reg
component shiftreg16 is
Port(clk : in std_logic;
	  d	: in std_logic;
	  din   : in std_logic_vector(15 downto 0);
	  ld  : in std_logic;
	  sh  : in std_logic;
	  q	: out std_logic);
end component;

BEGIN
	
	
	--Process to set up registers and loop output
	process( fsmdone ) begin
	
		if( rising_edge(fsmdone) ) then
			
			if( not matrixready ) then
				setupCounter <= setupCounter + 1;
				
				case setupCounter is
					when "0000" => writeval <= "0000000000000000"; --Start up/do nothing
					when "0001" => writeval <= "0000110000000001"; --Set normal operation mode
					when "0010" => writeval <= "0000101100001111"; --Set Enable all scan bits
					when "0011" => writeval <= "0000101000001111"; --Set intensity to maximum
					when "0100" => writeval <= "0000000100000000"; --clear row 1
					when "0101" => writeval <= "0000001000000000"; --clear row 2
					when "0110" => writeval <= "0000001100000000"; --clear row 3
					when "0111" => writeval <= "0000010000000000"; --clear row 4
					when "1000" => writeval <= "0000010100000000"; --clear row 5
					when "1001" => writeval <= "0000011000010000"; --clear row 6
					when "1011" => writeval <= "0000011100000000"; --clear row 7
					when "1100" => writeval <= "0000100000000000"; --clear row 8
					when "1101" => matrixready <= true;
					when others => writeval <= "0000000000000000";
				end case;
				
			else
				
				setupCounter <= setupCounter + 1;
				--Loop and write to each of the registers for the leds
				case setupCounter is
					when "0000" => writeval <= "00000001" & r1;
					when "0001" => writeval <= "00000010" & r2;
					when "0010" => writeval <= "00000011" & r3;
					when "0011" => writeval <= "00000100" & r4;
					when "0100" => writeval <= "00000101" & r5;
					when "0101" => writeval <= "00000110" & r6;
					when "0110" => writeval <= "00000111" & r7;
					when "0111" => writeval <= "00001000" & r8;
					when others => writeval <= "0000000000000000";
										setupCounter <= "0000";
					
				end case;
				
			end if;
		end if;
	
	end process;
	--Output fsmdone to reset fsm.
	reset <= fsmdone;
	
	
	--Process that controls the output clock speed.
	Process(clk)
	begin
		
		if( rising_edge(clk) ) then
			
			counter <= counter + 1;
			if( counter = 5000 ) then
				
				clockbuffer <= not clockbuffer;
				counter <= "00000000000000000000000000000000";
			end if;
			
		end if;

	End process;
	
	
	
	
	--Ports for 16 bit shift register
	shft1 : shiftreg16 port
	map(
		clk => clockbuffer,
		d => '0',
		din => writeval,
		ld => ld,
		sh => sh,
		q => q);
	
	
	--Setup ports for State Machine
	fsm1 : fsm port
	map(
		reset => reset,
		clk => clockbuffer,
		ld => ld,
		sh => sh,
		ce => cebuffer,
		done => fsmdone);
		
	
	
	clockout <= clockbuffer;
	dout <= q;
	ce <= cebuffer;
END beh;
