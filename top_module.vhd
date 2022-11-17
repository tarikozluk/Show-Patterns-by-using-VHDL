library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
entity Top_Module is
  port
  (       clk      : in std_logic;
          RED_O    : out std_logic_vector(3 downto 0);
		  GREEN_O  : out std_logic_vector(3 downto 0);
		  BLUE_O   : out std_logic_vector(3 downto 0);
		  VSYNC_O  : out std_logic;
		  HSYNC_O  : out std_logic;
		  JA       : out std_logic_vector(1 downto 1);
		  LED      : out std_logic_vector(0 downto 0)
  );
end Top_Module;

architecture Behavioral of Top_Module is

component vga_controller 
  GENERIC(
    h_pulse  : INTEGER := 208;    --horiztonal sync pulse width in pixels
    h_bp     : INTEGER := 336;    --horiztonal back porch width in pixels
    h_pixels : INTEGER := 1920;   --horiztonal display width in pixels
    h_fp     : INTEGER := 128;    --horiztonal front porch width in pixels
    h_pol    : STD_LOGIC := '0';  --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  : INTEGER := 3;      --vertical sync pulse width in rows
    v_bp     : INTEGER := 38;     --vertical back porch width in rows
    v_pixels : INTEGER := 1200;   --vertical display width in rows
    v_fp     : INTEGER := 1;      --vertical front porch width in rows
    v_pol    : STD_LOGIC := '1'); --vertical sync pulse polarity (1 = positive, 0 = negative)
  PORT(
    pixel_clk : IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    reset_n   : IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    : OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    : OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  : OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    : OUT  INTEGER;    --horizontal pixel coordinate
    row       : OUT  INTEGER;    --vertical pixel coordinate
    n_blank   : OUT  STD_LOGIC;  --direct blacking output to DAC
    n_sync    : OUT  STD_LOGIC); --sync-on-green output to DAC
END component;

 --VGA signals
 signal BLUE_O_sig,RED_O_sig,GREEN_O_sig : std_logic_vector(3 downto 0); 
 signal PIX_CLK_I : std_logic;
 signal PIX_CLK_I_COUNTER : std_logic_vector(2 downto 0);
 signal HC_out,VC_out :  integer :=0;
 
--constant  h_pulse  : integer := 96;   --horiztonal sync pulse width in pixels
--constant  h_bp     : integer := 48;    --horiztonal back porch width in pixels
--constant  h_pixels : integer := 640;   --horiztonal display width in pixels
--constant  h_fp     : integer := 16;    --horiztonal front porch width in pixels
--constant  h_pol    : std_logic := '0';  --horizontal sync pulse polarity (1 = positive, 0 = negative)
--constant  v_pulse  : integer := 2;      --vertical sync pulse width in rows
--constant  v_bp     : integer := 33;    --vertical back porch width in rows
--constant  v_pixels : integer := 480;   --vertical display width in rows
--constant  v_fp     : integer  :=10;      --vertical front porch width in rows
--constant  v_pol    : std_logic  := '0'; --vertical sync pulse polarity (1 = positive, 0 = negative)

constant  h_pulse  : integer := 44;   --horiztonal sync pulse width in pixels
constant  h_bp     : integer := 148;    --horiztonal back porch width in pixels
constant  h_pixels : integer := 1920;   --horiztonal display width in pixels
constant  h_fp     : integer := 88;    --horiztonal front porch width in pixels
constant  h_pol    : std_logic := '1';  --horizontal sync pulse polarity (1 = positive, 0 = negative)
constant  v_pulse  : integer := 5;      --vertical sync pulse width in rows
constant  v_bp     : integer := 36;    --vertical back porch width in rows
constant  v_pixels : integer := 1080;   --vertical display width in rows
constant  v_fp     : integer  :=4;      --vertical front porch width in rows
constant  v_pol    : std_logic  := '1'; --vertical sync pulse polarity (1 = positive, 0 = negative)


