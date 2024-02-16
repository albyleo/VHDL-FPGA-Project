----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alberto Leo
-- 
-- Create Date: 14.05.2023 00:24:01
-- Design Name: 
-- Module Name: reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------






library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;


entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_w : in std_logic;
o_z0 : out std_logic_vector(7 downto 0);
o_z1 : out std_logic_vector(7 downto 0);
o_z2 : out std_logic_vector(7 downto 0);
o_z3 : out std_logic_vector(7 downto 0);
o_done : out std_logic;																 
o_mem_addr : out std_logic_vector(15 downto 0);
i_mem_data : in std_logic_vector(7 downto 0);
o_mem_we : out std_logic;
o_mem_en : out std_logic
);
end project_reti_logiche;

   
   
architecture Behavioral of project_reti_logiche is
   
   
   -- Types e Constanti
    type state_type is (WAIT_START, HEADER1, READ_ADDR, WRITE_DATA, WAITING); 

    -- Segnali
    
    signal state : state_type;
    signal header : std_logic_vector(1 downto 0);		 
   -- signal addr : std_logic_vector(15 downto 0);
    --signal mem_data : std_logic_vector(7 downto 0);
    --signal mem_write : std_logic;
    
      function reverse(in_vect:std_logic_vector(15 downto 0))
	return std_logic_vector is	
	variable inverti :std_logic_vector(15 downto 0);
	begin
		
		inverti(0):=in_vect(15);
		inverti(1):=in_vect(14); 
		inverti(2):=in_vect(13);
		inverti(3):=in_vect(12);	 
		inverti(4):=in_vect(11);
		inverti(5):=in_vect(10); 
		inverti(6):=in_vect(9);
		inverti(7):=in_vect(8);  
		inverti(8):=in_vect(7);
		inverti(9):=in_vect(6);	 
		inverti(10):=in_vect(5);  
        inverti(11):=in_vect(4);
		inverti(12):=in_vect(3);	
		inverti(13):=in_vect(2);  
		inverti(14):=in_vect(1);
		inverti(15):=in_vect(0);
		
		
		return inverti;
		
		
    end function;
    
    
    
    
    
    
    
    
  begin
    
     process(i_clk, i_rst)
    
    --variabili
	 variable shift_reg:std_logic_vector(15 downto 0);	
	 variable counter : integer range 0 to 15 := 0;	
	 variable tmp : integer := 0;  
	 variable tmp_vect:std_logic_vector(0 to 15);
     variable z0:std_logic_vector(7 downto 0):="00000000";
     variable z1:std_logic_vector(7 downto 0):="00000000";
     variable z2:std_logic_vector(7 downto 0):="00000000";
     variable z3:std_logic_vector(7 downto 0):="00000000";
    
    begin
     
        if i_rst = '1' then
            -- Reset signals and variables
            state <= WAIT_START;                     --faccio in modo solo se prendo il primo reset=1 posso poi andare nel caso WAIT_START dove ci sarà il primo start=1
            o_mem_addr <= (others => '0');
            o_z0 <= (others => '0');
            o_z1 <= (others => '0');
            o_z2 <= (others => '0');
            o_z3 <= (others => '0');
            o_done <= '0';
 
          elsif i_clk'event and i_clk='1' then     --acquisisco sul di salita del clock, potevo anche usare il rising_edge
             o_mem_en<='1';                        --abilito lettura
			 o_mem_we<='0';   
            
             case state is
               when WAIT_START =>               -- il WAIT_START è il primo stato, mi assicuro che qui ci sia il segnale o_done basso ed inializzo a zero le uscite 
                   
                   o_done<='0';	            
					 
					  o_z0 <= (others => '0');
                      o_z1 <= (others => '0');
                      o_z2 <= (others => '0');
                      o_z3 <= (others => '0');
                      
                    if i_start = '1' then        --start=1 inizio a prendere i primi due bit che metterò nel vettore header che poi utilizzerò per scrivere nelgiusto canale d uscita
                        header(1) <= i_w;
                        state <= HEADER1;
					 
					  
                        end if;
                      
                      
                when HEADER1 =>	  
				
					if i_start='1' then
                    header(0) <=i_w;
                    state <= READ_ADDR;	           -- completo la lettura del canale d uscita salvandolo in header(), e passo allo stato di lettura dell indirizzo di mem 
					end if;

                      
                when READ_ADDR =>
                  if i_start = '1' then
               
				  --tmp_vect(counter):=i_w;
				  shift_reg(counter):=i_w;
				  counter := counter+1;	  
				  
                  state <= READ_ADDR;
					
				 elsif i_start='0' then	  
					 --shift_reg(counter-1 downto 0):=tmp_vect(0 to counter-1);    --non uso più loop o funzioni col 'downto' o 'to' perchè non sintetizzabili in vivado perciò ho implementato una funzione 'reverse' che ha il compito di invertire la stringa e leggere bene da i_w l indirizzo di memoria. 
					 --shift_reg(15 downto (counter)):=(others =>'0');             
					 shift_reg:=reverse(shift_reg);
					 shift_reg(15-counter downto 0):=(others =>'0');                --completo l indirrizzo con gli 0 necessari
					 tmp:=15-counter;
					 counter:=15;                  
                
                 end if;
				  -- o_mem_addr<=shift_reg;
				  o_mem_addr<=std_logic_vector(unsigned(shift_reg) srl tmp+1);
				   
				   
				   
				   if counter=15 then
				   
				      state<=WAITING; 
					  counter:=0;
				    end if;
				   
				  when WAITING =>               --Stato di wait per dar tempo di aggiornare
				    
				     state <=WRITE_DATA;
				    
				  
				  when WRITE_DATA =>              -- ultimo stato in cui o_done è alto e posso così scrivere nell uscita, mi assicuro anche di salvare le uscite nelle rispettive variabili così da evitare di perdere i dati quando le reinializzo a zero in WAIT_START ovvero qundo o_done è basso
				    
				     o_done<='1';	
					 
					  o_z0 <= z0;
                      o_z1 <= z1;
                      o_z2 <= z2;
                      o_z3 <= z3; 
					
					 if header="00" then 
					  o_z0<=i_mem_data;
					  z0:=i_mem_data;
					    end if;		
					 if header="01" then 
					  o_z1<=i_mem_data;
					  z1:=i_mem_data;
					    end if;
					 if header="10" then 
					  o_z2<=i_mem_data;
					  z2:=i_mem_data;
					    end if;
					 if header="11" then 
					  o_z3<=i_mem_data;
					  z3:=i_mem_data;
					    end if;		
				  
				   
				  state<=WAIT_START;
				  
				   
                end case;    
				  			                									  			                                          											 		                    
                                  
           end if;
     
     end process;

end Behavioral;