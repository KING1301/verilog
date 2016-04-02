`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:18:32 07/21/2015 
// Design Name: 
// Module Name:    WASHER 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////display /////////////////////////////////////
module Divider(CLK,CLK_1,CLK_250);
output CLK_1, CLK_250;
reg CLK_1=0;
reg CLK_250=0;
input CLK;
reg [25:0] cn=0;
reg [18:0] cn1=0;

always @(posedge CLK)
	begin
	if(cn== 24999999) //1s
		  begin
		    cn<=0;
		    CLK_1<=~CLK_1;
		   end
	  else
		cn<=cn+1;
	end
	
always @(posedge CLK)
	begin
	  if(cn1==99999)
		  begin
		    cn1<=0;
		    CLK_250<=~CLK_250;
		    end
	  else
		cn1<=cn1+1;
	end
	

endmodule

module Decoding(q_count,q_out);
input[3:0] q_count;
output reg [7:0] q_out;
always @(q_count) 
begin
		case(q_count)		
		4'b0000:q_out <= 8'b00000011;
		4'b0001:q_out <= 8'b10011111;
		4'b0010:q_out <= 8'b00100101;
		4'b0011:q_out <= 8'b00001101;
		4'b0100:q_out <= 8'b10011001;
		4'b0101:q_out <= 8'b01001001;
		4'b0110:q_out <= 8'b01000001;
		4'b0111:q_out <= 8'b00011011;
		4'b1000:q_out <= 8'b00000001;
		4'b1001:q_out <= 8'b00001001;
		default:q_out <= 8'b00000011;
		endcase
end
endmodule

module dtsm(CLK_250, A_TIME1,A_TIME2, TIME1,TIME2,display,WATER1,WATER2, q_ctl, q_out);
input CLK_250,display;
input[3:0] A_TIME1,A_TIME2,TIME1,TIME2,WATER1,WATER2;
output reg [3:0] q_ctl=4'b1110;
output [7:0] q_out;
reg[3:0] q_count=0;
always @(posedge CLK_250) 
begin		
	case(q_ctl)
	 4'b1110:
	   begin
			 q_count <= A_TIME2;
			 q_ctl <= 4'b1101;
		 end
	 4'b1101:
	   begin
			 if(display==1)
			   q_count <= WATER1;
			 else
				 q_count <= TIME1;
				 q_ctl <= 4'b1011;
		 end
	4'b1011:
	  begin
			if(display==1)
			  q_count <= WATER2;
			else
				q_count <= TIME2;
				q_ctl <= 4'b0111;
		end
	4'b0111:
	  begin
			q_count <= A_TIME1;
			q_ctl <= 4'b1110;
		end
	default:
		begin
		  q_count <= A_TIME1;
			q_ctl <= 4'b1110;
		end  
  endcase		
end	

Decoding t(q_count, q_out);
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////

module CONTROL(POWER,STOP,SR,SP,ST,finish,CLOSE);//SR:POWER SP:PAUSE ST:start
input POWER,STOP,finish,CLOSE;
output reg SP=1,ST=0;
output SR;
assign SR=~POWER|CLOSE;

always @(posedge STOP or posedge finish or posedge SR)  //PAUSE
begin
  if(SR)
    begin
	   ST<=0;
      SP<=1; 
    end
  else if(finish)
	 begin
	  ST<=0;
     SP<=1;
	 end
	 else
	 begin
	  ST<=1;
     SP<=~SP; 
	 end
end
endmodule

module COUNT(CLK_1,MODE,SET,SR,SP,ST,STATE,A_TIME1,A_TIME2,TIME1,TIME2,finish,LED_in,LED_out);
input CLK_1,SR,SP,ST,SET;
input[2:0] MODE; 
output finish,LED_in,LED_out;

output reg [1:0] STATE=2'b00;
output reg [3:0] A_TIME1 = 4'd3,A_TIME2 = 4'd3, TIME1 = 4'd1,TIME2 = 4'd2;
reg [3:0] TIME3 = 4'd0;
reg [3:0] TIME4 = 4'd0;
wire OK;

assign LED_in=(~SR&&ST)&&((STATE==2'b00&&TIME1==1)|(STATE==2'b01&&TIME1==4'b0000&&TIME2>4'b0110));
//assign LED_in=(~SR&&~SP)&&((STATE==2'b00&&TIME1==1)|(STATE==2'b01&&TIME1==4'b0000&&TIME2>4'b0110));
assign LED_out=(~SR&&ST)&&((STATE==2'b01&&TIME1==1)|(STATE==2'b10));
//assign LED_out=(~SR&&~SP)&&((STATE==2'b01&&TIME1==1)|(STATE==2'b10));
assign finish=(A_TIME1==0&&A_TIME2==0&&TIME1==0&&TIME2==0);
assign OK=(TIME1==0&&TIME2==0);
wire CLR=SR|finish;
always @(posedge SP or posedge CLK_1 or posedge CLR )
begin
  if(CLR==1)
    begin
	 STATE<=2'b00;
	 A_TIME1 <= 4'd3;
    A_TIME2 <= 4'd3;
	 TIME1 <= 4'd1;
    TIME2 <= 4'd2;
    TIME3 <= 4'd0;
    TIME4 <= 4'd0;	
    end	
  else if(SP==1)
   begin
	if(SET)
	begin
     case(MODE)		
       3'b000:
		     begin
					STATE<=2'b00;
					A_TIME1 <= 4'd3;
					A_TIME2 <= 4'd3;
					TIME1 <= 4'd1;
					TIME2 <= 4'd2;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;
		     end
       3'b001:
		     begin
					STATE<=2'b00;
					A_TIME1 <= 4'd1;
					A_TIME2 <= 4'd2;
					TIME1 <= 4'd1;
					TIME2 <= 4'd2;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;		 
		     end
       3'b010:
		     begin
					STATE<=2'b00;
					A_TIME1 <= 4'd2;
					A_TIME2 <= 4'd7;
					TIME1 <= 4'd1;
					TIME2 <= 4'd2;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;		 
		     end
       3'b011:
		     begin
					STATE<=2'b01;
					A_TIME1 <= 4'd1;
					A_TIME2 <= 4'd5;
					TIME1 <= 4'd1;
					TIME2 <= 4'd5;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;		 
		     end
       3'b100:
		     begin
					STATE<=2'b01;
					A_TIME1 <= 4'd2;
					A_TIME2 <= 4'd1;
					TIME1 <= 4'd1;
					TIME2 <= 4'd5;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;		 
		     end
       3'b101:
		     begin
					STATE<=2'b10;
					A_TIME1 <= 4'd0;
					A_TIME2 <= 4'd6;
					TIME1 <= 4'd0;
					TIME2 <= 4'd6;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;		 
         end		
       default:
         begin
					STATE<=2'b00;
					A_TIME1 <= 4'd3;
					A_TIME2 <= 4'd3;
					TIME1 <= 4'd1;
					TIME2 <= 4'd2;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;
         end
	endcase
	end	 

  end
  else if(OK==1)
    begin
	  case(STATE)
		2'b00:
		   begin
					STATE<=2'b01;
					TIME1 <= 4'd1;
					TIME2 <= 4'd5;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;	
		    end
		2'b01:
			begin
					STATE<=2'b10;
					TIME1 <= 4'd0;
               TIME2 <= 4'd6;
               TIME3 <= 4'd0;
               TIME4 <= 4'd0;
			end
		default:
			begin
					STATE<=2'b00;
	            TIME1 <= 4'd1;
					TIME2 <= 4'd2;
					TIME3 <= 4'd0;
					TIME4 <= 4'd0;	
			end
	    endcase
	end
  else
    begin
  		  TIME4 <= TIME4 + 1;
  		  //if(TIME4==9)
		  if(TIME4==3)
  		    begin
  		      TIME4<=0;
  		      TIME3<=TIME3+1;
				//if(TIME3==5)
  		      if(TIME3==0)//test 10s(fast) normal 60s
  		        begin
  		          TIME3<=0;
  		          A_TIME2<=A_TIME2-1;
					 TIME2<=TIME2-1;
  		         
  		          if(A_TIME2==0)
  		            begin
							A_TIME2<=9;
							A_TIME1<=A_TIME1-1;
		            end   

              if(TIME2==0)
  		            begin
							TIME2<=9;
							TIME1<=TIME1-1;
		            end						
		        end    
		    end
    end
	end

endmodule


module LED(CLK_1,STATE,SP,ST,SR,MODE,STOP,SET_M,SET_W,finish,LED_1,LED_2,LED_3,LED_ST,LED_P,LED_A);
input SP,ST,SR,CLK_1,SET_M,SET_W,finish,STOP;
input[1:0] STATE;
input[2:0] MODE;
output LED_1,LED_2,LED_3,LED_ST,LED_P,LED_A;
reg[1:0] count=0;
reg flag=0;
assign LED_1=(MODE==3'd3||MODE==3'd4||MODE==3'd5||STATE>2'b00||SR==1)? 0:(STATE==2'b00&&SP==0)?CLK_1:1;
assign LED_2=(MODE==3'd1||MODE==3'd5||STATE>2'b01||SR==1)? 0:(STATE==2'b01&&SP==0)?CLK_1:1;
assign LED_3=(MODE==3'd1||MODE==3'd2||MODE==3'd3||STATE>2'b10||SR==1)? 0:(STATE==2'b10&&SP==0)?CLK_1:1;
assign LED_ST=ST;
assign LED_P=~SR;
assign LED_A=((CLK_1&&flag)|(SET_M|SET_W|STOP))&&~SR;

always @(posedge CLK_1 or posedge SR or posedge finish )  
begin
  if(SR==1)
    begin
      flag<=0;
      count<=0; 
	  end  
  else
    begin
      if(finish==1)
        flag<=1;
      else if(flag==1)
        begin
          count<=count+1;
          if(count==2'd2)
            begin
              count<=0;
              flag<=0;
            end  
        end    
    end
end
endmodule

module M_WCHOOSE(CLK_1,SET_M,SET_W,SR,SP,finish,MODE,SET,WATER1,WATER2,display);
input CLK_1,SET_M,SET_W,SR,SP,finish;
output reg [2:0] MODE=0;
output reg [3:0] WATER1=0,WATER2=4'd3;
output reg display=0;
output reg SET=0;
reg[2:0] COUNT_D=0;
reg[2:0] COUNT_W=0; 
wire CLR=SR|finish;
wire sp=~SP;
always @(posedge SET_M or posedge CLR or posedge sp)
begin
  if(CLR==1)
    MODE<=0;
	 else if(sp)
	 SET<=0;
  else if(SP==1)
	  begin
	  SET<=1;
	    MODE<=MODE+1;
      if(MODE==3'd5)
        MODE<=0;
	  end
end

always @(posedge CLR or posedge SET_W)
begin
if(CLR==1)
COUNT_W<=0;
else
COUNT_W<=COUNT_W+1;
end

always @(COUNT_W)
begin
	case(COUNT_W)
		3'd0:
			begin
				WATER1<=4'd0;
				WATER2<=4'd3;
			end
		3'd1:
			begin
				WATER1<=4'd0;
				WATER2<=4'd4;
			end
		3'd2:
			begin
				WATER1<=4'd0;
				WATER2<=4'd5;
			end
		3'd3:
			begin
				WATER1<=4'd0;
				WATER2<=4'd6;
			end
		3'd4:
			begin
				WATER1<=4'd0;
				WATER2<=4'd7;
			end
		3'd5:
			begin
				WATER1<=4'd0;
				WATER2<=4'd8;
			end
		3'd6:
			begin
				WATER1<=4'd0;
				WATER2<=4'd9;
			end
		3'd7:
			begin
				WATER1<=4'd1;
				WATER2<=4'd0;
			end
		default
			begin
				WATER1<=4'd0;
				WATER2<=4'd3;
			end
	endcase

end


//always @( posedge SR or posedge CLK_1 or posedge SET_W)
always @( posedge CLR or posedge CLK_1 or posedge SET_W)
begin
    //if(SR==1)
	 if(CLR==1)
	 begin
			COUNT_D<=0;
			display<=0;
	 end
  else if(SET_W==1)
  begin
		COUNT_D<=0;
		display<=1;
  end
  else 
    begin
	  if(display==1)
	  begin
       COUNT_D<=COUNT_D+1;
       if(COUNT_D==3'd4)
         begin
           COUNT_D<=0;
			  display<=0;
         end
		end
		else
		begin
		   COUNT_D<=0;
	      display<=0;
		end
    end 

end	 

endmodule

module AUTO_CLOSE(POWER,STOP,SET_M,SET_W,finish,CLK_1,CLOSE);
input CLK_1,POWER,STOP,SET_M,SET_W,finish;
output reg CLOSE=0;
reg [3:0]count_C=0;
reg flag_c=0;
wire CLR=((SET_M|SET_W|STOP)&&(~CLOSE))|~POWER;
always @(posedge CLR or posedge finish or posedge CLK_1)
begin 
  if(CLR==1)
    begin
      flag_c<=0;
      count_C<=0;
      CLOSE<=0;
    end
  else if(finish==1)
     flag_c<=1;
  else if(flag_c==1)
    begin    
      count_C<=count_C+1;
      if(count_C==4'd9)
        begin
          CLOSE<=1;
          flag_c<=0;
          count_C<=0;
        end
    end
end
endmodule

module WASHER(POWER,STOP,SET_M,SET_W,CLK,LED_1,LED_2,LED_3,LED_in,LED_out,LED_ST,LED_P,LED_A,q_ctl, q_out);
input CLK,POWER,STOP,SET_M,SET_W;
output LED_1,LED_2,LED_3,LED_in,LED_out,LED_ST,LED_P,LED_A;
output [3:0] q_ctl;
output [7:0] q_out;
wire CLK_1,CLK_250,SR,SP,ST,finish,display,CLOSE;
wire[1:0] STATE;
wire[2:0] MODE;
wire [3:0] A_TIME1,A_TIME2,TIME1,TIME2,WATER1,WATER2;
Divider s1(CLK,CLK_1,CLK_250);
dtsm s2(CLK_250, A_TIME1,A_TIME2, TIME1,TIME2,display,WATER1,WATER2, q_ctl, q_out);
CONTROL s3(POWER,STOP,SR,SP,ST,finish,CLOSE);
COUNT s4(CLK_1,MODE,SET,SR,SP,ST,STATE,A_TIME1,A_TIME2,TIME1,TIME2,finish,LED_in,LED_out);
LED s5(CLK_1,STATE,SP,ST,SR,MODE,STOP,SET_M,SET_W,finish,LED_1,LED_2,LED_3,LED_ST,LED_P,LED_A);
M_WCHOOSE s6(CLK_1,SET_M,SET_W,SR,SP,finish,MODE,SET,WATER1,WATER2,display);
AUTO_CLOSE s7(POWER,STOP,SET_M,SET_W,finish,CLK_1,CLOSE);
endmodule
