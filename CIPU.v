module CIPU(
input       clk, 
input       rst,
input       [7:0]people_thing_in,
input       ready_fifo,
input       ready_lifo,
input       [7:0]thing_in,
input       [3:0]thing_num,
output reg     valid_fifo,
output reg     valid_lifo,
output reg     valid_fifo2,
output reg     [7:0]people_thing_out,
output reg     [7:0]thing_out,
output reg     done_thing,
output reg     done_fifo,
output reg     done_lifo,
output reg     done_fifo2);
    
    reg [7:0] FIFO [15:0]; 
    reg [7:0] LIFO [15:0]; 
   
    reg [4:0]fifo_count;//most 16  
    reg [3:0]lifo_count;// most 16
    
    reg [4:0]fifo_pop_counter;//most 16
    reg [3:0]lifo_pop_counter;//most 16
    reg [3:0]fifo2_pop_counter;
    
    reg [3:0]current_lifo_have;
    reg case_0;
    reg people_done;
    reg fifo2_start;
    
    always @(posedge clk)
    begin
        if(fifo2_start)
        begin
            valid_fifo2 = 1;
            done_lifo = 1;           
            fifo2_start = 0;
        end
        if(done_fifo2)
        begin
            done_thing = 0;
            done_fifo = 0;
            done_lifo = 0;
            done_fifo2 = 0;
        end
        if ((people_thing_in >= 8'b01000001) && (people_thing_in <= 8'b01011010) && (people_done != 1))//A~Z
        begin 
            FIFO[fifo_count] = people_thing_in;
            fifo_count = fifo_count + 1;
        end
        
        if(((thing_in >= 8'b00110001) && (thing_in <= 8'b00111001)) || (thing_in == 8'b00111011) || (thing_in == 8'b00100100))//1~9 && ;
        begin 
            if((valid_lifo != 1) && (done_thing != 1))
            begin
                if(thing_in == 8'b00100100)//$
                begin
                    fifo2_start = 1;
                end
                
                else if((thing_in == 8'b00111011) && (thing_num != 0))// ;
                begin            
                    lifo_pop_counter = thing_num; 
                    valid_lifo = 1;             
                end
                
                else if(thing_in != 8'b00111011)//;
                begin                
                    LIFO[lifo_count] = thing_in;
                    lifo_count = lifo_count + 1;
                end
                
                if((thing_num == 0) && (case_0 != 1) && (thing_in == 8'b00111011))//case 0
                begin
                    valid_lifo = 1;
                    lifo_pop_counter = 1;
                    case_0 = 1;
                end                         
            end
            
            else
            begin
                done_thing = 0;  
                thing_out = 0;
            end                
        end      
        
        if((people_thing_in == 8'b00100100) && (done_fifo == 0) && (people_done != 1))//$
        begin
            valid_fifo = 1;           
        end        
        else
        begin
            valid_fifo = 0;
            done_fifo = 0;
            //people_thing_out = 0;
        end      
        
        if((valid_fifo) && (people_done != 1))
        begin
            if(fifo_pop_counter == fifo_count )
            begin
                valid_fifo = 0;
                fifo_pop_counter = 0;
                done_fifo = 1;
                people_done = 1;
            end
            else if(fifo_pop_counter != fifo_count)
                people_thing_out = FIFO[fifo_pop_counter];
            fifo_pop_counter = fifo_pop_counter + 1;           
        end
        
        if(valid_lifo)
        begin
            if(case_0)
            begin
                if(lifo_pop_counter != 0)
                begin
                    thing_out = 8'B00110000;
                    lifo_pop_counter = lifo_pop_counter - 1;
                end
                else
                begin
                    valid_lifo = 0;
                    done_thing = 1;
                    case_0 = 0;
                    //fifo2_start = 1;//////////////////////////////////////////
                end    
            end
            else if(lifo_pop_counter != 0)
            begin
                thing_out = LIFO[lifo_count - 1];
                lifo_count = lifo_count -1;
                lifo_pop_counter = lifo_pop_counter - 1;
            end
            else
            begin
                valid_lifo = 0;
                done_thing = 1;
            end
        end    
        
        if(valid_fifo2)
        begin
            if(fifo2_pop_counter != lifo_count)
            begin
                thing_out = LIFO[fifo2_pop_counter];
                fifo2_pop_counter = fifo2_pop_counter + 1;
            end
            else
            begin
                valid_fifo2 = 0;
                done_fifo2 = 1;
            end
        end                   
    end
    
    always @(negedge rst)
    begin
        valid_fifo = 0;
        valid_lifo = 0;
        valid_fifo2 = 0;
        people_thing_out = 0;
        thing_out = 0;
        done_thing = 0;
        done_fifo = 0;
        done_lifo = 0;
        done_fifo2 = 0;
        fifo_count = 0;
        lifo_count = 0;
        fifo_pop_counter = 0;
        lifo_pop_counter = 0;
        case_0 = 0;
        people_done = 0;
        fifo2_pop_counter = 0;
    end
endmodule