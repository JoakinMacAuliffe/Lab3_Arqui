library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab03_top is
    Generic (
        -- 1_000_000 ciclos @ 100 MHz = 10 ms de antirrebote
        DEBOUNCE_CICLOS : positive := 1_000_000
    );
    Port (
        CLK       : in STD_LOGIC;
        RESET     : in STD_LOGIC;
        X         : in STD_LOGIC;
        ENTER     : in STD_LOGIC;
        X_OUT     : out STD_LOGIC;
        ACCESO_OK : out STD_LOGIC;
        ERROR     : out STD_LOGIC;
        BLOQUEADO : out STD_LOGIC;
        INTENTOS  : out STD_LOGIC_VECTOR(1 downto 0);
        ESTADO_LED: out STD_LOGIC_VECTOR(3 downto 0)
    );
end lab03_top;

architecture Behavioral of lab03_top is
    signal pulso_enter : STD_LOGIC;
    signal x_s0, x_s1  : STD_LOGIC := '0';
begin
    X_OUT <= X;

    -- Sincronizador de 2 etapas para el switch X
    process(CLK)
    begin
        if rising_edge(CLK) then
            x_s0 <= X;
            x_s1 <= x_s0;
        end if;
    end process;

    Inst_detector: entity work.detector_flanco
        generic map(
            DEBOUNCE_CICLOS => DEBOUNCE_CICLOS
        )
        port map(
            CLK => CLK,
            BOTON => ENTER,
            PULSO => pulso_enter
        );

    Inst_fsm: entity work.fsm_acceso
        port map(
            CLK => CLK,
            RESET => RESET,
            X => x_s1,
            ENTER => pulso_enter,
            ACCESO_OK => ACCESO_OK,
            ERROR => ERROR,
            BLOQUEADO => BLOQUEADO,
            INTENTOS => INTENTOS,
            ESTADO_LED => ESTADO_LED
        );
end Behavioral;
