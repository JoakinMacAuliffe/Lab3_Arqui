library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_acceso is
    Port ( 
        CLK       : in STD_LOGIC;
        RESET     : in STD_LOGIC;
        X         : in STD_LOGIC;
        ENTER     : in STD_LOGIC;
        ACCESO_OK : out STD_LOGIC;
        ERROR     : out STD_LOGIC;
        BLOQUEADO : out STD_LOGIC;
        INTENTOS  : out STD_LOGIC_VECTOR(1 downto 0);
        ESTADO_LED: out STD_LOGIC_VECTOR(3 downto 0)
    );
end fsm_acceso;

architecture Behavioral of fsm_acceso is
    -- Estados con los NOMBRES EXACTOS de la pizarra del profesor
    type tipo_estado is (INICIO, OK1, OK2, OK3, OK4, ESTADO_OK, E1, E2, E3, E4, NOK, BLOQUEO);
    signal estado_actual, estado_siguiente : tipo_estado;
    signal cont_intentos : unsigned(1 downto 0) := "00";
begin

    -- Registro de estado y contador de intentos (Síncrono)
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                estado_actual <= INICIO;
                cont_intentos <= "00";
            elsif ENTER = '1' then
                if estado_actual = BLOQUEO then
                    estado_actual <= BLOQUEO;
                else
                    estado_actual <= estado_siguiente;
                    
                    -- INCREMENTO PERFECTO: Solo cuenta el intento fallido al llegar al 5to bit (NOK o BLOQUEO)
                    if (estado_siguiente = NOK or estado_siguiente = BLOQUEO) and 
                       (estado_actual = E4 or estado_actual = OK4) then
                        if cont_intentos < 3 then
                            cont_intentos <= cont_intentos + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Lógica de transición de estados basada fielmente en la pizarra
    process (estado_actual, X, cont_intentos)
    begin
        estado_siguiente <= estado_actual;
        case estado_actual is
            -- RUTA CORRECTA (Izquierda de la pizarra)
            when INICIO => if X = '1' then estado_siguiente <= OK1; else estado_siguiente <= E1; end if;
            when OK1    => if X = '0' then estado_siguiente <= OK2; else estado_siguiente <= E2; end if;
            when OK2    => if X = '1' then estado_siguiente <= OK3; else estado_siguiente <= E3; end if;
            when OK3    => if X = '1' then estado_siguiente <= OK4; else estado_siguiente <= E4; end if;
            when OK4    => 
                if X = '0' then 
                    estado_siguiente <= ESTADO_OK; 
                else 
                    if cont_intentos = 2 then estado_siguiente <= BLOQUEO; else estado_siguiente <= NOK; end if;
                end if;

            -- RUTA DE ERRORES ARRASTRADOS (Derecha de la pizarra)
            when E1 => estado_siguiente <= E2; -- Ignora X, arrastra el error
            when E2 => estado_siguiente <= E3;
            when E3 => estado_siguiente <= E4;
            when E4 => 
                if cont_intentos = 2 then estado_siguiente <= BLOQUEO; else estado_siguiente <= NOK; end if;

            -- ESTADOS FINALES (Esperan ENTER para volver a intentar)
            when ESTADO_OK => estado_siguiente <= ESTADO_OK;
            when NOK       => estado_siguiente <= INICIO; -- Al presionar ENTER después del error, vuelve al inicio
            when BLOQUEO   => estado_siguiente <= BLOQUEO;
            when others    => estado_siguiente <= INICIO;
        end case;
    end process;

    -- Lógica de LEDs: ¡Aquí está el truco para engañar al usuario!
    process (estado_actual, cont_intentos)
    begin
        ACCESO_OK <= '0';
        ERROR <= '0';
        BLOQUEADO <= '0';
        ESTADO_LED <= "0000";

        case estado_actual is
            when INICIO => ESTADO_LED <= "0000";
            
            -- Los estados E muestran EXACTAMENTE LOS MISMOS LEDS que los OK
            when OK1 | E1 => ESTADO_LED <= "0001";
            when OK2 | E2 => ESTADO_LED <= "0010";
            when OK3 | E3 => ESTADO_LED <= "0011";
            when OK4 | E4 => ESTADO_LED <= "0100";
            
            when ESTADO_OK => 
                ACCESO_OK <= '1';
                ESTADO_LED <= "0101";
                
            -- El error solo se revela al final (NOK)
            when NOK => 
                ERROR <= '1';
                ESTADO_LED <= "1110";
                
            when BLOQUEO => 
                BLOQUEADO <= '1';
                ESTADO_LED <= "1111";
            when others => null;
        end case;
        
        INTENTOS <= std_logic_vector(cont_intentos);
    end process;

end Behavioral;