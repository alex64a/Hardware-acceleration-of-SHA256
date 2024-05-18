library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlpath is
    Port (
        clk   : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        -- Additional ports for interfacing with data path
        i_lt_N_i     : in std_logic;
        w_finished_i : in std_logic;
        load_m_o     : out std_logic;
        --CONTROL SIGNAL FOR MUX
        state_o  : out std_logic_vector(2 downto 0);
        t_lt_64_i   : in std_logic;
        compute_t_o : out std_logic;
        
        ready : out std_logic
    );
end controlpath;

architecture Behavioral of controlpath is
    type state_type is (IDLE, LOAD_W, W_LOADED, SIG, T_PHASE, COMPUTE_V, UPDATE_H);
    signal state_reg, state_next : state_type;
begin

    state_register:process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= IDLE;
        elsif rising_edge(clk) then
            state_reg <= state_next;
        end process;
     
     next_state_logic:process(state_reg, start )
     begin
         case state_reg is
             when IDLE =>
                 ready <= '1';
                 state_o    <= "000";
                 if start = '1' then
                     state_next <= LOAD_W;
                 else
                     state_next <= IDLE;
                 end if;
     
             when LOAD_W =>
                  state_o    <= "001";
                 if i_lt_N_i = '1' then
                     load_m_o <= '1';
                     state_next <= W_LOADED;
                 else
                     load_m_o <= '0';
                     state_next <= IDLE;
                 end if;
                 
              when W_LOADED =>
                  state_o    <= "010";
                 if w_finished_i = '1' then
                     state_next <= SIG;
                 else
                     state_next <= W_LOADED;
                 end if;
     
             when SIG =>
                  state_o    <= "011";
                  state_next <= T_PHASE;
                     
             when T_PHASE =>
                   state_o    <= "100";
                 if t_lt_64_i = '1' then
                    compute_t_o <= '1';
                     state_next <= COMPUTE_V;
                 else
                     compute_t_o <= '0';
                     state_next <= UPDATE_H;
                 end if;
     
             when COMPUTE_V =>
                 state_o    <= "101";
                 state_next <= COMPUTE_V;
     
             when UPDATE_H =>
                state_o    <= "110";
                 state_next <= LOAD_W;
     
             when others =>
                state_o    <= "000";
                 state_next <= IDLE;  -- Default state assignment for safety
         end case;
     end process;

end Behavioral;