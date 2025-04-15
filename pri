
I1_pgen_vhdl : pgen_vhdl
PORT MAP (
            din  => difm_freq_match,
            clk  => clk,
            dout => freq_match_pul_r );
    
I2_pgen_vhdl : pgen_vhdl
PORT MAP (
            din  => not difm_freq_match,
            clk  => clk,
            dout => freq_match_pul_f );

process(clk)
begin
if(rising_edge(clk)) then
if(jamm_en = '1') then -- or pri_cnt_clr = '0') then
    if(pw_check_cnt  >= pw_verify_cnt  and (pw_check_cnt <= pw_verify_cnt + pw_verify_const) and difm_freq_match1 = '1') then     
        pw_check_cnt        <= pw_check_cnt + '1';
        invalid_pw_trig     <= '0';
    elsif(pw_check_cnt  >= pw_verify_cnt  and (pw_check_cnt <= pw_verify_cnt + pw_verify_const) and difm_freq_match1 = '0') then
        pw_check_cnt        <= (others =>'0');  
        invalid_pw_trig     <= '1';  
    elsif(difm_freq_match = '1' and invalid_pw = '0') then
        pw_check_cnt        <= pw_check_cnt + '1';
        invalid_pw_trig     <= '0'; 
    end if;
    
    if(freq_match_pul_f     = '1' and invalid_pw = '1') then
        invalid_pw          <= '0';
        calc_pw             <= calc_pw; 
        pw_check_cnt        <= (others =>'0'); 
    elsif(freq_match_pul_f  = '1' and invalid_pw = '0') then
        invalid_pw          <= '0';
        calc_pw             <= pw_check_cnt - '1';
        pw_check_cnt        <= (others =>'0');         
    elsif(invalid_pw_trig   = '1') then
        invalid_pw          <= '1';
    else         
        invalid_pw          <= invalid_pw;
    end if;
    
    -------------- while using the PRI make sure that the lookthrough and the sync count is >= 2
    pri_check_cnt       <= pri_check_cnt +'1';
    
    if(freq_match_pul_r = '1') then
        calc_pri_off     <= pri_check_cnt - pri_check_cnt1;
    end if;
    
    if(freq_match_pul_f = '1') then
        pri_check_cnt1  <= pri_check_cnt;
    end if;
    
    calc_pri        <= calc_pw + calc_pri_off;
         
else
    invalid_pw_trig <= '0';
    invalid_pw      <= '0';
    pw_check_cnt    <= (others =>'0');
    calc_pw         <= (others =>'0');
    calc_pri        <= (others =>'0');
end if;
end if;
end process;

process(clk)
begin
if(rising_edge(clk)) then
if((calc_pw <= pw1+pw_offset) and  (calc_pw > pw1 - pw_offset)) then   -- offset of 200 ns.
    pw_match <= '1';
else
    pw_match <= '0';    
end if;

--if((calc_pri <= pri1+pri_offset) and  (calc_pri > pri1 - pri_offset)) then
--    pri_match <= '1';
--else
--    pri_match <= '0';    
--end if;
end if;
end process;

---- PW and PRI Calucation for the log detector. -- Helpful while simulation
--process(clk)
--begin
--if(rising_EdgE(clk)) then
--if(jamm_en = '1') then
--    if(difm_freq_match = '1') then
--        pw_check_cnt        <= pw_check_cnt + '1';  
--    elsif(freq_match_pul_f = '1') then
--        calc_pw             <= pw_check_cnt;
--        pw_check_cnt        <= (others =>'0'); 
--    end if;        
    
--    pri_check_cnt       <= pri_check_cnt +'1';
    
--    if(freq_match_pul_r = '1') then
--    calc_pri_off     <= pri_check_cnt - pri_check_cnt1;
--    end if;
    
--    if(freq_match_pul_f = '1') then
--    pri_check_cnt1  <= pri_check_cnt;
--    end if;
    
--    calc_pri        <= calc_pw + calc_pri_off;
    
--else
--    pw_check_cnt        <= (others =>'0');
--    pri_check_cnt       <= (others =>'0');       
--    pri_check_cnt1      <= (others =>'0');       
--    calc_pri            <= (others =>'0');       
--    calc_pw             <= (others =>'0');       
--end if;
--end if;
--end process;
