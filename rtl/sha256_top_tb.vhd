library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_SHA256_TOP is
end tb_SHA256_TOP;

architecture behavior of tb_SHA256_TOP is

    -- Component Declaration for the Unit Under Test (UUT)
    component SHA256_TOP
        Port (
            clk : in std_logic;
            reset : in std_logic;
            start : in std_logic;
            N_i : in std_logic_vector(31 downto 0);
            M_i : in std_logic_vector(31 downto 0);
            H : out std_logic_vector(255 downto 0);
            ready : out std_logic
        );
    end component;

    -- Signals for stimulating the UUT
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal N_i : std_logic_vector(31 downto 0) := (others => '0');
    signal M_i : std_logic_vector(31 downto 0) := (others => '0');
    signal H : std_logic_vector(255 downto 0);
    signal ready : std_logic;

    -- Clock period definition
    constant clk_period : time := 10.15 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SHA256_TOP
        port map (
            clk => clk,
            reset => reset,
            start => start,
            N_i => N_i,
            M_i => M_i,
            H => H,
            ready => ready
        );

    -- Clock process definitions
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        wait for 20 ns;
        start <= '1';
        N_i <= x"00000001";
        wait for 10 ns;        
        start <= '0';
        wait for 10 ns;        
        
        
        M_i <= x"31800000";
        wait for 10 ns;        
        M_i <= x"00000000";
        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000000";        
        wait for 10 ns;        
        M_i <= x"00000008";
        
        wait for 1000 ns;
        wait;
        
    end process;

end behavior;
