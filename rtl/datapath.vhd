library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        
        -- data input
        M_i : in std_logic_vector(31 downto 0);
        
        i_lt_N_o     : out std_logic;
        w_finished_o : out std_logic;
        load_m_i     : in std_logic;
        --CONTROL SIGNAL FOR MUX
        state_i  : in std_logic_vector(2 downto 0);
        t_lt_64_o   : out std_logic;
        compute_t_i : in std_logic;
        
        H     : out std_logic_vector(31 downto 0)
    );
end datapath;

architecture Behavioral of datapath is
    type v_H_t is array (1 to 8) of std_logic_vector(31 downto 0);
    type W_t is array (1 to 64) of std_logic_vector(31 downto 0);

    signal W_reg, W_next : W_t;
    signal w_s : W_t;
    signal v_reg, v_next : v_H_t;
    signal H_reg, H_next : v_H_t;
    signal i_reg, t_reg, T1_reg, T2_reg : std_logic_vector(31 downto 0);  -- 32-bit registers
    signal i_next, t_next, T1_next, T2_next : std_logic_vector(31 downto 0);  -- 32-bit next state signals

begin

    W_regs_muxes: for i in 1 to 64 generate
    begin
        process(clk, reset)
        begin
            if reset = '1' then
                W_reg(i) <= (others => '0');
            elsif rising_edge(clk) then
                W_reg(i) <= W_next(i);
            end if;
        end process;
        
        first_16_muxes:if i < 17 generate
            W_mux: with state_i select W_next(i) <=
               (others => '0')  when "000",
               M_i when "010",
               W_reg(i) when others;
        end generate;
        
        after_16_muxes:if i > 16 generate 
        w_s(i) <= W_reg(i-15)(6 downto 0) &  W_reg(i-15)(31 downto 7);
            with state_i select W_next(i) <=
              (others => '0')  when "000",
              (W_reg(i-2)(16 downto 0) & W_reg(i-2)(31 downto 17)) xor (W_reg(i-2)(18 downto 0) & W_reg(i-2)(31 downto 19)) xor
              std_logic_vector(unsigned(shift_right(unsigned(W_reg(i-2)), 10)) + unsigned(W_reg(i-7)) +
              unsigned(w_s(i))) xor (W_reg(i-15)(17 downto 0) & W_reg(i-15)(31 downto 18)) xor
              std_logic_vector(unsigned(shift_right(unsigned(W_reg(i-15)), 3)) + unsigned(W_reg(i-16))) when "011",
              W_reg(i) when others;
         end generate;
   end generate;

   v_regs: for i in 1 to 8 generate
   begin
       v_regs:process(clk, reset)
       begin
           if reset = '1' then
               v_reg(i) <= ( others => '0');
           elsif rising_edge(clk) then
               v_reg(i) <= v_next(i);
           end if;
       end process;
   end generate;
   
   v_muxes:process (state_i, H_reg, v_reg, T1_reg, T2_reg) is
   begin
       case state_i is
           when "000" =>   
               v_next(1)<= std_logic_vector(to_unsigned(0,32));
               v_next(2)<= std_logic_vector(to_unsigned(0,32));
               v_next(3)<= std_logic_vector(to_unsigned(0,32));
               v_next(4)<= std_logic_vector(to_unsigned(0,32));
               v_next(5)<= std_logic_vector(to_unsigned(0,32));
               v_next(6)<= std_logic_vector(to_unsigned(0,32));
               v_next(7)<= std_logic_vector(to_unsigned(0,32));
               v_next(8)<= std_logic_vector(to_unsigned(0,32));
               
           when "011" =>
               v_next(1)<= H_reg(1);
               v_next(2)<= H_reg(2);
               v_next(3)<= H_reg(3);
               v_next(4)<= H_reg(4);
               v_next(5)<= H_reg(5);
               v_next(6)<= H_reg(6);
               v_next(7)<= H_reg(7);
               v_next(8)<= H_reg(8);
               
           when "110" =>
               v_next(8) <= v_reg(7);
               v_next(7) <= v_reg(6);
               v_next(6) <= v_reg(5);
               v_next(5) <= std_logic_vector(unsigned(v_reg(4)) + unsigned(T1_reg));
               v_next(4) <= v_reg(3);
               v_next(3) <= v_reg(2);
               v_next(2) <= v_reg(1);
               v_next(1) <= std_logic_vector(unsigned(T1_reg) + unsigned(T2_reg));
           
           when others =>
               v_next(1)<= v_reg(1);
               v_next(2)<= v_reg(2);
               v_next(3)<= v_reg(3);
               v_next(4)<= v_reg(4);
               v_next(5)<= v_reg(5);
               v_next(6)<= v_reg(6);
               v_next(7)<= v_reg(7);
               v_next(8)<= v_reg(8);
           end case;
       end process;
    
    H_regs: for i in 1 to 8 generate
    begin
       H_regs:process(clk, reset)
       begin
           if reset = '1' then
               H_reg(i) <= ( others => '0');
           elsif rising_edge(clk) then
               H_reg(i) <= H_next(i);
           end if;
       end process;
    end generate;
    
       
    H_muxes:process (state_i) is
    begin
        case state_i is
            when "000" =>   
                H_next(1)<= x"6a09e667";
                H_next(2)<= x"bb67ae85";
                H_next(3)<= x"3c6ef372";
                H_next(4)<= x"a54ff53a";
                H_next(5)<= x"510e527f";
                H_next(6)<= x"9b05688c";
                H_next(7)<= x"1f83d9ab";
                H_next(8)<= x"5be0cd19";
                
            when "111" =>
                H_next(8) <= std_logic_vector(unsigned(v_reg(8)) + unsigned(H_reg(8)));
                H_next(7) <= std_logic_vector(unsigned(v_reg(7)) + unsigned(H_reg(7)));
                H_next(6) <= std_logic_vector(unsigned(v_reg(6)) + unsigned(H_reg(6)));
                H_next(5) <= std_logic_vector(unsigned(v_reg(5)) + unsigned(H_reg(5)));
                H_next(4) <= std_logic_vector(unsigned(v_reg(4)) + unsigned(H_reg(4)));
                H_next(3) <= std_logic_vector(unsigned(v_reg(3)) + unsigned(H_reg(3)));
                H_next(2) <= std_logic_vector(unsigned(v_reg(2)) + unsigned(H_reg(2)));
                H_next(1) <= std_logic_vector(unsigned(v_reg(1)) + unsigned(H_reg(1)));
            
            when others =>
                H_next(1)<= H_reg(1);
                H_next(2)<= H_reg(2);
                H_next(3)<= H_reg(3);
                H_next(4)<= H_reg(4);
                H_next(5)<= H_reg(5);
                H_next(6)<= H_reg(6);
                H_next(7)<= H_reg(7);
                H_next(8)<= H_reg(8);
            
            end case;
        end process;

    other_regs:process(clk, reset)
    begin
        if reset = '1' then
            -- Asynchronous reset
            i_reg <= (others => '0');
            t_reg <= (others => '0');
            T1_reg <= (others => '0');
            T2_reg <= (others => '0');
        elsif rising_edge(clk) then
            -- Update registers with next state values
            i_reg <= i_next;
            t_reg <= t_next;
            T1_reg <= T1_next;
            T2_reg <= T2_next;
        end if;
    end process;
    
    i_mux:
    with state_i select i_next <=
      (others => '0')  when "000",
      std_logic_vector(unsigned(i_reg) + to_unsigned(1, 32)) when "111",
      i_reg when others;
    

end Behavioral;
