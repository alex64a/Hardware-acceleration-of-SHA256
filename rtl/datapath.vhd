library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        
        -- config input
        N_i : in std_logic_vector(31 downto 0);
        
        -- data input
        M_i : in std_logic_vector(31 downto 0); 
        
        i_lt_N_o     : out std_logic;
        w_finished_o : out std_logic;
        load_m_i     : in std_logic;
        --CONTROL SIGNAL FOR MUX
        state_i  : in std_logic_vector(2 downto 0);
        compute_t_i : in std_logic;
        N_take_in_i : in std_logic;
        j_lt_48_o   : out std_logic;
        t_lt_64_o   : out std_logic;
        
        H     : out std_logic_vector(255 downto 0)
    );
end datapath;

architecture Behavioral of datapath is
    type v_H_t is array (0 to 7) of std_logic_vector(31 downto 0);
    type W_t is array (0 to 63) of std_logic_vector(31 downto 0);
    type we_W_t is array (0 to 15) of std_logic;

    signal we_W_s : we_W_t;
    signal W_reg, W_next : W_t;
    signal w_s : W_t;
    signal v_reg, v_next : v_H_t;
    signal H_reg, H_next : v_H_t;
    signal i_reg, t_reg, T1_reg, T2_reg : std_logic_vector(31 downto 0);  -- 32-bit registers
    signal N_next, N_reg : std_logic_vector(31 downto 0);  -- 32-bit register
    signal j_next, j_reg : std_logic_vector(31 downto 0);  -- 32-bit register
    signal i_next, t_next, T1_next, T2_next : std_logic_vector(31 downto 0);  -- 32-bit next state register
    
    signal k_s : std_logic_vector(31 downto 0);
    signal T1_w_select_s : std_logic_vector(31 downto 0);
    signal t_lt_64_s, i_lt_N_s, j_lt_48_s : std_logic;
    signal cnt_o_s : std_logic_vector(4 downto 0);
    signal v_ch_s : std_logic_vector(31 downto 0);
    

