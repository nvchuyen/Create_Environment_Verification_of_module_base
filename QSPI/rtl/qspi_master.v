`timescale 1ns / 1ps

module qspi_master #(
  parameter DATA_WIDTH = 32,
  parameter COMM_WIDTH = 8, 
  parameter ADDR_WIDTH = 24,
  parameter	DUMMY_CYC_SING = 8,
  parameter DUMMY_CYC_DUAL = 8,
  parameter DUMMY_CYC_QUAD = 10,
  parameter WIDTH      = DATA_WIDTH + ADDR_WIDTH + COMM_WIDTH 
  )
    (
        input  wire                                  i_clk,
        input  wire                                  i_rst_n,
        input  wire [DATA_WIDTH-1:0]                 i_data,
        input  wire [ADDR_WIDTH-1:0]                 i_addr,
        input  wire [COMM_WIDTH-1:0]                 i_command,
        input  wire                                  i_rw,
        input  wire                                  i_enable,
        input  wire                                  i_burst_enable,
        input  wire  [15:0]                          i_burst_count,
        input  wire  [15:0]                          i_divider,
        input  wire                                  i_cpha,
        input  wire                                  i_cpol,
        input  wire  [1:0]                           i_mode,
        output wire                                  SCLK,
        output wire  [DATA_WIDTH-1:0]                o_read_word,
        output reg                                   o_busy = 0,
        output reg                                   o_done = 0,        
        output reg                                   SS = 1,      
        output reg                                   o_burst_read_data_valid = 0,
        output reg                                   o_burst_write_word_request = 0,


        inout					 					                   SO0,
        inout 										                   SO1,
        inout 										                   SO2,
        inout 										                   SO3 
        // input  wire     [3:0]                        i_SO,
        // output reg      [3:0]                        o_SO,    // SO0 - MISO
        //                                                       // SO1 - MOSI
        //                                                       // SO2 - WP
        //                                                       // SO3 - HOLD
        // output  reg                 oe0,
        // output  reg                 oe1,
        // output  reg                 oe2,
        // output  reg                 oe3
    );
     
    localparam S_IDLE           =           8'h00;
    localparam S_SET_SS         =           8'h01;
    localparam S_TRANSMIT_COMM  =           8'h02;
    localparam S_TRANSMIT_ADDR  =           8'h03;
    localparam S_TRANSMIT_DATA  =           8'h04;
    localparam S_READ_DATA      =           8'h05;
    localparam S_STOP           =           8'h06;
    localparam S_DUMMY 	 		= 			8'h07;

    localparam SINGLE_MODE      = 2'b00;
    localparam DUAL_MODE        = 2'b01;
    localparam QUAD_MODE        = 2'b10;

    reg [7:0] state, next_state;
    reg [7:0] proc_counter = 0;
    reg [7:0] bit_counter = 0;
    reg [WIDTH-1:0] data_out = 0;
    reg [WIDTH-1:0] read_data = 0;
    reg        burst_enable = 0;
    reg        rw = 0;
    reg        cpha = 0;
    reg        cpol = 0;
    reg        sclk = 0;
    reg   [1:0]     mode = SINGLE_MODE;
    reg [WIDTH-1:0] read_word = 0;   
    reg [15:0] burst_count = 0;  
    reg [7:0]	dummy_cnt = 0;    
    

    reg 	[3:0] 		o_SO;
    wire 	[3:0] 		i_SO;

    reg 	oe0;
    reg 	oe1;
    reg 	oe2;
    reg 	oe3;
    
    assign o_read_word = read_data[DATA_WIDTH-1:0];
    
    assign SCLK = (cpol == 0) ? sclk : ~sclk;
    
    reg [15:0] divider_counter = 0;
    //clock divider
    wire divider_tick;
    assign divider_tick = (divider_counter == i_divider) ? 1 : 0;
    //spi divider tick geneartor
    always@(posedge i_clk or negedge i_rst_n)begin
        if(~i_rst_n)begin
            divider_counter <= 0;
        end
        else begin
            if(divider_counter == i_divider)begin
                divider_counter <= 0;
            end
            else begin
                divider_counter <= divider_counter + 1;
            end
        end
    end
    
    // FSM (1/3)
    always @(posedge i_clk or negedge i_rst_n) begin 
    	if(~i_rst_n) begin
    		state 		<= S_IDLE;
    	end else begin
    		if(divider_tick)
    			state 	 	<= next_state;
    	end
    end

    // FSM (2/3)
    always @(*) begin
    	next_state  = state;	 
    	case(state)
    		S_IDLE: begin
    			if(i_enable) begin
    				next_state 		= S_SET_SS;
    			end
    		end
    		S_SET_SS: begin
    			next_state 			= S_TRANSMIT_COMM;
    		end
    		S_TRANSMIT_COMM: begin
    			if(bit_counter >= COMM_WIDTH-1 && proc_counter == 3) begin
    				next_state 			= S_TRANSMIT_ADDR;
    			end
    		end
    		S_TRANSMIT_ADDR: begin
    			case(mode)
    				SINGLE_MODE: begin
    					if(bit_counter 	>= ADDR_WIDTH-1 && proc_counter == 3) begin
    						next_state 			= S_DUMMY; 
    					end
    				end
    				DUAL_MODE: begin
    					if(bit_counter 	>= ADDR_WIDTH-2 && proc_counter == 3) begin
    						next_state 			= S_DUMMY;
    					end
    				end
    				QUAD_MODE: begin
    					if(bit_counter 	>= ADDR_WIDTH-4 && proc_counter == 3) begin
    						next_state 			= S_DUMMY;
    					end
    				end
    			endcase
    		end
    		S_TRANSMIT_DATA: begin
    			if(bit_counter >= DATA_WIDTH-1 && proc_counter == 3) begin
    				if(burst_enable) begin
    					if(burst_count 	<= 1) begin
    						next_state 			= S_STOP;
    					end
    				end
    				else begin
    					next_state 			= S_STOP;
    				end
    			end
    		end
    		S_DUMMY: begin
    			case(mode)
    				SINGLE_MODE: begin
    					if(dummy_cnt == DUMMY_CYC_SING - 1 && proc_counter == 3) begin
    						if(rw == 0) begin
    							next_state 		= 	S_TRANSMIT_DATA;
    						end
    						else begin
    							next_state 		= 	S_READ_DATA;
    						end
    					end
    				end
    				DUAL_MODE: begin
    					if(dummy_cnt == DUMMY_CYC_DUAL - 1 && proc_counter == 3) begin
    						if(rw == 0) begin
    							next_state 		= 	S_TRANSMIT_DATA;
    						end
    						else begin
    							next_state 		= 	S_READ_DATA;
    						end
    					end
    				end
    				QUAD_MODE: begin
    					if(dummy_cnt == DUMMY_CYC_QUAD - 1 && proc_counter == 3) begin
    						if(rw == 0) begin
    							next_state 		= 	S_TRANSMIT_DATA;
    						end
    						else begin
    							next_state 		= 	S_READ_DATA;
    						end
    					end
    				end
    			endcase
    		end
    		S_READ_DATA: begin
    			case(mode)
    				SINGLE_MODE: begin
    					if(bit_counter >= DATA_WIDTH-1 &&  proc_counter == 3) begin
    						if(burst_enable) begin
    							if(burst_count 	<= 1) begin
    								next_state 		= 	S_STOP;
    							end
    						end
    						else begin
    							next_state 		= S_STOP;
    						end
    					end
    				end
    				DUAL_MODE: begin
    					if(bit_counter >= DATA_WIDTH-2 && proc_counter == 3) begin
    						if(burst_enable) begin
    							if(burst_count <= 1) begin
    								next_state 		= S_STOP;
    							end
    						end
    						else begin
    							next_state 		= S_STOP;
    						end
    					end
    				end
    				QUAD_MODE: begin
    					if(bit_counter >= DATA_WIDTH-4 && proc_counter == 3) begin
    						if(burst_enable) begin
    							if(burst_count <= 1) begin
    								next_state 			= S_STOP;
    							end
    						end
    						else begin
    							next_state 			= S_STOP;
    						end
    					end
    				end
    			endcase
    		end
    		S_STOP: begin
    			if(proc_counter == 3) begin
    				next_state 			=  S_IDLE;
    			end

    		end
    	endcase
    end

    // FSM (3/3)
    always@(posedge i_clk or negedge i_rst_n)begin
        if(~i_rst_n)begin
            o_busy <= 0;
            o_done <= 0;
            burst_enable <= 0;
            rw <= 0;
            cpha <= 0;
            cpol <= 0;
            SS  <= 1;
            o_SO[3:0] <= 0;
            sclk <= 0;
            mode <= SINGLE_MODE;
            read_word <= 0;
            read_data <= 0;
            o_burst_read_data_valid <= 0;
            burst_count <= 0;
            o_burst_write_word_request <= 0;
        end
        else begin
            if(divider_tick)begin
                case(state)
                    S_IDLE: begin
                        proc_counter <= 0;
                        burst_enable <= i_burst_enable;
                        rw <= i_rw;
                        cpha <= i_cpha;
                        cpol <= i_cpol;
                        mode <= i_mode;
						o_done 	<= 'b0;
                        burst_count <= i_burst_count;
                        if(i_enable)begin
                            o_busy <= 1;
                        end
                    end
                    
                    S_SET_SS: begin
                        SS    <= 0;
                        data_out <= {i_command,i_addr, i_data};
                        if(cpha == 0)begin
                            //to meet setup requirements we must set now for cpha = 0
                            o_SO[0] <= i_command[COMM_WIDTH-1];
                        end
                    end
                    
                    S_TRANSMIT_COMM: begin                   	
                      			case(proc_counter)
                          			0: begin
                            			proc_counter  <= 1;
                            			if(bit_counter > 0 && cpha == 1) begin
                              				read_data[0]  <= i_SO[1];
                              				read_data[WIDTH-1:1]  <= read_data[WIDTH-2:0];
                           				end
                            			if(bit_counter == 0 && cpha == 0) begin
                              				data_out  <= {data_out[WIDTH-2:0], 1'b0};
                            			end
                            			if(cpha == 1) begin
                              				read_data [0]  <= i_SO[1];
                              				read_data[WIDTH-1:1]  <= read_data[WIDTH-2:0];
                            			end
                          			end
                          			1: begin
                            			proc_counter  <= 2;
                            			if(cpha == 1) begin
                                     if(bit_counter == COMM_WIDTH) begin
                                       case(mode)
                                         SINGLE_MODE: begin
                              				    o_SO[0]  <= data_out[WIDTH-1];
                          				        data_out <= {data_out[WIDTH-2:0],1'b0};
                                        end
                                        DUAL_MODE: begin
                                          o_SO[1:0] <= data_out[WIDTH-1:WIDTH-2];
                                          data_out <= {data_out[WIDTH-3:0], 2'b0};
                                        end
                                        QUAD_MODE: begin
                                          o_SO[3:0] <= data_out[WIDTH-1:WIDTH-4];
                                          data_out <= {data_out[WIDTH-5:0], 4'b0000};
                                        end
                                      endcase
                            			  end
                                    else begin
                                      o_SO[0]  <= data_out[WIDTH-1];
                     				          data_out <= {data_out[WIDTH-2:0],1'b0};
                                    end
                                  end
                            			sclk  <= 1;
                          			end
                          			2: begin
                            			proc_counter  <= 3;
                            			if(cpha == 0) begin
                              				read_data[0]  <= i_SO[1];
                              				read_data[WIDTH-1:1]  <= read_data[WIDTH-2:0];
                         	  			end
                          			end
                          			3: begin
                            			proc_counter  <= 0;
                            			if(cpha == 0) begin
                                    if(bit_counter == COMM_WIDTH-1) begin
                                      case(mode)
                                        SINGLE_MODE: begin
                                          o_SO[0] <= data_out[WIDTH-1];
                              				    data_out <= {data_out[WIDTH-2:0], 1'b0};
                                        end
                                        DUAL_MODE: begin
                                          o_SO[1:0] <= data_out[WIDTH-1:WIDTH-2];
                                          data_out <= {data_out[WIDTH-3:0], 2'b0};
                                        end
                                        QUAD_MODE: begin
                                          o_SO[3:0] <= data_out[WIDTH-1:WIDTH-4];
                                          data_out <= {data_out[WIDTH-5:0], 4'b0000};
                                        end           
                                      endcase
                                    end
                                    else begin
                                        o_SO[0] <= data_out[WIDTH-1];
                            				    data_out <= {data_out[WIDTH-2:0], 1'b0};    
                                    end
                            			end
                            			if(bit_counter == COMM_WIDTH-1) begin
                              				bit_counter 			<= 'b0;
                            			end
                            			else begin
                              				bit_counter   <= bit_counter + 1;
                            			end
                            			sclk  <= 0;
                          			end
                      			endcase
                    end

                    S_TRANSMIT_ADDR: begin
                      case(mode)
                        SINGLE_MODE: begin
                          case(proc_counter)
                            0: begin
                               proc_counter <= 1;
                               if(bit_counter > 0 && cpha == 1)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];
                               end
                                if(cpha == 1)begin
                                    read_data[0] <= i_SO[0];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];   
                               end
                            end
                            
                            1: begin
                               proc_counter <= 2;
                               if(cpha == 1)begin
                                    o_SO[0] <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               sclk <= 1;
                            end
                            
                            2: begin
                               proc_counter <= 3;
                               if(cpha == 0)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];          
                               end
                            end
                            
                            3: begin
                                sclk <= 0;
                                proc_counter <= 0;
                               if(cpha == 0)begin
                                    o_SO[0]  <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               if(bit_counter == ADDR_WIDTH-1)begin
                                   bit_counter <= 0;
                                   o_SO[0]  <= 'b0;
                               end
                               else begin
                                   bit_counter <= bit_counter + 1;
                               end
                            end
                          endcase
                        end
                        DUAL_MODE: begin
                          case(proc_counter)
                            0: begin
                              proc_counter      <= 1;
                            end
                            1: begin
                              proc_counter      <= 2;
                              sclk              <= 1;
                              if(cpha == 1) begin
                                o_SO[1:0]         <= data_out[WIDTH-1:WIDTH-2];
                                data_out        <= {data_out[WIDTH-3:0],2'b00};
                              end
                            end
                            2: begin
                              proc_counter      <= 3;
                            end
                            3: begin
                              proc_counter      <= 0;
                              sclk              <= 0;
                              if(cpha == 0) begin
                                o_SO[1:0]     <= data_out[WIDTH-1:WIDTH-2];
                                data_out    <= {data_out[WIDTH-3:0], 2'b00};
                              end 
                              if(bit_counter >= ADDR_WIDTH-2) begin
                                bit_counter   <= 0;
                                o_SO[1:0] 		<= 2'b00;
                              end
                              else begin
                                bit_counter   <= bit_counter + 2;
                              end
                            end
                          endcase
                        end
                        QUAD_MODE: begin
                          case(proc_counter)
                            0: begin
                              proc_counter    <= 1;
                            end
                            1: begin
                              proc_counter    <= 2;
                              sclk            <= 1;
                              if(cpha == 1) begin
                                o_SO[3:0]       <= data_out[WIDTH-1:WIDTH-4];
                                data_out      <= {data_out[WIDTH-5:0],4'b0000};
                              end
                            end
                            2: begin
                              proc_counter    <= 3;
                            end
                            3: begin
                              proc_counter    <= 0;
                              sclk            <= 0;
                              if(cpha == 0) begin
                                o_SO[3:0]       <= data_out[WIDTH-1:WIDTH-4];
                                data_out      <= {data_out[WIDTH-5:0] , 4'b0000};
                              end
                              if(bit_counter >= ADDR_WIDTH-4) begin
                                bit_counter   <= 0;
                                o_SO[3:0] 		<= 4'b0000;
                              end
                              else begin
                                bit_counter   <= bit_counter + 4;
                              end
                            end
                          endcase
                        end
                      endcase
                    end
                    
                    S_TRANSMIT_DATA: begin
                      case(mode)
                        SINGLE_MODE: begin
                          case(proc_counter)
                            0:begin
                                proc_counter <= 1;
                                if(bit_counter == (DATA_WIDTH-1) && burst_enable == 1 && burst_count > 1)begin
                                    //if in burst mode send out request for new data word
                                    o_burst_write_word_request <= 1;
                                end
                                if(cpha == 1)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];   
                               end
                            end
                            
                            1: begin
                               proc_counter <= 2;
                               if(cpha == 1)begin
                                    o_SO[0] <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               sclk <= 1;
                            end
                            
                            2: begin
                                proc_counter <= 3;
                                if(cpha == 0)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0]; 
                                end
                                if(o_burst_write_word_request == 1)begin
                                    o_burst_write_word_request <= 0;
                                    data_out[WIDTH-1:ADDR_WIDTH+1] <= i_data;
                                end
                            end
                            
                            3: begin
                               sclk <= 0;
                               proc_counter <= 0;
                               if(cpha == 0)begin
                                    o_SO[0] <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               if(bit_counter == (DATA_WIDTH-1))begin
                                  bit_counter <= 0;
                                  if(burst_enable)begin
                                        burst_count <= burst_count - 1;
                                   end
                               end
                               else begin
                                   bit_counter <= bit_counter + 1;
                               end
                            end
                        endcase
                      end
                      DUAL_MODE: begin
                      	case(proc_counter)
                      		0: begin
                      			proc_counter 	<= 1;
                      			if(bit_counter 	== (ADDR_WIDTH-1) && burst_enable == 1 && burst_count > 1) begin
                      				o_burst_write_word_request 		<= 1;
                      			end
                      			if(cpha == 1 ) begin
                      				read_data[1:0] 			<= o_SO[1:0];
                      				read_data[WIDTH-1:2] 		<= {read_data[WIDTH-3:0], 2'b00};
                      			end
                      		end
                      		1: begin
                      			proc_counter 	<= 2;
                      			sclk 			<= 1;
                      			if(cpha == 1) begin
                      				o_SO[1:0] 		<= data_out[WIDTH-1: WIDTH-2];
                      				data_out 		<= {data_out[WIDTH-3:0] , 2'b00}; 
                      			end
                      		end
                      		2: begin
                      			proc_counter 	<= 3;
                      			if(o_burst_write_word_request == 1) begin
                      				o_burst_write_word_request 		<= 0;
                      				data_out[WIDTH-1:ADDR_WIDTH+1] 	<= i_data;
                      			end
                      		end
                      		3: begin
                      			proc_counter 	<= 0;
                      			sclk 			<= 0;
                      			if(cpha == 0) begin
                      				o_SO[1:0] 			<= data_out[WIDTH-1:WIDTH-2];
                      				data_out 			<= {data_out[WIDTH-3:0], 2'b00};
                      			end
                      			if(bit_counter 	== (DATA_WIDTH-2)) begin
                      				bit_counter 		<= 0;
                      				if(burst_enable) begin
                      					burst_count 		<= burst_count - 1;
                      				end
                      			end
                      			else begin
                      				bit_counter 		<= bit_counter 	+ 2;
                      			end
                      		end
                      	endcase
                      end
                      QUAD_MODE: begin
                      	case(proc_counter)
                      		0: begin
                      			proc_counter 	<= 1;
                      			if(bit_counter == (ADDR_WIDTH-1) && burst_enable == 1 && burst_count > 1) begin
                      				o_burst_write_word_request 			<= 1;
                      			end
                      			if(cpha == 1) begin
                      				read_data[3:0] 			<= o_SO[3:0];
                      				read_data[WIDTH-1:4] 		<= {read_data[WIDTH-5:0],4'b0000};
                      			end
                      		end
                      		1: begin
                      			proc_counter 	<= 2;
                      			sclk 			<= 1;
                      			if(cpha == 1) begin
                      				o_SO[3:0] 			<= data_out[WIDTH-1:WIDTH-4];
                      				data_out 			<= {data_out[WIDTH-5:0] , 4'b0000};
                      			end
                      		end
                      		2: begin
                      			proc_counter 	<= 3;
                      			if(o_burst_write_word_request == 1) begin
                      				o_burst_write_word_request 			<= 0;
                      				data_out[WIDTH-1:ADDR_WIDTH+1] 		<= i_data;
                      			end
                      		end
                      		3: begin
                      			proc_counter 	<= 0;
                      			sclk 			<= 0;
                      			if(cpha == 0) begin
                      				o_SO[3:0] 			<= data_out[WIDTH-1: WIDTH-4];
                      				data_out 			<= {data_out[WIDTH-5:0], 4'b0000};
                      			end
                      			if(bit_counter== (DATA_WIDTH-4)) begin
                      				bit_counter 		<= 0;
                      				if(burst_enable) begin
                      					burst_count 		<= burst_count - 1;
                      				end
                      			end
                      			else begin
                      				bit_counter 		<= bit_counter + 4;
                      			end
                      		end
                      	endcase
                      end
                    endcase
                  end
                    
                    //reg in shifted in data from slave into read_data
                    S_READ_DATA: begin
                      case (mode)
                        SINGLE_MODE : begin
                          case(proc_counter)
                            0:begin
                                proc_counter <= 1;
                                o_burst_read_data_valid <= 0;
                                if(cpha == 1)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];   
                               end
                            end
                            
                            1: begin
                               proc_counter <= 2;
                               if(cpha == 1)begin
                                    o_SO[0] <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               sclk <= 1;
                            end
                            
                            2: begin
                                proc_counter <= 3;
                                if(cpha == 0)begin
                                    read_data[0] <= i_SO[1];
                                    read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];
                                end
                            end
                            
                            3: begin
                               sclk <= 0;
                               proc_counter <= 0;
                               if(cpha == 0)begin
                                    o_SO[0] <= data_out[WIDTH-1];
                                    data_out <= {data_out[WIDTH-2:0], 1'b0};
                               end
                               if(bit_counter == (DATA_WIDTH-1))begin
                                   bit_counter <= 0;
                                   if(burst_enable)begin
                                        burst_count <= burst_count - 1;
                                        o_burst_read_data_valid <= 1;
                                   end
                               end
                               else begin
                                   bit_counter <= bit_counter + 1;
                               end
                            end
                          endcase 
                        end
                        DUAL_MODE: begin
                          case(proc_counter)
                            0 : begin
                              proc_counter  <= 1; 
                              o_burst_read_data_valid   <= 0;
                              if(cpha == 1) begin
                                read_data[1:0]    <= i_SO[1:0];
                                read_data[WIDTH-1:2]    <= read_data[WIDTH-3:0];
                              end
                            end
                            1: begin
                              proc_counter  <= 2;
                              sclk          <= 1;
                            end
                            2: begin
                              proc_counter  <= 3;
                              if(cpha == 0) begin
                                read_data[1:0]    <= i_SO[1:0];
                                read_data[WIDTH-1:2]    <= read_data[WIDTH-3:0];
                              end
                            end
                            3: begin
                              proc_counter  <= 0;
                              sclk          <= 0;
                              if(bit_counter >= (DATA_WIDTH - 2)) begin
                                bit_counter   <= 0;
                                if(burst_enable) begin
                                  burst_count   <= burst_count  - 1;
                                  o_burst_read_data_valid <= 1;
                                end
                              end
                              else begin
                                bit_counter <= bit_counter + 2;
                              end
                            end
                          endcase
                        end
                        QUAD_MODE: begin
                          case(proc_counter)
                            0: begin
                              proc_counter  <= 1;
                              o_burst_read_data_valid   <= 0;
                              if(cpha == 1) begin
                                read_data[3:0]      <= i_SO[3:0];
                                read_data[WIDTH-1:4]  <= read_data[WIDTH-4:0];
                              end
                            end
                            1: begin
                              proc_counter  <= 2;
                              sclk          <= 1;
                            end
                            2: begin
                              proc_counter  <= 3;
                              if(cpha == 0) begin
                                read_data[3:0]    <= i_SO[3:0];
                                read_data[WIDTH-1:4] <= read_data[WIDTH-4:0];
                              end
                            end
                            3: begin
                              proc_counter  <= 0;
                              sclk          <= 0;
                              if(bit_counter >= (DATA_WIDTH - 4)) begin
                                bit_counter   <= 0;
                                if(burst_enable) begin
                                  burst_count   <= burst_count  - 1;
                                  o_burst_read_data_valid <= 1;
                                end
                              end
                              else begin
                                bit_counter <= bit_counter + 4;
                              end
                            end
                          endcase
                        end
                      endcase
                    end
                    
                    S_STOP: begin
                    
                        case(proc_counter)
                            0:begin
                                proc_counter <= 1;
                                o_burst_read_data_valid <= 0;
                                case(mode)
                                	SINGLE_MODE: begin
                                		if(cpha == 1)begin
                                    		read_data[0] <= i_SO[0];
                                    		read_data[WIDTH-1:1] <= read_data[WIDTH-2:0];
                               			end
                               		end
                               		DUAL_MODE: begin
                               			if(cpha == 1) begin
                               				read_data[1:0] 		<= i_SO[1:0];
                               				read_data[WIDTH-1:2] 	<= read_data[WIDTH-3:0];
                               			end
                               		end
                             		QUAD_MODE: begin
                             			if(cpha == 1) begin
                             				read_data[3:0] 		<= i_SO[3:0];
                             				read_data[WIDTH-5:4] 	<= i_SO[3:0];
                             			end
                             		end
                               endcase
                            end
                            
                            1: begin
                               SS <= 1;
                               o_SO[3:0] <= 0;
                               proc_counter <= 2;
                            end
                            
                            2: begin
                                proc_counter <= 3;
                            end
                            
                            3: begin
                               proc_counter <= 0;
                               o_busy       <= 0;
                               o_done       <= 1;
                            end
                        endcase
                    end
                    
                    S_DUMMY: begin
                    	case(proc_counter)
                    		0 : begin
                    			proc_counter 		<= 	1;
                    		end
                    		1: begin
                    			proc_counter 		<= 	2;
                    			sclk 				<= 	1;
                    		end
                    		2: begin
                    			proc_counter 		<= 	3;
                    		end
                    		3: begin
                    			proc_counter 		<= 	0;
                    			sclk 				<= 	0;
                    			case(mode)
                    				SINGLE_MODE : begin
                    					if(dummy_cnt 	== DUMMY_CYC_SING -1) begin
                    						dummy_cnt 		<= 		0;
                    					end
                    					else begin
                    						dummy_cnt 	= 	dummy_cnt 	+ 1;
                    					end
                    				end
                    				DUAL_MODE: begin
                    					if(dummy_cnt 	== DUMMY_CYC_DUAL - 1) begin
                    						dummy_cnt 		<= 0;
                    					end
                    					else begin
                    						dummy_cnt 	= dummy_cnt 	+ 1;
                    					end
                    				end
                    				QUAD_MODE: begin
                    					if(dummy_cnt 	== DUMMY_CYC_QUAD - 1) begin
                    						dummy_cnt 		<= 0;
                    					end
                    					else begin
                    						dummy_cnt 		<= dummy_cnt + 1;
                    					end
                    				end
                    			endcase
                    		end
                    	endcase
                    	case (mode)
                    		SINGLE_MODE: begin
                    			o_SO[1] 			<= 0;
                    		end
                    		DUAL_MODE: begin
                    			o_SO[1:0] 			<= 2'b00;
                    		end
                    		QUAD_MODE: begin
                    			o_SO[3:0] 			<= 4'b0000;
                    		end
                    	endcase
                    end
                  
                endcase
            end
        end
    
    end


always @(posedge i_clk or negedge i_rst_n) begin 
	if(~i_rst_n) begin
		oe0 		<= 0;
		oe1 		<= 0;
		oe2 		<= 0;
		oe3 		<= 0;
	end else begin
			case(state)
				S_IDLE: begin
					oe0 		<= 0;
					oe1 		<= 0;
					oe2 		<= 0;
					oe3 		<= 0;
				end

				S_SET_SS: begin
					case(mode)
						SINGLE_MODE: begin
							oe0 	 	<= 1;
							oe1     <= 0;
						end 
						DUAL_MODE: begin
							oe0 		<= 1;
							oe1 		<= 1;
						end
						QUAD_MODE: begin
							oe0			<= 1;
							oe1 		<= 1;
						end
					endcase
				end

				S_TRANSMIT_COMM: begin
					case(mode)
						DUAL_MODE: begin
							oe0 		<= 1;
						end
						QUAD_MODE: begin
							oe0 		<= 1;
						end
					endcase
				end


				S_TRANSMIT_ADDR : begin
					case(mode)
						DUAL_MODE: begin
							oe0 		<= 1;
							oe1 		<= 1;
						end
						QUAD_MODE: begin
							oe0 	 	<= 1;
							oe1 		<= 1;
							oe2 		<= 1;
							oe3 		<= 1;
						end
					endcase
				end

				S_DUMMY: begin
				end

				S_TRANSMIT_DATA : begin
					case(mode)
						DUAL_MODE: begin
							oe0 		<= 1;
							oe1 		<= 1;
						end
						QUAD_MODE: begin
							oe0 		<= 1;
							oe1 		<= 1;
							oe2 		<= 1;
							oe3 		<= 1;
						end
					endcase
				end

				S_READ_DATA : begin
					case(mode)
						DUAL_MODE: begin
							oe0 		<= 0;
							oe1 		<= 0;
						end
						QUAD_MODE: begin
							oe0 		<= 0;
							oe1 		<= 0;
							oe2 		<= 0;
							oe3 		<= 0;
						end 
					endcase
				end

				S_STOP: begin
					oe0 		<= 0;
					oe1 		<= 0;
					oe2 		<= 0;
					oe3 		<= 0;
				end
			endcase
		//end
	end
end

// PAD

assign i_SO[0]          = SO0;
assign i_SO[1]          = SO1;
assign i_SO[2]          = SO2;
assign i_SO[3]          = SO3;

assign SO0              = oe0 ? o_SO[0]   : 'bz;
assign SO1              = oe1 ? o_SO[1]   : 'bz;
assign SO2              = oe2 ? o_SO[2]   : 'bz;
assign SO3              = oe3 ? o_SO[3]   : 'bz;



endmodule