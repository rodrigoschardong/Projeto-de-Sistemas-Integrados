----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2021 08:36:08 PM
-- Design Name: 
-- Module Name: teste - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity teste is
--  Port ( );
end teste;

architecture rtl of teste is

component TOPO 
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           echo : in STD_LOGIC;
           trigger: out STD_LOGIC;
           pwm1 : out STD_LOGIC;
           pwm2 : out STD_LOGIC);
end component;

signal clk : STD_LOGIC := '0';
signal rst_n : STD_LOGIC := '0';
signal echo: STD_LOGIC := '0';
signal trigger: STD_LOGIC;
signal pwm1 : STD_LOGIC;
signal pwm2 : STD_LOGIC;

begin

dut: TOPO port map ( 
           clk  => clk,
           rst_n => rst_n,
           trigger => trigger,
           echo => echo,
           pwm1 => pwm1,
           pwm2 => pwm2
);

clk <= not clk after 5 ns;

--Simulação do echo
echo_simulation : process
begin
    echo <= '0';
    --Aguarda o trigger - 1
    wait until trigger = '1'; 
    wait for 100us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 2
    wait until trigger = '1';
    wait for 500us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 3 
    wait until trigger = '1';
    wait for 1ms; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 4
    wait until trigger = '1';
    wait for 1500us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 5
    wait until trigger = '1';
    wait for 1ms; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 6
    wait until trigger = '1';
    wait for 1ms; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 7
    wait until trigger = '1';
    wait for 1200us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 8
    wait until trigger = '1';
    wait for 1100us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 9
    wait until trigger = '1';
    wait for 1200us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 10
    wait until trigger = '1';
    wait for 1150us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 11
    wait until trigger = '1';
    wait for 700us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 12
    wait until trigger = '1';
    wait for 600us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 13
    wait until trigger = '1';
    wait for 500us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 14
    wait until trigger = '1';
    wait for 650us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 15
    wait until trigger = '1';
    wait for 800us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 16
    wait until trigger = '1';
    wait for 1000us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 17
    wait until trigger = '1';
    wait for 250us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
    echo <= '0';
    --Aguarda o trigger - 18
    wait until trigger = '1';
    wait for 500us; -- tempo do echo
    echo <= '1';
    wait for 25ns;
end process;

process 
begin
    wait for 20ns;
    rst_n <= '1';
    wait;
end process;

end rtl;
