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
    
    -- sinais de teste
    signal d_alto: std_logic_vector (11 downto 0) := "000000000000";
    signal i_alto: std_logic_vector (10 downto 0) := "00000000000";
    signal pid_alto: std_logic_vector (3 downto 0) := "0000";
    
 
    
    
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
    
    signal i: std_logic_vector (27 downto 0) := "0000000000000000000000000000";
    signal i0: std_logic_vector (27 downto 0) := "0000000000000000000000000000";
    signal i_neg_flag: std_logic := '0';
    
    signal last_distance: std_logic_vector (23 downto 0) := "000000000000000000000000";
    signal d_neg_flag: std_logic := '0';
    signal d: std_logic_vector (25 downto 0) := "00000000000000000000000000";
    
    
    signal pid: std_logic_vector (15 downto 0) := x"0000";
    signal pid_neg_flag: std_logic := '0';
  
begin

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
        i0 <= i;
        last_distance <= distance;
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
variable pid_aux_shift : std_logic_vector(19 downto 0);
variable pid_aux : std_logic_vector(15 downto 0);
variable i_aux : std_logic_vector(15 downto 0);
variable d_aux : std_logic_vector(11 downto 0);

begin
    i_aux := i(15 downto 0);
    d_aux := d(25 downto 14);
    -- Ajeitar as constanstes e os valores dos controladores para signed
    if(clk'event and clk='1') then
        if(erro_neg_flag = '0' and d_neg_flag = '0' and  i_neg_flag = '0')then
            pid_neg_flag <= '0';
            pid_aux := p + d_aux + i_aux;
        elsif(erro_neg_flag = '1' and d_neg_flag = '0' and  i_neg_flag = '0')then
        pid_aux:= d_aux - p  + i_aux;
            if( p > (d_aux + i_aux))then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if;
         elsif(erro_neg_flag = '0' and d_neg_flag = '1' and  i_neg_flag = '0')then
         pid_aux := p - d_aux + i_aux;
            if( d_aux > (p + i_aux) )then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if;
          elsif(erro_neg_flag = '0' and d_neg_flag = '0' and  i_neg_flag = '1')then
          pid_aux:= p + d_aux - i_aux;
            if(i_aux > (p + d_aux))then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if;
          elsif(erro_neg_flag = '1' and d_neg_flag = '1' and  i_neg_flag = '0')then
          pid_aux:= i_aux -p - d_aux;
            if(i_aux < (p + d_aux))then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if; 
          elsif(erro_neg_flag = '1' and d_neg_flag = '0' and  i_neg_flag = '1')then
          pid_aux:= d_aux -i_aux -p ;
            if( d_aux < (p + i_aux))then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if;
          elsif(erro_neg_flag = '0' and d_neg_flag = '1' and  i_neg_flag = '1')then
          pid_aux:= p - d_aux - i_aux;
            if( p < (d_aux+ i_aux))then
                pid_neg_flag <= '1';
                pid_aux := not(pid_aux);
            else
                pid_neg_flag <= '0';
            end if;
          else
              pid_aux:= p + d_aux + i_aux;
              pid_neg_flag <= '1';
          end if;
   -- pid<= p + d(25 downto 14) + i(15 downto 0);
    pid_aux_shift := pid_aux(15 downto 0) * "1000";
    pid <= pid_aux_shift(15 downto 0);
    pid_alto <= pid(15 downto 12);
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
            p <= erro * kp;
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
Integrador: process(clk)
variable i_aux: std_logic_vector(43 downto 0);
begin
   if(clk'event and clk='1') then
        if(erro_neg_flag = '1' and i_neg_flag = '1') then -- caso o erro seja negativo e o i também
            i_neg_flag <= '1';
            i_aux := ((i0 + (erro * ki)) * freq);
        elsif(erro_neg_flag = '0' and i_neg_flag = '1') then -- caso o i seja negativo e o erro positivo
            if(i0 > (erro * ki)) then -- se o i for maior do que erro*ki o i será negativo
                i_neg_flag <= '1';
                i_aux := ((i0 - (erro * ki)) * freq);
            else
                i_neg_flag <= '0';
                i_aux := ((i0 - (erro * ki)) * freq);
               
            end if;
        elsif(erro_neg_flag = '1' and i_neg_flag = '0') then 
            if(i0 < (erro * ki)) then -- se o erro é negativo e erro*ki for maior que i, então i será negativo  
                i_neg_flag <= '1';
                i_aux := ((i0 - (erro * ki)) * freq);
            else
                i_neg_flag <= '0';
                i_aux := ((i0 - (erro * ki)) * freq);
            end if;
        else -- caso erro e i sejam positivos
            i_neg_flag <= '0';
            i_aux := ((i0 + (erro * ki)) * freq);
        end if;
       
        i <= i_aux(43 downto 16);
        i_alto <= i(27 downto 17);
    end if;
end process;
-------------------------------------------------------------------
--  Controlador Derivador
--      Entrada: freq
--      Saida: d
-------------------------------------------------------------------
Derivador: process(clk)
variable d_aux: std_logic_vector(42 downto 0);
begin
    if(clk'event and clk='1') then
        if(last_distance < distance) then
            d_aux := (distance - last_distance) * kd * freq; 
            d_neg_flag <= '0';
        else
            d_aux := (last_distance - distance) * kd * freq;
            d_neg_flag <= '1';
        end if;
    d<= d_aux(42 downto 17);
    d_alto <=  d(25 downto 14);
    end if;
end process;

-------------------------------------------------------------------
--  PWM
--      Entrada: pid, PID_neg_flag
--      Saida: i
-------------------------------------------------------------------
--PWM: process(clk)
--begin
   -- if(clk'event and clk='1') then
       -- if(pid_neg_flag = '1') then
             --motor 1
         --   pwm2 <= '1';
        --    if(pid > freq_counter) then
          --      pwm1 <= '0';
        --    else
      --          pwm1 <= '1';
    --        end if;
  --      else
     --        --motor 2
   --         pwm1 <= '1';
          --  if(pid < freq_counter) then
            --    pwm2 <= '0';
          --  else
        --        pwm2 <= '1';
      --      end if;
    --    end if;
  --  end if;
--end process;
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
            if(pid > freq_counter) then
                pwm2 <= '0';
            else
                pwm2 <= '1';
            end if;
        end if;
    end if;
end process;

end rtl;