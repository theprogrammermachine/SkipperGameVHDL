
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity VGA_Square is
  port ( CLK_24MHz      : in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			key : in std_logic_vector(3 downto 0);
			sw  : in std_logic_vector(7 downto 0);
			a   : out std_logic_vector(3 downto 0);
			b   : out std_logic_vector(3 downto 0);
			c   : out std_logic_vector(3 downto 0);
			d   : out std_logic_vector(3 downto 0)
  );
end VGA_Square;

architecture Behavioral of VGA_Square is

  constant doorDistance : std_logic_vector(10 downto 0) := "00100101100"; -- 300
  constant doorWidth : std_logic_vector(10 downto 0) := "00000011001";
  constant doorHeight : std_logic_vector(10 downto 0) := "00011001000";
  
  signal ColorOutput : std_logic_vector(5 downto 0);
  
  signal screenWidth : std_logic_vector(10 downto 0); -- := "1010000000"-SquareWidth;
  signal screenHeight : std_logic_vector(10 downto 0); -- := "0111100000"-SquareWidth;
  signal squareX : std_logic_vector(10 downto 0);
  signal squareY : std_logic_vector(10 downto 0);
  signal doorXArr : std_logic_vector(43 downto 0) := (others => '0');
  signal doorXArrTempG : std_logic_vector(43 downto 0) := (others => '0');
  signal doorYArr : std_logic_vector(43 downto 0) := (others => '0');
  signal doorYArrTempG : std_logic_vector(43 downto 0) := (others => '0');
  signal passedFlags : std_logic_vector(3 downto 0) := (others => '0');
  
  constant prescalerLimit : std_logic_vector(29 downto 0) := "000000000000101101110001101100";
  constant prescalerv2Limit : std_logic_vector(29 downto 0) := "000000000000000000011110000000";
                                                               
  signal prescaler : std_logic_vector(29 downto 0) := (others => '0');
  signal prescalerv2 : std_logic_vector(29 downto 0) := (others => '0');
  signal prescalerv3 : std_logic_vector(29 downto 0) := (others => '0');
  signal prescalerv4 : std_logic_vector(29 downto 0) := (others => '0');
  signal prescalerv5 : std_logic_vector(29 downto 0) := (others => '0');
  signal prescalerv6 : std_logic_vector(29 downto 0) := (others => '0');
  
  signal score : std_logic_vector(3 downto 0) := (others => '0');
  signal score2: std_logic_vector(3 downto 0) := (others => '0');
  
  signal speed : std_logic_vector(10 downto 0) := "00000000001";
  signal squareSpeed : std_logic_vector(10 downto 0) := "00000000000";
  signal squareSpeedSign : std_logic := '0';
  
  type GameStates is (gameFinished, gameReseted, gamePlaying);
  signal state : GameStates := gameReseted;
  
  signal psuedo_rand : std_logic_vector(31 downto 0) := "01010101001010010010100010101001";
  
  signal passedX : std_logic_vector(15 downto 0) := (others => '0');
  
  signal secondDigit : std_logic_vector(3 downto 0) := (others => '0');
  signal firstDigit : std_logic_vector(3 downto 0) := (others => '0');
  
  signal finalScore : std_logic_vector(3 downto 0) := (others => '0');
  signal finalScore2 : std_logic_vector(3 downto 0) := (others => '0');
  
