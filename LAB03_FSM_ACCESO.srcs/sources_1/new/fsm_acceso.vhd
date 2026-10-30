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
    -- Se agregan los estados E1, E2, E3 y E4 para la ruta de error retardada
    type tipo_estado is (INICIO, S1, S2, S3, S4, E1, E2, E3, E4, ACCESO, ERROR_CLAVE, BLOQUEO);
    signal estado_actual, estado_siguiente : tipo_estado;
    signal cont_intentos : unsigned(1 downto 0) := "00";
begin


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
                    -- Se cuenta un intento fallido al evaluar el 5.o digito con error
                    if (estado_actual = S4 or estado_actual = E4) and estado_siguiente /= ACCESO then
                        if cont_intentos < 3 then
                            cont_intentos <= cont_intentos + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;


    process (estado_actual, X, cont_intentos)
    begin
        estado_siguiente <= estado_actual;
        case estado_actual is
            -- Ruta de secuencia correcta
            when INICIO =>
                if X = '1' then estado_siguiente <= S1; else estado_siguiente <= E1; end if;
            when S1 =>
                if X = '0' then estado_siguiente <= S2; else estado_siguiente <= E2; end if;
            when S2 =>
                if X = '1' then estado_siguiente <= S3; else estado_siguiente <= E3; end if;
            when S3 =>
                if X = '1' then estado_siguiente <= S4; else estado_siguiente <= E4; end if;
            when S4 =>
                if X = '0' then
                    estado_siguiente <= ACCESO;
                elsif cont_intentos >= 2 then
                    estado_siguiente <= BLOQUEO;      -- 3er intento fallido
                else
                    estado_siguiente <= ERROR_CLAVE;
                end if;
            
            -- Ruta de error (consume los bits restantes sin importar su valor)
            when E1 => estado_siguiente <= E2;
            when E2 => estado_siguiente <= E3;
            when E3 => estado_siguiente <= E4;
            when E4 =>
                if cont_intentos >= 2 then
                    estado_siguiente <= BLOQUEO;      -- 3er intento fallido
                else
                    estado_siguiente <= ERROR_CLAVE;
                end if;
            
            -- Estados finales
            when ERROR_CLAVE =>
                if cont_intentos >= 3 then
                    estado_siguiente <= BLOQUEO;
                else
                    estado_siguiente <= INICIO;
                end if;
            when ACCESO =>
                estado_siguiente <= ACCESO;
            when BLOQUEO =>
                estado_siguiente <= BLOQUEO;
            when others =>
                estado_siguiente <= INICIO;
        end case;
    end process;


    process (estado_actual, cont_intentos)
    begin
        ACCESO_OK <= '0';
        ERROR <= '0';
        BLOQUEADO <= '0';
        ESTADO_LED <= "0000";


        case estado_actual is
            when INICIO => ESTADO_LED <= "0000";
            -- Los estados de error (E) muestran el mismo LED que los estados correctos (S)
            when S1 | E1 => ESTADO_LED <= "0001";
            when S2 | E2 => ESTADO_LED <= "0010";
            when S3 | E3 => ESTADO_LED <= "0011";
            when S4 | E4 => ESTADO_LED <= "0100";
            when ACCESO => 
                ACCESO_OK <= '1';
                ESTADO_LED <= "0101";
            when ERROR_CLAVE => 
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