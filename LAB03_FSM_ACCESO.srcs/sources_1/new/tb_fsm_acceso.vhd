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
    -- En simulacion se usa un antirrebote corto (4 ciclos) para no simular 10 ms
    uut: entity work.lab03_top
        generic map ( DEBOUNCE_CICLOS => 4 )
        PORT MAP (
          CLK => CLK, RESET => RESET, X => X, ENTER => ENTER,
          X_OUT => X_OUT, ACCESO_OK => ACCESO_OK, ERROR => ERROR,
          BLOQUEADO => BLOQUEADO, INTENTOS => INTENTOS, ESTADO_LED => ESTADO_LED
        );


    CLK <= not CLK after 5 ns;


    stim_proc: process
        -- Pulsacion limpia (mas larga que el antirrebote + sincronizador)
        procedure pulso_btn is
        begin
            ENTER <= '1'; wait for 100 ns;
            ENTER <= '0'; wait for 100 ns;
        end procedure;

        -- Pulsacion con rebotes al presionar y al soltar (debe contar como UNA)
        procedure pulso_rebote is
        begin
            ENTER <= '1'; wait for 10 ns;
            ENTER <= '0'; wait for 10 ns;
            ENTER <= '1'; wait for 20 ns;
            ENTER <= '0'; wait for 10 ns;
            ENTER <= '1'; wait for 150 ns;
            ENTER <= '0'; wait for 10 ns;
            ENTER <= '1'; wait for 10 ns;
            ENTER <= '0'; wait for 150 ns;
        end procedure;
    begin
        RESET <= '1'; wait for 20 ns;
        RESET <= '0'; wait for 20 ns;
        
        -- CASO 1: Secuencia Correcta 10110 (con rebotes en el boton)
        X<='1'; pulso_rebote; X<='0'; pulso_rebote; X<='1'; pulso_rebote; X<='1'; pulso_rebote; X<='0'; pulso_rebote;
        wait for 10 ns;
        assert (ACCESO_OK = '1') report "Fallo Caso 1: Acceso no autorizado (revisar antirrebote)" severity FAILURE;
        
        -- CASO 2: Error en el 1er digito, Intento 1 (00000)
        -- Debe esperar los 5 digitos antes de marcar ERROR
        RESET <= '1'; wait for 20 ns; RESET <= '0'; wait for 20 ns;
        X<='0'; pulso_btn;
        assert (ERROR = '0' and ESTADO_LED = "0001") report "Fallo Caso 2: error antes del digito 5 (d1)" severity FAILURE;
        X<='0'; pulso_btn;
        assert (ERROR = '0' and ESTADO_LED = "0010") report "Fallo Caso 2: error antes del digito 5 (d2)" severity FAILURE;
        X<='0'; pulso_btn;
        assert (ERROR = '0' and ESTADO_LED = "0011") report "Fallo Caso 2: error antes del digito 5 (d3)" severity FAILURE;
        X<='0'; pulso_btn;
        assert (ERROR = '0' and ESTADO_LED = "0100") report "Fallo Caso 2: error antes del digito 5 (d4)" severity FAILURE;
        X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ERROR = '1') report "Fallo Caso 2: no marco ERROR tras 5 digitos" severity FAILURE;
        assert (INTENTOS = "01") report "Fallo Caso 2: Intento 1 no registrado" severity FAILURE;
        
        -- Pulso extra para salir del estado ERROR_CLAVE y volver a INICIO sin borrar el contador
        pulso_btn;
        
        -- CASO 3: Error en el 2do digito, Intento 2 (11111)
        X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn;
        assert (ERROR = '0') report "Fallo Caso 3: error antes del digito 5" severity FAILURE;
        X<='1'; pulso_btn;
        wait for 10 ns;
        assert (ERROR = '1' and INTENTOS = "10") report "Fallo Caso 3: Intento 2 no registrado" severity FAILURE;


        -- Pulso extra para salir del estado ERROR_CLAVE y volver a INICIO sin borrar el contador
        pulso_btn;


        -- CASO 4: Error en el 5to digito, Intento 3 y BLOQUEO (10111)
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn;
        wait for 10 ns;
        assert (BLOQUEADO = '1' and INTENTOS = "11") report "Fallo Caso 4: Bloqueo no activado" severity FAILURE;


        -- CASO 5: Despues del bloqueo (10110) - NO debe autorizar
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ACCESO_OK = '0' and BLOQUEADO = '1') report "Fallo Caso 5: Se autorizo estando bloqueado" severity FAILURE;


        -- CASO 6: RESET y clave correcta (10110)
        RESET <= '1'; wait for 20 ns; RESET <= '0'; wait for 20 ns;
        X<='1'; pulso_btn; X<='0'; pulso_btn; X<='1'; pulso_btn; X<='1'; pulso_btn; X<='0'; pulso_btn;
        wait for 10 ns;
        assert (ACCESO_OK = '1') report "Fallo Caso 6: No autorizo tras el reset" severity FAILURE;


        report "Todos los casos pasaron correctamente" severity NOTE;
        wait;
    end process;
end behavior;
