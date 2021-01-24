----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2021 08:22:58 PM
-- Design Name: 
-- Module Name: TOPO - rtl
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

entity TOPO is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           echo: in STD_LOGIC;
           trigger: out STD_LOGIC;
           pwm1 : out STD_LOGIC;
           pwm2 : out STD_LOGIC);
end TOPO;

architecture rtl of TOPO is

component datapath 
    Port ( clk : in STD_LOGIC; -- vem da placa / simulação
           --onOff : in STD_LOGIC; -- vem da placa / sim
           echo: in STD_LOGIC;
           trigger: out STD_LOGIC;
           pwm1 : out STD_LOGIC; 
           pwm2 : out STD_LOGIC);
end component;

component clk_wiz_0 port 
 (
        clk_out1 : out STD_LOGIC;
        reset: in STD_LOGIC;
        locked:out STD_LOGIC;
        clk_in1 : in STD_LOGIC
 );
end component;

signal clk_20mz: std_logic;
signal rst: std_logic;


begin

rst <= not rst_n;

dcm: clk_wiz_0 port map (
    clk_out1 => clk_20mz,
    reset => rst,
    locked => open,
    clk_in1 =>  clk
);

dp:datapath Port map ( 
            clk => clk_20mz,
           --onOff : in STD_LOGIC; -- vem da placa / sim
           echo => echo,
           trigger => trigger,
           pwm1 => pwm1,
           pwm2 => pwm2
);

end rtl;
