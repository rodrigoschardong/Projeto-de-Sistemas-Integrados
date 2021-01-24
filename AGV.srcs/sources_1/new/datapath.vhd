----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Rodrigo
-- 
-- Create Date: 01/19/2021 06:48:18 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;
library work;


entity datapath is
    Port ( clk : in STD_LOGIC; -- vem da placa / simulação
           --onOff : in STD_LOGIC; -- vem da placa / sim
           echo: in STD_LOGIC;
           trigger: out STD_LOGIC;
           pwm1 : out STD_LOGIC; 
           pwm2 : out STD_LOGIC);
end datapath;

architecture rtl of datapath is
    -- Sinais do modulo Freq de Leitura
    signal enable : std_logic := '0';
    constant freq : std_logic_vector (15 downto 0):= "1110101001100000"; --60k ciclos de clock 
    signal freq_counter : std_logic_vector (15 downto 0):= "0000000000000000"; -- Conta até o sensor detectar 100cm
    
    -- Sinais do modulo Timer
    signal timer_counter : std_logic_vector (15 downto 0):= "0000000000000000";
    signal echo_flag: std_logic := '0';
    
    --Sinais do modulo Conversor_Tempo_Distancia
    signal distance: std_logic_vector (23 downto 0) := "000000000000000000000000";
    constant speed_of_sound: std_logic_vector (7 downto 0) := "10101000"; -- Velocidade do Som/ 2 (descontado o tempo do eco)
    
    --Sinais do modulo Error
    constant distance_base: std_logic_vector (6 downto 0) := "0010100";
    signal erro: std_logic_vector (6 downto 0) := "0000000";
    signal erro_neg_flag: std_logic := '0';
    
    -- Sinais do modulo Control 
    -- Ajeitar as constanstes e os valores dos controladores para signed
    constant kp: std_logic_vector (8 downto 0) := "011010011";
    constant ki: std_logic_vector (4 downto 0) := "11101";
    constant kd: std_logic_vector (2 downto 0) := "111";
    
    signal p: std_logic_vector (15 downto 0) := "0000000000000000";
    
    --signal i: std_logic_vector (3 downto 0) := "0000";
    --signal i_neg_flag: std_logic := '0';
    
    signal last_distance: std_logic_vector (6 downto 0) := "0000000";
    signal d_neg_flag: std_logic := '0';
    signal d: std_logic_vector (25 downto 0) := "00000000000000000000000000";
    
    
    signal pid: std_logic_vector (15 downto 0) := x"0000";
    signal pid_neg_flag: std_logic := '0';
    
    --Sinais do modulo Motores
    --signal motor_1: std_logic_vector (15 downto 0) := (others => '0');
    --signal motor_2: std_logic_vector (15 downto 0) := "0000000000000000";
    --signal pwm_motor_1: std_logic := '0';
    --signal pwm_motor_2: std_logic := '0';

    --signal clk : std_logic := '0';
    --signal echo : std_logic := '0';
  
begin

--clk <= not clk after 25ns;
--teste <= not teste after 20ms;