begin

    W_regs_muxes: for i in 0 to 63 generate
    begin
    
        first_16_regs:if i < 16 generate
            process(clk, reset)
            begin
                if reset = '1' then
                    W_reg(i) <= (others => '0');
                elsif rising_edge(clk) then
                    if(we_W_s(i) = '1') then
                        W_reg(i) <= M_i;
                    end if;
                end if;
            end process;
        end generate;
                    
        we_comps:if i < 16 generate
            we_W_s(i) <= '1' when (cnt_o_s = std_logic_vector(to_unsigned(i,5)))
            else '0';
        end generate;
        
        after_16_regs:if i > 15 generate
            process(clk)
            begin
                if rising_edge(clk) then
                    if reset = '1' then
                        W_reg(i) <= (others => '0');
                    else
                        W_reg(i) <= W_next(i);
                    end if;
                end if;
            end process;
        end generate;
        
        after_16_muxes:if i > 15 generate 
            with state_i select W_next(i) <=
              (others => '0')  when "000",
              std_logic_vector(
                              ((unsigned(rotate_right(unsigned(W_reg(i - 2)), 17))  xor 
                              unsigned(rotate_right(unsigned(W_reg(i - 2)), 19))  xor 
                              shift_right(unsigned(W_reg(i - 2)), 10))  + 
                              unsigned(W_reg(i - 7)))  + 
                              ((unsigned(rotate_right(unsigned(W_reg(i - 15)), 7))  xor 
                              unsigned(rotate_right(unsigned(W_reg(i - 15)), 18))  xor 
                              shift_right(unsigned(W_reg(i - 15)), 3))  + 
                              unsigned(W_reg(i - 16)))
                          ) when "011",
              W_reg(i) when others;
         end generate;
   end generate;

   v_regs: for i in 0 to 7 generate
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
                  v_next(0)<= v_reg(0);
                  v_next(1)<= v_reg(1);
                  v_next(2)<= v_reg(2);
                  v_next(3)<= v_reg(3);
                  v_next(4)<= v_reg(4);
                  v_next(5)<= v_reg(5);
                  v_next(6)<= v_reg(6);
                  v_next(7)<= v_reg(7);
       case state_i is
           when "000" =>   
               v_next(0)<= std_logic_vector(to_unsigned(0,32));
               v_next(1)<= std_logic_vector(to_unsigned(0,32));
               v_next(2)<= std_logic_vector(to_unsigned(0,32));
               v_next(3)<= std_logic_vector(to_unsigned(0,32));
               v_next(4)<= std_logic_vector(to_unsigned(0,32));
               v_next(5)<= std_logic_vector(to_unsigned(0,32));
               v_next(6)<= std_logic_vector(to_unsigned(0,32));
               v_next(7)<= std_logic_vector(to_unsigned(0,32));
               
           when "011" =>
               v_next(0)<= H_reg(0);
               v_next(1)<= H_reg(1);
               v_next(2)<= H_reg(2);
               v_next(3)<= H_reg(3);
               v_next(4)<= H_reg(4);
               v_next(5)<= H_reg(5);
               v_next(6)<= H_reg(6);
               v_next(7)<= H_reg(7);
               
           when "101" =>
               v_next(7) <= v_reg(6);
               v_next(6) <= v_reg(5);
               v_next(5) <= v_reg(4);
               v_next(4) <= std_logic_vector(unsigned(v_reg(3)) + unsigned(T1_reg));
               v_next(3) <= v_reg(2);
               v_next(2) <= v_reg(1);
               v_next(1) <= v_reg(0);
               v_next(0) <= std_logic_vector(unsigned(T1_reg) + unsigned(T2_reg));
           
           when others =>
               v_next(0)<= v_reg(0);
               v_next(1)<= v_reg(1);
               v_next(2)<= v_reg(2);
               v_next(3)<= v_reg(3);
               v_next(4)<= v_reg(4);
               v_next(5)<= v_reg(5);
               v_next(6)<= v_reg(6);
               v_next(7)<= v_reg(7);
           end case;
       end process;
    
    H_regs: for i in 0 to 7 generate
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
    
       
    H_muxes:process (state_i, v_reg, H_reg) is
    begin
        case state_i is
            when "000" =>   
                H_next(0)<= x"6a09e667";
                H_next(1)<= x"bb67ae85";
                H_next(2)<= x"3c6ef372";
                H_next(3)<= x"a54ff53a";
                H_next(4)<= x"510e527f";
                H_next(5)<= x"9b05688c";
                H_next(6)<= x"1f83d9ab";
                H_next(7)<= x"5be0cd19";
                
            when "110" =>
                H_next(7) <= std_logic_vector(unsigned(v_reg(7)) + unsigned(H_reg(7)));
                H_next(6) <= std_logic_vector(unsigned(v_reg(6)) + unsigned(H_reg(6)));
                H_next(5) <= std_logic_vector(unsigned(v_reg(5)) + unsigned(H_reg(5)));
                H_next(4) <= std_logic_vector(unsigned(v_reg(4)) + unsigned(H_reg(4)));
                H_next(3) <= std_logic_vector(unsigned(v_reg(3)) + unsigned(H_reg(3)));
                H_next(2) <= std_logic_vector(unsigned(v_reg(2)) + unsigned(H_reg(2)));
                H_next(1) <= std_logic_vector(unsigned(v_reg(1)) + unsigned(H_reg(1)));
                H_next(0) <= std_logic_vector(unsigned(v_reg(0)) + unsigned(H_reg(0)));
            
            when others =>
                H_next(0)<= H_reg(0);
                H_next(1)<= H_reg(1);
                H_next(2)<= H_reg(2);
                H_next(3)<= H_reg(3);
                H_next(4)<= H_reg(4);
                H_next(5)<= H_reg(5);
                H_next(6)<= H_reg(6);
                H_next(7)<= H_reg(7);
            
            end case;
        end process;

    other_regs:process(clk, reset)
    begin
        if reset = '1' then
            -- Asynchronous reset
            i_reg <= (others => '0');
            N_reg <= (others => '0');
            t_reg <= (others => '0');
            j_reg <= (others => '0');
            T1_reg <= (others => '0');
            T2_reg <= (others => '0');
        elsif rising_edge(clk) then
            -- Update registers with next state values
            i_reg <= i_next;
            N_reg <= N_next;
            t_reg <= t_next;
            j_reg <= j_next;
            T1_reg <= T1_next;
            T2_reg <= T2_next;
        end if;
    end process;
    
    i_mux:
    with state_i select i_next <=
      (others => '0')  when "000",
      std_logic_vector(unsigned(i_reg) + to_unsigned(1, 32)) when "110",
      i_reg when others; 
          
    j_mux:process (state_i, j_lt_48_s, j_reg) is
      begin
      case state_i is
          when "000" =>   
              j_next <= (others => '0');
              
          when "011" =>
              if(j_lt_48_s = '1') then 
                  j_next <= std_logic_vector(unsigned(j_reg) + to_unsigned(1, 32));
              else
                  j_next <= j_reg;
              end if;
          
          when others =>
              j_next <= j_reg;
          end case;
      end process;   
      
      t_mux:
      with state_i select t_next <=
        (others => '0')  when "000",
        std_logic_vector(unsigned(t_reg) + to_unsigned(1, 32)) when "101",
        t_reg when others;
        
        
    T1_mux:process (state_i, t_lt_64_s, v_reg, T1_reg) is
    begin
    case state_i is
        when "000" =>   
            T1_next <= (others => '0');
            
        when "100" =>
            if(t_lt_64_s = '1') then 
                T1_next <= std_logic_vector(
                            (unsigned( rotate_right(unsigned(v_reg(4)), 6)) xor 
                            unsigned( rotate_right(unsigned(v_reg(4)), 11)) xor 
                            unsigned( rotate_right(unsigned(v_reg(4)), 25))) + 
                            unsigned(v_reg(7)) + 
                            unsigned((v_reg(4) and v_reg(5)) xor (not v_reg(4) and v_reg(6))) + 
                            unsigned(k_s) + 
                            unsigned(T1_w_select_s)
                          );
            else
                T1_next <= T1_reg;
            end if;
        
        when others =>
            T1_next <= T1_reg;
        end case;
    end process;

      coefficients_mux: with t_reg select k_s <=        
      x"428a2f98" when x"00000000",
      x"71374491" when x"00000001",
      x"b5c0fbcf" when x"00000002",
      x"e9b5dba5" when x"00000003",
      x"3956c25b" when x"00000004",
      x"59f111f1" when x"00000005",
      x"923f82a4" when x"00000006",
      x"ab1c5ed5" when x"00000007",
      x"d807aa98" when x"00000008",
      x"12835b01" when x"00000009",
      x"243185be" when x"0000000A",
      x"550c7dc3" when x"0000000B",
      x"72be5d74" when x"0000000C",
      x"80deb1fe" when x"0000000D",
      x"9bdc06a7" when x"0000000E",
      x"c19bf174" when x"0000000F",
      x"e49b69c1" when x"00000010",
      x"efbe4786" when x"00000011",
      x"0fc19dc6" when x"00000012",
      x"240ca1cc" when x"00000013",
      x"2de92c6f" when x"00000014",
      x"4a7484aa" when x"00000015",
      x"5cb0a9dc" when x"00000016",
      x"76f988da" when x"00000017",
      x"983e5152" when x"00000018",
      x"a831c66d" when x"00000019",
      x"b00327c8" when x"0000001A",
      x"bf597fc7" when x"0000001B",
      x"c6e00bf3" when x"0000001C",
      x"d5a79147" when x"0000001D",
      x"06ca6351" when x"0000001E",
      x"14292967" when x"0000001F",
      x"27b70a85" when x"00000020",
      x"2e1b2138" when x"00000021",
      x"4d2c6dfc" when x"00000022",
      x"53380d13" when x"00000023",
      x"650a7354" when x"00000024",
      x"766a0abb" when x"00000025",
      x"81c2c92e" when x"00000026",
      x"92722c85" when x"00000027",
      x"a2bfe8a1" when x"00000028",
      x"a81a664b" when x"00000029",
      x"c24b8b70" when x"0000002A",
      x"c76c51a3" when x"0000002B",
      x"d192e819" when x"0000002C",
      x"d6990624" when x"0000002D",
      x"f40e3585" when x"0000002E",
      x"106aa070" when x"0000002F",
      x"19a4c116" when x"00000030",
      x"1e376c08" when x"00000031",
      x"2748774c" when x"00000032",
      x"34b0bcb5" when x"00000033",
      x"391c0cb3" when x"00000034",
      x"4ed8aa4a" when x"00000035",
      x"5b9cca4f" when x"00000036",
      x"682e6ff3" when x"00000037",
      x"748f82ee" when x"00000038",
      x"78a5636f" when x"00000039",
      x"84c87814" when x"0000003A",
      x"8cc70208" when x"0000003B",
      x"90befffa" when x"0000003C",
      x"a4506ceb" when x"0000003D",
      x"bef9a3f7" when x"0000003E",
      x"c67178f2" when x"0000003F",
      (others => '0') when others;      
      
      T1_select_w_mux: with t_reg select T1_w_select_s <=     
      W_reg(0)  when x"00000000",
      W_reg(1)  when x"00000001",
      W_reg(2)  when x"00000002",
      W_reg(3)  when x"00000003",
      W_reg(4)  when x"00000004",
      W_reg(5)  when x"00000005",
      W_reg(6)  when x"00000006",
      W_reg(7)  when x"00000007",
      W_reg(8)  when x"00000008",
      W_reg(9)  when x"00000009",
      W_reg(10) when x"0000000A",
      W_reg(11) when x"0000000B",
      W_reg(12) when x"0000000C",
      W_reg(13) when x"0000000D",
      W_reg(14) when x"0000000E",
      W_reg(15) when x"0000000F",
      W_reg(16) when x"00000010",
      W_reg(17) when x"00000011",
      W_reg(18) when x"00000012",
      W_reg(19) when x"00000013",
      W_reg(20) when x"00000014",
      W_reg(21) when x"00000015",
      W_reg(22) when x"00000016",
      W_reg(23) when x"00000017",
      W_reg(24) when x"00000018",
      W_reg(25) when x"00000019",
      W_reg(26) when x"0000001A",
      W_reg(27) when x"0000001B",
      W_reg(28) when x"0000001C",
      W_reg(29) when x"0000001D",
      W_reg(30) when x"0000001E",
      W_reg(31) when x"0000001F",
      W_reg(32) when x"00000020",
      W_reg(33) when x"00000021",
      W_reg(34) when x"00000022",
      W_reg(35) when x"00000023",
      W_reg(36) when x"00000024",
      W_reg(37) when x"00000025",
      W_reg(38) when x"00000026",
      W_reg(39) when x"00000027",
      W_reg(40) when x"00000028",
      W_reg(41) when x"00000029",
      W_reg(42) when x"0000002A",
      W_reg(43) when x"0000002B",
      W_reg(44) when x"0000002C",
      W_reg(45) when x"0000002D",
      W_reg(46) when x"0000002E",
      W_reg(47) when x"0000002F",
      W_reg(48) when x"00000030",
      W_reg(49) when x"00000031",
      W_reg(50) when x"00000032",
      W_reg(51) when x"00000033",
      W_reg(52) when x"00000034",
      W_reg(53) when x"00000035",
      W_reg(54) when x"00000036",
      W_reg(55) when x"00000037",
      W_reg(56) when x"00000038",
      W_reg(57) when x"00000039",
      W_reg(58) when x"0000003A",
      W_reg(59) when x"0000003B",
      W_reg(60) when x"0000003C",
      W_reg(61) when x"0000003D",
      W_reg(62) when x"0000003E",
      W_reg(63) when x"0000003F",
      (others => '0') when others;
      
        T2_mux:process (state_i, v_reg, t_lt_64_s, T2_reg) is
        begin
        v_ch_s <= (v_reg(0) and v_reg(1)) xor (v_reg(0) and v_reg(2)) xor (v_reg(1) and v_reg(2));
        case state_i is
            when "000" =>   
                T2_next <= (others => '0');
                
            when "100" =>
                if(t_lt_64_s = '1') then 
                    T2_next <= std_logic_vector(
                                (unsigned(rotate_right(unsigned(v_reg(0)), 2)) xor
                                rotate_right(unsigned(v_reg(0)), 13) xor 
                                rotate_right(unsigned(v_reg(0)), 22))    
                               + unsigned(v_ch_s)
                            );
                else
                    T2_next <= T2_reg;
                end if;
            
            when others =>
                T2_next <= T2_reg;
            end case;
        end process;
        
      N_mux:process (N_i, N_take_in_i, N_reg) is
        begin
            if( N_take_in_i = '1') then 
                N_next <= N_i;
            else
                N_next <= N_reg;
            end if;
        end process;
        
      t_comparator: process (t_reg)
      begin
        if( t_reg < std_logic_vector(to_unsigned(64, 32))) then
            t_lt_64_s <= '1';
        else
            t_lt_64_s <= '0';
        end if;
      end process;
      
      t_lt_64_o <= t_lt_64_s;
      
        i_comparator: process (i_reg, N_reg)
        begin
          if( i_reg < N_reg ) then
              i_lt_N_s <= '1';
          else
              i_lt_N_s <= '0';
          end if;
        end process;
        
        j_comparator: process (j_reg)
        begin
          if( j_reg < std_logic_vector(to_unsigned(47, 32)) ) then
              j_lt_48_s <= '1';
          else
              j_lt_48_s <= '0';
          end if;
        end process;
        
      j_lt_48_o <= j_lt_48_s;
      
      i_lt_N_o <= i_lt_N_s;
      
      counter: process (clk, cnt_o_s, load_m_i)
      begin
        if(rising_edge(clk)) then
          if(reset = '1') then
            cnt_o_s <= "00000";
          else
            if(cnt_o_s <= "01111") then
            
                if(load_m_i = '1') then
                    cnt_o_s <= (others => '0');
                else
                    cnt_o_s <= std_logic_vector(unsigned(cnt_o_s) + to_unsigned(1, 5));
                end if;
                if(cnt_o_s = "01111") then
                    w_finished_o <= '1';
                else
                    w_finished_o <= '0';
                end if;
             else
                cnt_o_s <= "11111";
            end if;
        end if;
        end if;
      end process;
      
      H <= H_reg(0) & H_reg(1) & H_reg(2) & H_reg(3) & H_reg(4) & H_reg(5) & H_reg(6) & H_reg(7);
            

end Behavioral;
