library ieee;
use ieee.std_logic_1164.all;

entity Robot2_project is
	port(
			clk			: in bit;
			button 		: in std_logic;
			in_bit 		: in bit_vector (6 downto 1);
			LED 			: out bit_vector(6 downto 1);
			left_motor 	: out std_logic;
			right_motor : out std_logic;
			seg1, seg3	: out std_logic_vector(0 to 6);
			seg0 			: out std_logic_vector(0 to 7)
			);
end Robot2_project;
			
architecture line_tracer_code of Robot2_project is
	signal time_cnt       	   : integer range 0 to 50000 := 0;
	signal sec_cnt       	   : integer range 0 to 100 := 0;
	signal ms_tmp       	   	: integer range 0 to 100 := 0;
	signal ms_cnt       	   	: integer range 0 to 1000 := 0;
	signal stop_flag				: std_logic := '0';
	signal mode						: std_logic := '0';	
	-- 모터 동작 
	signal carry_cnt			: integer range 0 to 50000 := 0;
	signal left_motor_rate 	: integer range 0 to 100 := 0;
	signal right_motor_rate : integer range 0 to 100 := 0;
	signal drive_mode			: std_logic	 := '0';
	-- 블랙 카운트를 셀때 순간의 블랙 카운트를 포착하기 위해서 타이머 선언. 
	signal timer_one_sec		: integer range 0 to 49999999; -- DE0보드의 주파수는 50Mhz 이므로 주기는 20ns 따라서 50000000번 카운트하여 1초 구현 
	signal black_count_pop		: integer range 0 to 1000000  := 0;
	
	type is_array is array(6 downto 1) of integer range -10 to 10;
	signal sensor_now : is_array;
	signal sensor_buf : bit_vector(6 downto 1);

	