-------------------------------------------------------------------
--  Freq_de_Leitura
--      Entrada: clk
--      Saida: enable
-------------------------------------------------------------------
Freq_de_Leitura: process (clk) --, onOff)
begin
    if (clk'event and clk='1') then -- and onOff = '1') then
        if( freq = freq_counter) then
            freq_counter <= "0000000000000000";
        else
            freq_counter <= freq_counter + 1;
        end if;
        if(freq_counter = "0000000000000000") then
            enable <= '1';
        else
            enable <= '0';
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  Timer
--      Entrada: clk
--      Saída: timer_counter
-------------------------------------------------------------------
Timer: process(clk)
begin
    if (clk'event and clk='1') then
        if(enable = '1') then
            trigger <= '1';
            timer_counter <= "0000000000000000";
        elsif(echo_flag = '0') then
            trigger <= '0';
            timer_counter <= timer_counter + 1;
        else
            trigger <= '0';
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  EchoAnswer
--      Entrada: echo
--      Saida: echo_flag
-------------------------------------------------------------------
EchoAnswer: process(echo, enable)
begin
    if(echo'event and echo='1') then
        echo_flag <= '1';
        last_distance <= distance(23 downto 17);
    end if;
    if(enable = '1') then--if(clk'event and clk='1' and echo_flag = '1') then
        echo_flag <= '0';
    end if;
end process;

-------------------------------------------------------------------
--  Conversor_Tempo_Distancia
--      Entrada: clk
--      Saida: distance
-------------------------------------------------------------------
Conversor_Tempo_Distancia: process (clk)
--variable temp: std_logic_vector(15 downto 0);

begin
    if(clk'event and clk='1' and echo_flag = '1') then
        
        distance <= (timer_counter * speed_of_sound);
        --temp := (timer_counter * speed_of_sound);
        --distance <= temp /2;
    end if;
end process;

-------------------------------------------------------------------
--  Error
--      Entrada: distance
--      Saida: erro, erro_neg_flag
-------------------------------------------------------------------
Error: process(clk)
begin
    if(clk'event and clk='1' and echo_flag = '1') then
        --if(to_integer(unsigned(distance_base)) < to_integer(unsigned(distance)))then
        if(distance_base < distance(23 downto 17)) then
            --Distancia >
            erro_neg_flag <= '0';
            erro <= distance(23 downto 17) - distance_base;
        else
            -- Distancia <
            erro_neg_flag <= '1';
            erro(6 downto 0) <= distance_base - distance(23 downto 17);
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  Control
--      Entrada: clk
--      Saida: pid
-------------------------------------------------------------------
Control: process(clk)
begin
    -- Ajeitar as constanstes e os valores dos controladores para signed
    if(clk'event and clk='1') then
        if(erro_neg_flag = '0' and d_neg_flag = '0')then
            pid_neg_flag <= '0';
            pid <= p + d(25 downto 10);
        elsif(erro_neg_flag = '1' and d_neg_flag = '0')then
            if( p > d(25 downto 10))then
                pid <= not(p + d(25 downto 10));
                pid_neg_flag <= '1';
            else
                pid <= p + d(25 downto 10);
                pid_neg_flag <= '0';
            end if;
         elsif(erro_neg_flag = '0' and d_neg_flag = '1')then
            if( p < d(25 downto 10))then
                pid <= not(p + d(25 downto 10));
                pid_neg_flag <= '1';
            else
                pid <= p + d(25 downto 10);
                pid_neg_flag <= '0';
            end if;
          elsif(erro_neg_flag = '1' and d_neg_flag = '1')then
             pid <= not(p + d(25 downto 10));
                pid_neg_flag <= '1';
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  Controlador Proporcional
--      Entrada: erro
--      Saida: p
-------------------------------------------------------------------
Proporcional: process(clk)
begin
    if(clk'event and clk='1') then
        if(erro_neg_flag = '1') then
            p<= not(erro *kp);
        elsif(erro_neg_flag = '0') then
            p <= erro * kp;
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  Controlador Integrador
--      Entrada: erro, freq
--      Saida: i
-------------------------------------------------------------------
--Integrador: process(clk)
--begin
--    if(clk'event and clk='1') then
--        if(erro_neg_flag = '1' and i_neg_flag = '1') then
--            i <= not((i + (erro * ki)) * freq);
--        elsif(erro_neg_flag = '0' and i_neg_flag = '0') then
--            i <= (i + (erro * ki)) * freq;
--        elsif(erro_neg_flag = '0' and i_neg_flag = '1') then
--            if(i > (erro * ki)) then
--                i <= ((erro * ki) - i) * freq;
--            else
--                i_neg_flag <= '0';
                
--            end if;
--        else
--            i <= (i - (erro * ki)) * freq;
--        end if;
--    end if;
--end process;

-------------------------------------------------------------------
--  Controlador Derivador
--      Entrada: freq
--      Saida: d
-------------------------------------------------------------------
Derivador: process(clk)
begin
    if(clk'event and clk='1') then
        if(last_distance < distance(23 downto 17)) then
            d <= not((last_distance - distance(23 downto 17)) * kd * freq); 
            d_neg_flag <= '1';
        else
            d <= (last_distance - distance(23 downto 17)) * kd * freq;
            d_neg_flag <= '0';
        end if;
    end if;
end process;

-------------------------------------------------------------------
--  PWM
--      Entrada: pid, PID_neg_flag
--      Saida: i
-------------------------------------------------------------------
PWM: process(clk)
begin
    if(clk'event and clk='1') then
        if(pid_neg_flag = '1') then
             --motor 1
            pwm2 <= '1';
            if(pid > freq_counter) then
                pwm1 <= '0';
            else
                pwm1 <= '1';
            end if;
        else
             --motor 2
            pwm1 <= '1';
            if(pid < freq_counter) then
                pwm2 <= '0';
            else
                pwm2 <= '1';
            end if;
        end if;
    end if;
end process;

end rtl;
