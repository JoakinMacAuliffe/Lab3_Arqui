library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Detector de flanco con sincronizador y antirrebote.
--   1) Sincronizador de 2 etapas (evita metaestabilidad del boton asincrono).
--   2) Antirrebote: la salida estable solo cambia si la entrada se mantiene
--      distinta durante DEBOUNCE_CICLOS ciclos consecutivos.
--   3) Detector de flanco de subida: genera un pulso de 1 ciclo por pulsacion.
entity detector_flanco is
    Generic (
        -- 1_000_000 ciclos @ 100 MHz = 10 ms
        DEBOUNCE_CICLOS : positive := 1_000_000
    );
    Port (
        CLK : in STD_LOGIC;
        BOTON : in STD_LOGIC;
        PULSO : out STD_LOGIC
    );
end detector_flanco;

architecture Behavioral of detector_flanco is
    signal sync0, sync1   : std_logic := '0';
    signal estable        : std_logic := '0';
    signal estable_ant    : std_logic := '0';
    signal contador       : integer range 0 to DEBOUNCE_CICLOS - 1 := 0;
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Sincronizador
            sync0 <= BOTON;
            sync1 <= sync0;

            -- Antirrebote
            if sync1 = estable then
                contador <= 0;
            elsif contador = DEBOUNCE_CICLOS - 1 then
                estable  <= sync1;
                contador <= 0;
            else
                contador <= contador + 1;
            end if;

            -- Registro para detectar flanco
            estable_ant <= estable;
        end if;
    end process;

    PULSO <= estable and not estable_ant;
end Behavioral;