begin
   process(clk)
   begin
      if(clk'event and clk = '1') then -- rising edge
         if(time_cnt > 49999) then -- 1ms
            time_cnt <= 0;
            if(mode = '1' and stop_flag = '0') then -- 버튼이 모드를 1로 변경하면 프로세스 동작 
               if(ms_cnt > 999) then
                  sec_cnt <= sec_cnt + 1; -- 1 sec 카운트 
                  ms_cnt <= 0;
               else
                  ms_cnt <= ms_cnt + 1; -- 1 ms 카운트 
               end if;
            end if;
         else
            time_cnt <= time_cnt + 1;
         end if;
      end if;
   end process;
   
   process(ms_cnt)
   begin
      if(mode = '1') then --랩타임 표시 
         case(sec_cnt/10) is -- 10초 단위 표현 
            when 0 =>   seg1 <= "0000001";
            when 1 =>   seg1 <= "1001111";
            when 2 =>   seg1 <= "0010010";
            when 3 =>   seg1 <= "0000110";
            when 4 =>   seg1 <= "1001100";
            when 5 =>   seg1 <= "0100100";
            when 6 =>   seg1 <= "0100000";
            when 7 =>   seg1 <= "0001101";
            when 8 =>   seg1 <= "0000000";
            when 9 =>   seg1 <= "0000100";
            when others =>   seg1 <= "1111111";
         end case;
         
         case(sec_cnt mod 10) is -- 1초 단위 표현 
            when 0 =>   seg0 <= "00000010";
            when 1 =>   seg0 <= "10011110";
            when 2 =>   seg0 <= "00100100";
            when 3 =>   seg0 <= "00001100";
            when 4 =>   seg0 <= "10011000";
            when 5 =>   seg0 <= "01001000";
            when 6 =>   seg0 <= "01000000";
            when 7 =>   seg0 <= "00011010";
            when 8 =>   seg0 <= "00000000";
            when 9 =>   seg0 <= "00001000";
            when others =>   seg0 <= "11111110";
         end case;
      end if;
   end process;

	process(clk, button, in_bit, carry_cnt)
		-- 모터의 속도를 100으로 설정하여 500 을 곱하여 PWM의 주기인 50000과 맞춰주기 위해서 사용.
		variable left_motor_rate_to_clock	: integer :=0;
		variable right_motor_rate_to_clock	: integer :=0;
		-- 블랙 카운트 팝의 개수를 정제하여 넣기 위해서 사용.
		variable black_count	: integer range 0 to 1000000  :=0;
		
	begin
		if (button'event and button = '1') then -- 버튼 누르면 모드 1로 변경 
			if (mode = '1') then mode <= '0';
			else mode <= '1';
			end if;
		end if;
		
		if(black_count = 7) then
			mode <= '0';
		end if;
		
		if ( mode = '1' and stop_flag = '0' ) then -- 로봇 구동 동작 시작 조건문 
			if(clk'event and clk = '1') then 
				
				timer_one_sec <= timer_one_sec + 1;
				
				if(carry_cnt >= 49998) then
					carry_cnt <= 0;
				else
					carry_cnt <= carry_cnt + 1;
				end if;
				
				for i in 6 downto 1 loop -- 가중치를 사용할 때 곱하려고 했으나 가중치 사용 안했음.
					if(in_bit(i) = '0') then
						LED(i) <= '1';
						sensor_now(i) <= 0; -- is_array_type
						sensor_buf(i) <= '0'; -- bit_vector_type
					else
						led(i) <= '0';
						sensor_now(i) <= 1; 
						sensor_buf(i) <= '1';
					end if;
				end loop;

				if (timer_one_sec mod 500000 = 0) then -- 순간의 튀는 블랙카운트의 수 카운트하기 위해서 사용.
					if in_bit = "000000" then
						black_count_pop <= black_count_pop + 1;
						black_count := black_count_pop/9; -- 나의 로봇이 잡는 카운트의 수를 계산하여 9로 나누기 하여 몫 추출 
						if (black_count_pop / 9) = 0 then
							seg3	<= "0000001"; -- 0
						elsif (black_count_pop / 9) = 1 then
							seg3	<= "1001111"; -- 1
						elsif (black_count_pop / 9) = 2 then
							seg3	<= "0010010"; -- 2
						elsif (black_count_pop / 9) = 3 then
							seg3	<= "0000110"; -- 3
						elsif (black_count_pop / 9) = 4 then
							seg3	<= "1001100"; -- 4
						elsif (black_count_pop / 9) = 5 then
							seg3	<= "0100100"; -- 5
						elsif (black_count_pop / 9) = 6 then
							seg3	<= "0100000"; -- 6
						elsif (black_count_pop / 9) = 7 then
							seg3	<= "0001101"; -- 7
						elsif (black_count_pop / 9) = 8 then
							seg3	<= "0000000"; -- 8
						else
							seg3	<= "0000100"; -- 9
						end if;
					end if;
				end if;
				
				if(black_count = 1 and in_bit = "111111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
				
				elsif(black_count = 2 and in_bit = "111111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
				
				elsif(black_count = 3 and in_bit = "111111") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;			
					
				elsif(black_count = 4 and in_bit = "111111") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
					
				elsif(black_count = 5) then 
					left_motor_rate <= 50;
					right_motor_rate <= 50;
				
				elsif(black_count = 6) then
					left_motor_rate <= 0;
					right_motor_rate <= 0;

				elsif(black_count = 7) then
					left_motor_rate <= 0;
					right_motor_rate <= 0;
					
				elsif(in_bit = "110011") then
					left_motor_rate <= 40;
					right_motor_rate <= 40;

				elsif(in_bit = "111011") then
					left_motor_rate <= 40;
					right_motor_rate <= 35;

				elsif(in_bit = "110111") then
					left_motor_rate <= 35;
					right_motor_rate <= 40;
			 
				elsif(in_bit = "100111") then
					left_motor_rate <= 0;
					right_motor_rate <= 70;

				elsif(in_bit = "111001") then
					left_motor_rate <= 70;
					right_motor_rate <= 0;
			 
				elsif(in_bit = "111101") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;

				elsif(in_bit = "101111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
			  
				elsif(in_bit = "111110") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
			  
				elsif(in_bit = "011111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
			  
				elsif(in_bit = "111100") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
			  
				elsif(in_bit = "001111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
			  
				elsif(in_bit = "111000") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
			  
				elsif(in_bit = "000111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
			  
				elsif(in_bit = "110001") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;

				elsif(in_bit = "100011") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
					
				elsif(in_bit = "110000") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
					
				elsif(in_bit = "000011") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
					
				elsif(in_bit = "100001") then
					left_motor_rate <= 100;
					right_motor_rate <= 0;
				
				elsif(in_bit = "111111") then
					left_motor_rate <= 0;
					right_motor_rate <= 100;
				else
					left_motor_rate <= 30;
					right_motor_rate <= 30;
				end if;
				
			end if;
		
		
			-- Motor	코드 구현 
			left_motor_rate_to_clock	:= 500 * left_motor_rate; -- pwm모터의 주파수는 1KHz이기 때문에 1KHz 구현 
			right_motor_rate_to_clock  := 500 * right_motor_rate;
			
			if(time_cnt < left_motor_rate_to_clock) then
				left_motor <= '1';
			else
				left_motor <= '0';
			end if;
			
			if(time_cnt < right_motor_rate_to_clock) then
				right_motor <= '1';
			else
				right_motor <= '0';
			end if;
			
		else
			-- 모터 끄기 
			left_motor <= '0';
			right_motor <= '0';
			
			for i in 6 downto 1 loop
			led(i) <= '1';
			end loop;
				
		end if;

	end process;
			
	
end line_tracer_code;