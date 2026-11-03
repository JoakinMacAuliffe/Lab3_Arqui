library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detector_flanco is
    Port (
        CLK : in STD_LOGIC;
        BOTON : in STD_LOGIC;
        PULSO : out STD_LOGIC
    );
end detector_flanco;

architecture Behavioral of detector_flanco is
    signal q0, q1 : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            q0 <= BOTON;
            q1 <= q0;
        end if;
    end process;
   
    PULSO <= q0 and not q1;
end Behavioral;

