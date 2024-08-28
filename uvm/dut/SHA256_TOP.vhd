
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library ieee;
use ieee.std_logic_1164.all;

entity SHA256_TOP is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        N_i : in std_logic_vector(31 downto 0);
        M_i : in std_logic_vector(31 downto 0);
        H : out std_logic_vector(255 downto 0);
        ready : out std_logic
    );
end SHA256_TOP;

architecture rtl of SHA256_TOP is

    -- Signals for interconnecting datapath and controlpath
    signal i_lt_N_s     : std_logic;
    signal j_lt_48_s     : std_logic;
    signal w_finished_s : std_logic;
    signal load_m_s     : std_logic;
    signal state_s      : std_logic_vector(2 downto 0);
    signal compute_t_s  : std_logic;
    signal N_take_in_s  : std_logic;
    signal t_lt_64_s    : std_logic;

begin

    -- Instantiate datapath
    u_datapath: entity work.datapath
        port map (
            clk           => clk,
            reset         => reset,
            N_i           => N_i,
            M_i           => M_i,
            i_lt_N_o      => i_lt_N_s,
            j_lt_48_o      => j_lt_48_s,
            w_finished_o  => w_finished_s,
            load_m_i      => load_m_s,
            state_i       => state_s,
            compute_t_i   => compute_t_s,
            N_take_in_i   => N_take_in_s,
            t_lt_64_o     => t_lt_64_s,
            H             => H
        );

    -- Instantiate controlpath
    u_controlpath: entity work.controlpath
        port map (
            clk           => clk,
            reset         => reset,
            start         => start,
            i_lt_N_i      => i_lt_N_s,
            j_lt_48_i      => j_lt_48_s,
            w_finished_i  => w_finished_s,
            load_m_o      => load_m_s,
            state_o       => state_s,
            t_lt_64_i     => t_lt_64_s,
            compute_t_o   => compute_t_s,
            N_take_in_o   => N_take_in_s,
            ready         => ready
        );

end architecture rtl;