constant c_1024 : integer :=(1024*h_pixels)/1920;
constant c_512 : integer :=(512*h_pixels)/1920;
constant c_256 : integer :=(256*h_pixels)/1920;
constant c_128 : integer :=(128*h_pixels)/1920;
constant c_64 : integer :=(64*h_pixels)/1920;
constant c_32 : integer :=(32*h_pixels)/1920;
constant c_16 : integer :=(16*h_pixels)/1920;

constant cv_1024 : integer :=(1024*v_pixels)/1080;
constant cv_512 : integer :=(512*v_pixels)/1080;
constant cv_256 : integer :=(256*v_pixels)/1080;
constant cv_128 : integer :=(128*v_pixels)/1080;
constant cv_64 : integer :=(64*v_pixels)/1080;
constant cv_32 : integer :=(32*v_pixels)/1080;
constant cv_16 : integer :=(16*v_pixels)/1080;

signal counter : integer :=0;

type sine_array_type is array (0 to 31) of std_logic_vector(3 downto 0);
constant sine_values : sine_array_type :=
("1000","1001","1010","1100","1101","1110","1111",
"1111","1111","1111","1110","1101","1100","1011",
"1010","1000","0111","0101","0100","0011","0010",
"0001","0000","0000","0000","0000","0001","0010",
"0011","0101","0110","0111");

constant sine_index_step_h : integer :=1920/h_pixels;
constant sine_index_step_v : integer :=1920/v_pixels;

signal time_value : integer := 14850000; --148,5Mhz --- directly 1 sec
signal pattern_type_counter :  integer :=0;
signal change_pattern : std_logic :='0';


 
 
 --signal time_value : integer := 67108864;  ---less than 1 sec but almost
--signal time_value : std_logic_vector(26 downto 0) :="100000000000000000100000000";
--Pattern control signals
 --signal time_value : integer :=15000000;
--signal time_value : integer :=199900000; --almost 1 sec
 --signal pattern_type_counter : std_logic_vector(26 downto 0):=(others=>'0');
 --signal pattern_type_counter : std_logic_vector(26 downto 0):=("101111101011110000100000000");
--signal pattern_type_counter : std_logic_vector(26 downto 0):=(others=>'0');

--signal pattern_type_counter : std_logic_vector(23 downto 0):="";
 TYPE pattern_TYPE IS (p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24);
 SIGNAL pattern   : pattern_TYPE;
 
 --VGA clock generator
 component clk_wiz_0
 PORT
( clk_out1 : out std_logic;
  clk_in1  : in std_logic
 );
 end component;
 
 
begin

  clk_wiz_0_inst : clk_wiz_0
 PORT MAP
( clk_out1 =>PIX_CLK_I,
  clk_in1  =>clk
 );


vga_controller_inst: vga_controller 
  GENERIC map(
  h_pulse  => h_pulse,   --horiztonal sync pulse width in pixels
  h_bp     => h_bp,    --horiztonal back porch width in pixels
  h_pixels => h_pixels,   --horiztonal display width in pixels
  h_fp     => h_fp,    --horiztonal front porch width in pixels
  h_pol    => h_pol,  --horizontal sync pulse polarity (1 = positive, 0 = negative)
  v_pulse  => v_pulse,      --vertical sync pulse width in rows
  v_bp     => v_bp,    --vertical back porch width in rows
  v_pixels => v_pixels,   --vertical display width in rows
  v_fp     => v_fp,      --vertical front porch width in rows
  v_pol    => v_pol) --vertical sync pulse polarity (1 = positive, 0 = negative)
  PORT map(
    pixel_clk =>PIX_CLK_I,  --pixel clock at frequency of VGA mode being used
    reset_n   =>'1',  --active low asycnchronous reset
    h_sync    =>HSYNC_O,  --horiztonal sync pulse
    v_sync    =>VSYNC_O,  --vertical sync pulse
    disp_ena  =>open,  --display enable ('1' = display time, '0' = blanking time)
    column    =>HC_out,    --horizontal pixel coordinate
    row       =>VC_out ,   --vertical pixel coordinate
    n_blank   =>open,  --direct blacking output to DAC
    n_sync    =>open); --sync-on-green output to DAC