begin

   a <= firstDigit when (state = gamePlaying or state = gameFinished) else "1000";
	b <= secondDigit when (state = gamePlaying or state = gameFinished) else "0001";
	c <= score when (state = gamePlaying or state = gameFinished) else "0100";
	d <= score2 when (state = gamePlaying or state = gameFinished) else "0001";

	process(RESET, CLK_24MHz)
	variable doorsArrTempX : std_logic_vector(43 downto 0);
	variable doorsArrTempY : std_logic_vector(43 downto 0);
	begin
	 
	 if RESET = '1' then    
	 
	   squareX <= "00010010110"; -- 150
      squareY <= "00011100001"; -- 225
		  
   	doorsArrTempX(43 downto 33) := "01001011000"; -- 600
		doorsArrTempX(32 downto 22) := doorsArrTempX(43 downto 33) + doorDistance; -- 900
		doorsArrTempX(21 downto 11) := doorsArrTempX(32 downto 22) + doorDistance; -- 1200
		doorsArrTempX(10 downto 0) := doorsArrTempX(21 downto 11) + doorDistance; -- 1500
		doorXArrTempG <= doorsArrTempX;

		doorsArrTempY(43 downto 33) := "00011001000"; -- 200		  
		doorsArrTempY(32 downto 22) := "00011001000"; -- 200
		doorsArrTempY(21 downto 11) := "00011001000"; -- 400
		doorsArrTempY(10 downto 0) := "00011001000"; -- 300
	   doorYArrTempG <= doorsArrTempY;
		
		passedX <= (others => '0');
		
		speed <= "00000000001";
		prescaler <= (others => '0');
		prescalerv2 <= (others => '0');
		prescalerv4 <= (others => '0');
		
		firstDigit <= (others => '0');
		secondDigit <= (others => '0');
		
		score <= (others => '0');
		score2 <= (others => '0');
		
	 elsif CLK_24MHz'event and CLK_24MHz = '1' then
	   
		if state = gamePlaying then
		
		prescaler <= prescaler + 1;
			
		if prescaler >= prescalerLimit then
		
		  if squareSpeedSign = '0' then
		    if squareY <= 470 then
			   squareY <= squareY + squareSpeed;
			 end if;
		  elsif squareSpeedSign = '1' then
		    if squareY >= 10 then
			   squareY <= squareY - squareSpeed;
			 end if;
		  end if;		  
		  
		  if prescalerv2 >= prescalerv2Limit then
			 speed <= speed + 1;
			 prescalerv2 <= (others => '0');
		  else
		    prescalerv2 <= prescalerv2 + 1;
		  end if;
		  
		  if prescalerv4 >= 128 then
		    if firstDigit >= 9 then
			   firstDigit <= (others => '0');
				secondDigit <= secondDigit + 1;
			 else
			   firstDigit <= firstDigit + 1;
			 end if;
			 prescalerv4 <= (others => '0');
		  else
		    prescalerv4 <= prescalerv4 + 1;
		  end if;
		  
        if doorXArr(43 downto 33) <= 10 then
		    doorXArrTempG(43 downto 33) <= "10010110000";
			 doorYArrTempG(43 downto 33) <= "000" & psuedo_rand(31 downto 24);     
          passedFlags(3) <= '0';			 
		  elsif doorXArr(43 downto 33) < squareX then
		    if passedFlags(3) = '0' then
			   if score >= 9 then
			     if score2 = 0 then
                score2 <= score2 + 1;
				    score <= (others => '0');
				  end if;
            else		
              if score2 = 0 then			 
		          score <= score + 1;
				  end if;
			   end if;
				passedFlags(3) <= '1';
			 end if;
			 doorXArrTempG(43 downto 33) <= doorXArr(43 downto 33) - speed;		    
		  else
  		    doorXArrTempG(43 downto 33) <= doorXArr(43 downto 33) - speed;		    
		  end if;
		  
		  if doorXArr(32 downto 22) <= 10 then
		    doorXArrTempG(32 downto 22) <= "10010110000"; --doorXArr(21 downto 11) + doorDistance;
			 doorYArrTempG(32 downto 22) <= "000" & psuedo_rand(23 downto 16);          
		    passedFlags(2) <= '0';
		  elsif doorXArr(32 downto 22) < squareX then
		    if passedFlags(2) = '0' then
			   if score >= 9 then
			     if score2 = 0 then
                score2 <= score2 + 1;
				    score <= (others => '0');
				  end if;
            else		
              if score2 = 0 then			 
		          score <= score + 1;
				  end if;
			   end if;
				passedFlags(2) <= '1';
			 end if;
			 doorXArrTempG(32 downto 22) <= doorXArr(32 downto 22) - speed;
		  else
		    doorXArrTempG(32 downto 22) <= doorXArr(32 downto 22) - speed;		    
		  end if;
		  
		  if doorXArr(21 downto 11) <= 10 then
		    doorXArrTempG(21 downto 11) <= "10010110000"; --doorXArr(10 downto 0) + doorDistance;
			 doorYArrTempG(21 downto 11) <= "000" & psuedo_rand(15 downto 8);          
		    passedFlags(1) <= '0';
		  elsif doorXArr(21 downto 11) < squareX then
		    if passedFlags(1) = '0' then
			   if score >= 9 then
			     if score2 = 0 then
                score2 <= score2 + 1;
				    score <= (others => '0');
				  end if;
            else		
              if score2 = 0 then			 
		          score <= score + 1;
				  end if;
			   end if;
				passedFlags(1) <= '1';
			 end if;
			 doorXArrTempG(21 downto 11) <= doorXArr(21 downto 11) - speed;
		  else
		    doorXArrTempG(21 downto 11) <= doorXArr(21 downto 11) - speed;  
		  end if;
		  
		  if doorXArr(10 downto 0) <= 10 then
		    doorXArrTempG(10 downto 0) <= "10010110000"; --doorXArr(43 downto 33) + doorDistance;
			 doorYArrTempG(10 downto 0) <= "000" & psuedo_rand(7 downto 0);          
		    passedFlags(0) <= '0';
		  elsif doorXArr(10 downto 0) < squareX then
		    if passedFlags(0) = '0' then
			   if score >= 9 then
			     if score2 = 0 then
                score2 <= score2 + 1;
				    score <= (others => '0');
				  end if;
            else		
              if score2 = 0 then			 
		          score <= score + 1;
				  end if;
			   end if;
				passedFlags(0) <= '1';
			 end if;
			 doorXArrTempG(10 downto 0) <= doorXArr(10 downto 0) - speed;
		  else
		    doorXArrTempG(10 downto 0) <= doorXArr(10 downto 0) - speed;
		  end if;
		  
		  passedX <= passedX + speed;
		  
    	  prescaler <= (others => '0');
		
		end if;
		end if;
		  
	 end if;
	 
	end process;
		
	process (CLK_24MHZ, RESET, key)
	variable flag : std_logic := '0';
	variable counterHolder : integer;
	variable xHolder : std_logic_vector(10 downto 0);
	begin
	  if RESET = '1' then
	    squareSpeed <= "00000000000";
		 squareSpeedSign <= '0';
		 prescalerv3 <= (others => '0');
		 prescalerv6 <= (others => '0');
	    state <= gameReseted;
	  elsif CLK_24MHZ'event and CLK_24MHZ = '1' then
	    flag := '0';
	    for counter in 1 to 4 loop
		    if ((((squareX <= (doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorWidth)) and (squareX >= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)))) or
				  ((squareX + squareWidth) >= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) and (squareX + squareWidth) <= (doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorWidth)) or
				  ((squareX <= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1))) and ((squareX + squareWidth) >= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)))) or
				  (squareX <= (doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorWidth) and ((squareX + squareWidth) >= (doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorWidth))))
				  and
				  (((squareY <= doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1))) and ((squareY + squareWidth) >= doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)))) or
				  ((squareY <= (doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorHeight)) and ((squareY + squareWidth) >= (doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorHeight))) or
				  (squareY >= (doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorHeight)) or
				  ((squareY + squareWidth) <= doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1))))) then
           if doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) > 10 and doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) < 900 then 
		  	    state <= gameFinished;
				 flag := '1';
			  end if;
         elsif score2 > 0 then
			  state <= gameFinished;
			  flag := '1';
	    	end if;
		 end loop;
		 if flag = '0' then
		   if prescalerv6 < 8000000 then		
		     prescalerv6 <= prescalerv6 + 1;
			end if;
		   if sw(0) = '0' then
			  for counter in 1 to 4 loop
			    if counter = 1 then
				   counterHolder := counter;
					xHolder := doorXArr(10 downto 0);
				 else
				   if squareX < doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) and
					   doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) < xHolder then
						xHolder := doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1));
						counterHolder := counter;
				   end if;
				 end if;
			  end loop;
			  if squareY >= doorYArr(((counterHolder * 11) - 1) downto (((counterHolder - 1) * 10) + counterHolder - 1)) + 100 then	  	  
			    if prescalerv6 >= 8000000 then
				   squareSpeed <= "00000000010";
		         squareSpeedSign <= '1';
			      prescalerv6 <= (others => '0');
			      if state = gameReseted then
			        state <= gamePlaying;
			      end if;
			    end if;
			  end if;
			else
			  if key(0) = '0' and prescalerv6 >= 8000000 then
	          squareSpeed <= "00000000010";
		       squareSpeedSign <= '1';
			    prescalerv6 <= (others => '0');
			    if state = gameReseted then
			      state <= gamePlaying;
			    end if;
		     end if;
			end if;	
		   if prescalerv3 >= 3000000 then
		     if squareSpeed > 0 and squareSpeedSign = '0' then
			    if squareSpeed < 3 then
				   squareSpeed <= squareSpeed + 1;
				 end if;
			  elsif squareSpeed > 0 and squareSpeedSign = '1' then
			    squareSpeed <= squareSpeed - 1;
 			  elsif squareSpeed = 0 then
			    squareSpeed <= squareSpeed + 1;
				 squareSpeedSign <= '0';
			  end if;
			  prescalerv3 <= (others => '0');
			else
		     prescalerv3 <= prescalerv3 + 1;
			end if;  
		 end if;
	  end if;
	end process;	
   
	process (CLK_24Mhz, doorXArrTempG, doorYArrTempG)
	begin
	  if CLK_24MHz'event and CLK_24MHz = '1' then
	    doorXArr <= doorXArrTempG;
	    doorYArr <= doorYArrTempG;
	  end if;
	end process;
	
	process(CLK_24MHz)   -- maximal length 32-bit xnor LFSR   
	  function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is   
	  begin     
	    return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));   
	  end function; 
	begin   
	  if rising_edge(CLK_24MHz) then     
	    if reset='1' then       
		   psuedo_rand <= (others => '0');     
		 else       
		   psuedo_rand <= lfsr32(psuedo_rand);     
		 end if;   
	  end if;
	end process;
	
	process (doorXArr, doorYArr, squareX, squareY)
     variable flag : std_logic := '0';
	begin
	  flag := '0';
	  for counter in 1 to 4 loop
	    if ((ScanlineX >= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) and ScanlineX <= doorXArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorWidth) and (ScanlineY <= doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) or (ScanlineY >= doorYArr(((counter * 11) - 1) downto (((counter - 1) * 10) + counter - 1)) + doorHeight))) then
		   if ScanlineX > 10 and ScanlineX < 900 then
			  flag := '1';
			end if;
		 end if;
	  end loop;
	  if flag = '0' then
	    if ScanlineX >= squareX and ScanlineY >= squareY and ScanlineX <= squareX + squareWidth and ScanlineY <= squareY + squareWidth then
	      ColorOutput <= "000011";
       else
		   ColorOutput <= "111111";
		 end if;
     else
       ColorOutput <= "001100";
	  end if;
   end process;
	
	ColorOut <= ColorOutput;
	
	--screenWidth <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	--screenHeight <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)

end Behavioral;

