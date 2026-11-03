library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab03_top is
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
begin
    X_OUT <= X;

    Inst_detector: entity work.detector_flanco
        port map(
            CLK => CLK,
            BOTON => ENTER,
            PULSO => pulso_enter
        );

    Inst_fsm: entity work.fsm_acceso
        port map(
            CLK => CLK,
            RESET => RESET,
            X => X,
            ENTER => pulso_enter,
            ACCESO_OK => ACCESO_OK,
            ERROR => ERROR,
            BLOQUEADO => BLOQUEADO,
            INTENTOS => INTENTOS,
            ESTADO_LED => ESTADO_LED
        );
end Behavioral;
