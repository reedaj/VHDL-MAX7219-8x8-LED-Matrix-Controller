--Written by Adam Reed
--Contact at areed@csus.edu
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY fsm IS
PORT
(
  reset, clk : IN STD_LOGIC;
  ld : OUT STD_LOGIC;
  sh : OUT std_logic;
  ce : OUT std_logic;
  done : OUT std_logic
  
);
END fsm;

ARCHITECTURE beh OF fsm IS
type state_type is (s0, s1, s2, s3, s4);
signal cs, ns: state_type;

signal counter : std_logic_vector(3 downto 0);

BEGIN

Process(reset, clk)
Begin
If (reset = '1') then
  cs <= S0;
  counter <= "0000";
elsif (rising_edge(clk)) then
  cs <= ns;
  counter<= counter + 1;
end if;
End process;

Process(cs)
Begin
  case (cs) is
  When s0 =>
	  ns <= s1;
     ld <= '1';
	  sh <= '0';
	  ce <= '1';
	  done <= '0';
	  
  
  When s1 =>
	  if( counter = 15 ) then
			ns <= s2;
	  else 
			ns <= s1;
	  end if;
	  ld <= '0';
	  sh <= '1';
	  ce <= '0';
	  done <= '0';
	  
  When s2 =>
	  ns <= s3;
	  ld <= '0';
	  sh <= '1';
	  ce <= '0';
	  done <= '0';
	  
  when s3 =>
	  ns <= s4;
	  ld <= '0';
	  sh <= '0';
	  ce <= '1';
	  done <= '0';
	  
  when s4 =>
	  ns <= s4;
	  ld <= '0';
	  sh <= '0';
	  ce <= '0';
	  done <= '1';
	  
  when others => 
	  ld <= '0';
	  sh <= '0';
	  ce <= '0';
	  ns <= s0;
  
  end case;

end process;
END beh;
