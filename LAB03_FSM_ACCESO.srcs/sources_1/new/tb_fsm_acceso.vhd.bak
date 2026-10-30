library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_fsm_acceso is
end tb_fsm_acceso;


architecture behavior of tb_fsm_acceso is
    signal CLK : std_logic := '0';
    signal RESET : std_logic := '0';
    signal X : std_logic := '0';
    signal ENTER : std_logic := '0';
    
    signal X_OUT : std_logic;
    signal ACCESO_OK : std_logic;
    signal ERROR : std_logic;
    signal BLOQUEADO : std_logic;
    signal INTENTOS : std_logic_vector(1 downto 0);
    signal ESTADO_LED : std_logic_vector(3 downto 0);
begin
    uut: entity work.lab03_top PORT MAP (
          CLK => CLK, RESET => RESET, X => X, ENTER => ENTER,
          X_OUT => X_OUT, ACCESO_OK => ACCESO_OK, ERROR => ERROR,
          BLOQUEADO => BLOQUEADO, INTENTOS => INTENTOS, ESTADO_LED => ESTADO_LED
        );


    CLK <= not CLK after 5 ns;


    stim_proc: process
        procedure pulso_btn is
        begin
            ENTER <= '1'; wait for 20 ns;
            ENTER <= '0'; wait for 20 ns;
        end procedure;
    begin
        RESET <= '1'; wait for 20 ns;
        RESET <= '0'; wait for 20 ns;
        
        -- CASO 1: Secuencia Correcta 10110
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ACCESO_OK = '1') report "Fallo Caso 1: Acceso no autorizado" severity FAILURE;
        
        -- CASO 2: Error, Intento 1 (00000)
        RESET <= '1'; wait for 20 ns; RESET <= '0'; wait for 20 ns;
        X<='0'; pulso_btn; X<='0'; pulso_btn; X<='0'; pulso_btn; X<='0'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (INTENTOS = "01") report "Fallo Caso 2: Intento 1 no registrado" severity FAILURE;
        
        -- Pulso extra para salir del estado ERROR_CLAVE y volver a INICIO sin borrar el contador
        pulso_btn;
        
        -- CASO 3: Error, Intento 2 (11111)
        X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn;
        wait for 10 ns;
        assert (INTENTOS = "10") report "Fallo Caso 3: Intento 2 no registrado" severity FAILURE;


        -- Pulso extra para salir del estado ERROR_CLAVE y volver a INICIO sin borrar el contador
        pulso_btn;


        -- CASO 4: Error, Intento 3 y BLOQUEO (10111)
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn;
        wait for 10 ns;
        assert (BLOQUEADO = '1') report "Fallo Caso 4: Bloqueo no activado" severity FAILURE;


        -- CASO 5: Despues del bloqueo (10110) - NO debe autorizar
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ACCESO_OK = '0' and BLOQUEADO = '1') report "Fallo Caso 5: Se autorizó estando bloqueado" severity FAILURE;


        -- CASO 6: RESET y clave correcta (10110)
        RESET <= '1'; wait for 20 ns; RESET <= '0'; wait for 20 ns;
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ACCESO_OK = '1') report "Fallo Caso 6: No autorizó tras el reset" severity FAILURE;


        wait;
    end process;
end behavior;