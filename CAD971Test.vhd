library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CAD971Test is
	Port(
		--//////////// CLOCK //////////
		CLOCK_24 	: in std_logic;
		
		--//////////// KEY //////////
		RESET_N	: in std_logic;
		key : in std_logic_vector(3 downto 0);
		sw  : in std_logic_vector(7 downto 0);
		
		
		--//////////// VGA //////////
		VGA_B		: out std_logic_vector(1 downto 0);
		VGA_G		: out std_logic_vector(1 downto 0);
		VGA_HS	: out std_logic;
		VGA_R		: out std_logic_vector(1 downto 0);
		VGA_VS	: out std_logic;
		
		
			--//////////// 7SEG //////////
		sseg : out std_logic_vector(7 downto 0);
		an   : out std_logic_vector(3 downto 0)
	);
end CAD971Test;




--}} End of automatically maintained section

architecture CAD971Test of CAD971Test is

Component VGA_controller
	port ( CLK_24MHz		: in std_logic;
         VS					: out std_logic;
			HS					: out std_logic;
			RED				: out std_logic_vector(1 downto 0);
			GREEN				: out std_logic_vector(1 downto 0);
			BLUE				: out std_logic_vector(1 downto 0);
			RESET				: in std_logic;
			ColorIN			: in std_logic_vector(5 downto 0);
			ScanlineX		: out std_logic_vector(10 downto 0);
			ScanlineY		: out std_logic_vector(10 downto 0)
  );
end component;

Component VGA_Square
	port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			key            : in std_logic_vector(3 downto 0);
			sw             : in std_logic_vector(7 downto 0);
			a              : out std_logic_vector(3 downto 0);
			b              : out std_logic_vector(3 downto 0);
			c              : out std_logic_vector(3 downto 0);
			d              : out std_logic_vector(3 downto 0)
  );
end component;


function sevensegment(input : in std_logic_vector) return std_logic_vector is
	variable output : std_logic_vector(7 downto 0);
begin
	if input = "0000" then output :=x"c0";
	elsif input = "0001" then output :=x"f9";
	elsif input = "0010" then output :=x"a4";
	elsif input = "0011" then output :=x"b0";
	elsif input = "0100" then output :=x"99";
	elsif input = "0101" then output :=x"92";
	elsif input = "0110" then output :=x"82";
	elsif input = "0111" then output :=x"f8";
	elsif input = "1000" then output :=x"80";
	elsif input = "1001" then output :=x"98";
	else output :="11000000";
	end if;
	return output;
end function sevensegment;

signal ScanlineX,ScanlineY	: std_logic_vector(10 downto 0);
signal ColorTable	: std_logic_vector(5 downto 0);
signal a :  std_logic_vector(3 downto 0) := "0010";
signal b :  std_logic_vector(3 downto 0) := "1000";
signal c :  std_logic_vector(3 downto 0) := "0010";
signal d :  std_logic_vector(3 downto 0) := "0001";
signal sel : std_logic_vector(3 downto 0) := "1110";


begin

	 --------- VGA Controller -----------
	 VGA_Control: vga_controller
			port map(
				CLK_24MHz	=> CLOCK_24,
				VS				=> VGA_VS,
				HS				=> VGA_HS,
				RED			=> VGA_R,
				GREEN			=> VGA_G,
				BLUE			=> VGA_B,
				RESET			=> not RESET_N,
				ColorIN		=> ColorTable,
				ScanlineX	=> ScanlineX,
				ScanlineY	=> ScanlineY
			);
		
		--------- Moving Square -----------
		VGA_SQ: VGA_Square
			port map(
				CLK_24MHz		=> CLOCK_24,
				RESET				=> not RESET_N,
				ColorOut			=> ColorTable,
				SQUAREWIDTH		=> "00011001",
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY,
				key            => key,
				sw             => sw,
				a              => a,
				b              => b,
				c              => c,
				d              => d
			);
			
			
			
			process (CLOCK_24)
	variable count : integer range 0 to 5000 := 0;
begin
	if rising_edge(CLOCK_24) then
		count := count + 1;
		if count >= 4999 then
		count := 0;
		sel <= sel(0) & sel(3 downto 1);
		end if;
	end if;
end process;


process(a,b,c,d,sel)
begin
	case sel is
		when "1110" => sseg <= sevensegment(d);
		when "1101" => sseg <= sevensegment(c);
		when "1011" => sseg <= sevensegment(b);
		when others => sseg <= sevensegment(a);
	end case;
end process;
			
 an <= std_logic_vector(sel);	

	 

	 
end CAD971Test;