process(PIX_CLK_I)
	variable color_switch : std_logic :='0';
	variable sine_index : integer :=0;
	
	begin
	  if(rising_edge(PIX_CLK_I))then

             if(pattern=p1)then
                     if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                          RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                     else 
                       RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                     end if; 

               end if;
               
               
              if(pattern=p2)then
                      if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                           RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                      else 
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                      end if; 

               end if;   
               
               
              if(pattern=p3)then
                       if(HC_out>=0 and HC_out<=c_1024 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       elsif(HC_out>=c_1024 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                                 RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";                            
                       else 
                         RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       end if; 
                end if;     
                
                
                
              if(pattern=p4)then
                     if(HC_out>=0 and HC_out<c_512 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                          RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                     elsif(HC_out>c_512 and HC_out<=c_512+c_1024 and VC_out>=0 and VC_out <=v_pixels)then
                       RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                     elsif(HC_out>c_512+c_1024 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then
                         RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                       
                     end if; 
               end if;       
            
            
                             
              if(pattern=p5)then
                      if(HC_out>=0 and HC_out<c_256 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                           RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                      elsif(HC_out>=c_256 and HC_out<=c_256+c_512 and VC_out>=0 and VC_out <=v_pixels)then
                        RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                       elsif(HC_out>c_256+c_512 and HC_out<=c_256+c_1024 and VC_out>=0 and VC_out <=v_pixels)then
                          RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";  
                       elsif(HC_out>c_256+c_1024 and HC_out<=c_256+c_1024+c_512  and VC_out>=0 and VC_out <=v_pixels)then
                             RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";                                                   
                      elsif(HC_out>c_256+c_1024+c_512 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then
                          RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                       
                      end if; 
                end if;    
                
                
               if(pattern=p6)then
                       if(HC_out>=0 and HC_out<c_128 and VC_out>=0 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       elsif(HC_out>=c_128 and HC_out<=c_128+c_256 and VC_out>=0 and VC_out <=v_pixels)then
                         RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                       elsif(HC_out>c_128+c_256 and HC_out<=c_128+c_512 and VC_out>=0 and VC_out <=v_pixels)then
                           RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                       elsif(HC_out>c_128+c_512 and HC_out<=c_128+c_512+c_256 and VC_out>=0 and VC_out <=v_pixels)then
                            RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                       elsif(HC_out>c_128+c_512+c_256 and HC_out<=c_128+c_1024 and VC_out>=0 and VC_out <=v_pixels)then
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                       elsif(HC_out>c_128+c_1024  and HC_out<=c_128+c_1024+c_256  and VC_out>=0 and VC_out <=v_pixels)then
                              RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";
                       elsif(HC_out>c_128+c_1024+c_256 and HC_out<=c_128+c_1024+c_512 and VC_out>=0 and VC_out <=v_pixels)then
                                RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                       elsif(HC_out>c_128+c_1024+c_512  and HC_out<=h_pixels-4 and VC_out>=0 and VC_out <=v_pixels)then
                                 RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";      
                       else
                              RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                                                                                                          
                       end if; 
                 end if;    

                   if(pattern=p7)then
                        if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                          if(HC_out=0)then  -- 1-ST FACE  FIRST PIXEL
                            counter<=c_64;
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                          else
                            counter<=counter+1;  
                          end if;
                          
                          if(counter=c_128)then            
                            counter<=0;
                            RED_O_sig<=not RED_O_sig; GREEN_O_sig<=not GREEN_O_sig ; BLUE_O_sig<=not BLUE_O_sig; 
                          end if;
                        else
                           RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                        end if;
                   end if;   
            
            
            
           if(pattern=p8)then
                     if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                       if(HC_out=0)then  -- 1-ST FACE  FIRST PIXEL
                         counter<=c_32;
                         RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                       else
                         counter<=counter+1;  
                       end if;
                       
                       if(counter=c_64)then            
                         counter<=0;
                         RED_O_sig<=not RED_O_sig; GREEN_O_sig<=not GREEN_O_sig ; BLUE_O_sig<=not BLUE_O_sig; 
                       end if;
                     else
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                     end if;
           end if;    
                  
           if(pattern=p9)then
                         if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                           if(HC_out=0)then  -- 1-ST FACE  FIRST PIXEL
                             counter<=c_16;
                             RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                           else
                             counter<=counter+1;  
                           end if;
                           
                           if(counter=c_32)then            
                             counter<=0;
                             RED_O_sig<=not RED_O_sig; GREEN_O_sig<=not GREEN_O_sig ; BLUE_O_sig<=not BLUE_O_sig; 
                           end if;
                         else
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                         end if;
          end if;   
            
            
            
            
         if(pattern=p10)then
                       if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <cv_1024)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_1024 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";                            
                       else 
                         RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       end if; 
          end if; 
        
        
          if(pattern=p11)then
                       if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <cv_512)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_512 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                            RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";                            
                       else 
                         RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                       end if; 
          end if; 
        
        
           if(pattern=p12)then
                         if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <cv_256)then  -- 1-ST FACE  FIRST PIXEL
                              RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                         elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_256 and VC_out <=cv_256+cv_512)then  -- 1-ST FACE  FIRST PIXEL
                              RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";       
                         elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_256+cv_512 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                                   RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                                                 
                         else 
                           RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                         end if; 
            end if; 
                       
            if(pattern=p13)then
                        if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <cv_128)then  -- 1-ST FACE  FIRST PIXEL
                             RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                        elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_128 and VC_out <=cv_128+cv_256)then  -- 1-ST FACE  FIRST PIXEL
                             RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";       
                        elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_128+cv_256 and VC_out <=cv_128+cv_512)then  -- 1-ST FACE  FIRST PIXEL
                             RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";    
                        elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_128+cv_512 and VC_out <=cv_128+cv_512+cv_256)then  -- 1-ST FACE  FIRST PIXEL
                             RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111";    
                        elsif(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=cv_128+cv_512 and VC_out <=v_pixels)then  -- 1-ST FACE  FIRST PIXEL
                                  RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                                                                                                   
                        else 
                          RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";
                        end if; 
             end if;       
         
     
     
        if(pattern=p14)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                      if(VC_out=0)then  
                        counter<=cv_64;
                        color_switch:='0';
                      else
                        if(HC_out=h_pixels-2)then
                              counter<=counter+1;  
                         end if;
                      end if;
        
                
                      if(counter=cv_128)then            
                        counter<=0;
                        color_switch := not color_switch;
                      end if;
                      
                      if(color_switch='0')then
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                      end if;
                      if(color_switch='1')then
                         RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111"; 
                      end if;
                    else
                       RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                    end if;
            end if;    
     
     
     
     
        if(pattern=p15)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                      if(VC_out=0)then  
                        counter<=cv_32;
                        color_switch:='0';
                      else
                        if(HC_out=h_pixels-2)then
                              counter<=counter+1;  
                         end if;
                      end if;
        
                      if(counter=cv_64)then            
                        counter<=0;
                        color_switch := not color_switch;
                      end if;
                      
                      if(color_switch='0')then
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                      end if;
                      if(color_switch='1')then
                         RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111"; 
                      end if;
                    else
                       RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                    end if;
           end if;               
                       
 
        if(pattern=p16)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                      if(VC_out=0)then  
                        counter<=cv_16;
                        color_switch:='0';
                      else
                        if(HC_out=h_pixels-2)then
                              counter<=counter+1;  
                         end if;
                      end if;
        
                      if(counter=cv_32)then            
                        counter<=0;
                        color_switch := not color_switch;
                      end if;
                 
                      if(color_switch='0')then
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                      end if;
                      if(color_switch='1')then
                         RED_O_sig<="1111"; GREEN_O_sig<="1111"; BLUE_O_sig<="1111"; 
                      end if;
                    else
                       RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
                    end if;
        end if;
        
            if(pattern=p17)then
              if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                           if(HC_out=0)then  
                               sine_index:=8;
                           else
                               sine_index:=sine_index+sine_index_step_h;  
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);
               
              else
               RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
              end if;
            end if;
            
            
            if(pattern=p18)then
              if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                           if(HC_out=0)then  
                               sine_index:=16;
                           else
                               sine_index:=sine_index+sine_index_step_h;  
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);
               
              else
               RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
              end if;
            end if;
             
             
            if(pattern=p19)then
              if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                           if(HC_out=0)then  
                               sine_index:=24;
                           else
                               sine_index:=sine_index+sine_index_step_h;  
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);
               
              else
               RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
              end if;
            end if; 
                         
                         
            if(pattern=p20)then
              if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then   
                           if(HC_out=0)then  
                               sine_index:=0;
                           else
                               sine_index:=sine_index+sine_index_step_h;  
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);
               
              else
               RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000"; 
              end if;
            end if;   
            
             if(pattern=p21)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then 
                           if(VC_out=0)then  
                               sine_index:=8;
                           else
                             if(HC_out=h_pixels-2)then
                               sine_index:=sine_index+sine_index_step_h;  
                             end if;
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);  
                   else
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                
                   end if;
            end if;
            
            
            
             if(pattern=p22)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then 
                           if(VC_out=0)then  
                               sine_index:=16;
                           else
                             if(HC_out=h_pixels-2)then
                               sine_index:=sine_index+sine_index_step_h;  
                             end if;
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);  
                   else
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                
                   end if;
            end if;
            
            
             if(pattern=p23)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then 
                           if(VC_out=0)then  
                               sine_index:=24;
                           else
                             if(HC_out=h_pixels-2)then
                               sine_index:=sine_index+sine_index_step_h;  
                             end if;
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);  
                   else
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                
                   end if;
            end if;
                       
            
             if(pattern=p24)then
                    if(HC_out>=0 and HC_out<=h_pixels-2 and VC_out>=0 and VC_out <=v_pixels)then 
                           if(VC_out=0)then  
                               sine_index:=0;
                           else
                             if(HC_out=h_pixels-2)then
                               sine_index:=sine_index+sine_index_step_h;  
                             end if;
                           end if;
                             
                           if(sine_index>31)then            
                               sine_index:=0;
                           end if;
                             
                           RED_O_sig<=sine_values(sine_index);
                           GREEN_O_sig<=sine_values(sine_index);
                           BLUE_O_sig<=sine_values(sine_index);  
                   else
                        RED_O_sig<="0000"; GREEN_O_sig<="0000"; BLUE_O_sig<="0000";                
                   end if;
                   
            end if;
                                                                       
       end if;
             
	end process;
	
	

    RED_O <=RED_O_sig;-- when (HC_out>=0 and HC_out<=640 and VC_out>0 and VC_out <480) else "0000";
    GREEN_O <=GREEN_O_sig;-- when (HC_out>=0 and HC_out<=640 and VC_out>0 and VC_out <480) else "0000";
    BLUE_O <=BLUE_O_sig ;--when (HC_out>=0 and HC_out<=640 and VC_out>0 and VC_out <480) else "0000";
    
    
    
    --State Machine Which controls Pattern changing
    process(PIX_CLK_I)
    begin
        if(rising_edge(PIX_CLK_I))then
           ----------------------------- 
            pattern_type_counter<=pattern_type_counter+1; 
           
          --   pattern_type_counter<=pattern_type_counter+'1'; 
             if(pattern_type_counter=time_value)then
               ---
               ----          
               change_pattern<='1';
               pattern_type_counter <= 0;
             else
               change_pattern<='0';
             end if;
        end if;
    end process;
    
    
    

  PROCESS (PIX_CLK_I)
    BEGIN
       if(PIX_CLK_I'EVENT AND PIX_CLK_I = '1') THEN
             
          CASE pattern IS
         WHEN p1=>
            
            IF change_pattern = '1' THEN
            
               pattern <= p2;
               
            ELSE
               pattern <= p1;
               
            END IF;
         WHEN p2=>
             
             IF change_pattern = '1' THEN
                pattern <= p3;
             ELSE
                pattern <= p2;
             END IF;                            
         WHEN p3=>
              IF change_pattern = '1' THEN
                pattern <= p4;
              ELSE
                pattern <= p3;
              END IF;
         WHEN p4=>
              IF change_pattern = '1' THEN
                pattern <= p5;
              ELSE
                pattern <= p4;
              END IF;                            
 
          WHEN p5=>
                 IF change_pattern = '1' THEN
                    pattern <= p6;
                 ELSE
                    pattern <= p5;
                 END IF;
      
           WHEN p6=>
                  IF change_pattern = '1' THEN
                     pattern <= p7;
                  ELSE
                     pattern <= p6;
                  END IF;                            
      
          WHEN p7=>
                   IF change_pattern = '1' THEN
                     pattern <= p8;
                   ELSE
                     pattern <= p7;
                   END IF;
  
         WHEN p8=>
                   IF change_pattern = '1' THEN
                     pattern <= p9;
                   ELSE
                     pattern <= p8;
                   END IF;                            
          WHEN p9=>
              IF change_pattern = '1' THEN
                 pattern <= p10;
              ELSE
                 pattern <= p9;
              END IF;

           WHEN p10=>
               IF change_pattern = '1' THEN
                  pattern <= p11;
               ELSE
                  pattern <= p10;
               END IF;                            
        
           WHEN p11=>
                IF change_pattern = '1' THEN
                  pattern <= p12;
                ELSE
                  pattern <= p11;
                END IF;
        
          WHEN p12=>
                IF change_pattern = '1' THEN
                  pattern <= p13;
                ELSE
                  pattern <= p12;
                END IF;                            

          WHEN p13=>
               IF change_pattern = '1' THEN
                  pattern <= p14;
               ELSE
                  pattern <= p13;
               END IF;

            WHEN p14=>
                IF change_pattern = '1' THEN
                   pattern <= p15;
                ELSE
                   pattern <= p14;
                END IF;                            

            WHEN p15=>
                 IF change_pattern = '1' THEN
                   pattern <= p16;
                 ELSE
                   pattern <= p15;
                 END IF;

            WHEN p16=>
                 IF change_pattern = '1' THEN
                   pattern <= p17;
                 ELSE
                   pattern <= p16;
                 END IF;
                                 
            WHEN p17=>
                IF change_pattern = '1' THEN
                   pattern <= p18;
                ELSE
                   pattern <= p17;
                END IF;

            WHEN p18=>
                 IF change_pattern = '1' THEN
                    pattern <= p19;
                 ELSE
                    pattern <= p18;
                 END IF;                            

            WHEN p19=>
                  IF change_pattern = '1' THEN
                    pattern <= p20;
                  ELSE
                    pattern <= p19;
                  END IF;

            WHEN p20=>
                  IF change_pattern = '1' THEN
                    pattern <= p21;
                  ELSE
                    pattern <= p20;
                  END IF;                            

            WHEN p21=>
                 IF change_pattern = '1' THEN
                    pattern <= p22;
                 ELSE
                    pattern <= p21;
                 END IF;

             WHEN p22=>
                  IF change_pattern = '1' THEN
                     pattern <= p23;
                  ELSE
                     pattern <= p22;
                  END IF;                            

            WHEN p23=>
                   IF change_pattern = '1' THEN
                     pattern <= p24;
                   ELSE
                     pattern <= p23;
                   END IF;

           WHEN p24=>
               IF change_pattern = '1' THEN
                 pattern <= p1;
               ELSE
                 pattern <= p24;
               END IF;                                                                                
   END CASE;
       END IF;
    END PROCESS;  
--JA(1 downto 1) <= pattern_type_counter(22 downto 22);
--LED <= std_logic_vector(pattern_type_counter(22 downto 22));
end Behavioral;

