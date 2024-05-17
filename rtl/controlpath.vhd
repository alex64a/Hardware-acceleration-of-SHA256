library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlpath is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        done : out std_logic;
        -- Additional ports for interfacing with data path
        load_W : out std_logic;
        update_W : out std_logic;
        load_v : out std_logic;
        update_v : out std_logic;
        update_H : out std_logic;
        -- Port for iteration control
        iteration_done : in std_logic;
        t_done : in std_logic
    );
end controlpath;

architecture Behavioral of controlpath is
    type state_type is (IDLE, LOAD_W, COMPUTE_W, LOAD_V, COMPUTE_V, UPDATE_H, DONE);
    signal state, next_state : state_type;

    signal i, t : integer range 0 to 63;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            i <= 0;
            t <= 0;
            done <= '0';
        elsif rising_edge(clk) then
            state <= next_state;
            
            if state = IDLE or state = DONE then
                i <= 0;
                t <= 0;
            elsif state = LOAD_W then
                if t = 15 then
                    t <= 0;
                else
                    t <= t + 1;
                end if;
            elsif state = COMPUTE_W then
                if t = 63 then
                    t <= 0;
                else
                    t <= t + 1;
                end if;
            elsif state = LOAD_V then
                t <= 0;
            elsif state = COMPUTE_V then
                if t = 63 then
                    t <= 0;
                else
                    t <= t + 1;
                end if;
            elsif state = UPDATE_H then
                t <= 0;
                if i = N - 1 then
                    i <= 0;
                else
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;

    process(state, start, i, t, iteration_done, t_done)
    begin
        case state is
            when IDLE =>
                if start = '1' then
                    next_state <= LOAD_W;
                else
                    next_state <= IDLE;
                end if;
                done <= '0';
                load_W <= '0';
                update_W <= '0';
                load_v <= '0';
                update_v <= '0';
                update_H <= '0';
                
            when LOAD_W =>
                load_W <= '1';
                if t = 15 then
                    next_state <= COMPUTE_W;
                else
                    next_state <= LOAD_W;
                end if;
                done <= '0';
                update_W <= '0';
                load_v <= '0';
                update_v <= '0';
                update_H <= '0';
                
            when COMPUTE_W =>
                load_W <= '0';
                if t = 63 then
                    next_state <= LOAD_V;
                else
                    next_state <= COMPUTE_W;
                end if;
                done <= '0';
                update_W <= '1';
                load_v <= '0';
                update_v <= '0';
                update_H <= '0';

            when LOAD_V =>
                load_W <= '0';
                update_W <= '0';
                load_v <= '1';
                if iteration_done = '1' then
                    next_state <= COMPUTE_V;
                else
                    next_state <= LOAD_V;
                end if;
                done <= '0';
                update_v <= '0';
                update_H <= '0';
                
            when COMPUTE_V =>
                load_W <= '0';
                update_W <= '0';
                load_v <= '0';
                if t = 63 then
                    next_state <= UPDATE_H;
                else
                    next_state <= COMPUTE_V;
                end if;
                done <= '0';
                update_v <= '1';
                update_H <= '0';
                
            when UPDATE_H =>
                load_W <= '0';
                update_W <= '0';
                load_v <= '0';
                update_v <= '0';
                update_H <= '1';
                if i = N - 1 then
                    next_state <= DONE;
                else
                    next_state <= LOAD_W;
                end if;
                done <= '0';

            when DONE =>
                load_W <= '0';
                update_W <= '0';
                load_v <= '0';
                update_v <= '0';
                update_H <= '0';
                done <= '1';
                if start = '0' then
                    next_state <= IDLE;
                else
                    next_state <= DONE;
                end if;

            when others =>
                next_state <= IDLE;
                load_W <= '0';
                update_W <= '0';
                load_v <= '0';
                update_v <= '0';
                update_H <= '0';
                done <= '0';
        end case;
    end process;

end Behavioral;

