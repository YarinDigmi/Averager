// `timescale  1ns/1ps
module average #(
parameter NOF_BITS = 32
) (
input wire clk,
input wire rst_n,
input wire start,
input wire data_first,
input wire data_last,
input wire [NOF_BITS-1:0] data_in,
output reg [NOF_BITS:0] data_out,
output reg busy,
output reg TO,
output reg done
);

parameter PENDING=2'd0, READY=2'd1, WORKING=2'd2, FINISH=2'd3;
reg [1:0]state, next_state;
reg [NOF_BITS:0]out_count, out_sum, out_div;
reg data_last_temp,start_div,busy_count,busy_sum,busy_div,done_count,done_sum,done_div;
reg [3:0]TO_count;


always @(*)begin
    case(state)
    PENDING:begin
        TO=1'b0;
        busy=1'b0;
        done=1'b0;
        if(start) next_state=READY;
        else next_state=PENDING;
    end
    READY:begin
        if(TO_count>=4'd10) TO=1'b1;
        else TO=1'b0;
        busy=1'b0;
        done=1'b0;
        if(data_first && data_last) next_state=FINISH;
        else if(data_first) next_state=WORKING;
        else if(TO_count>=4'd10 && ~start) next_state=PENDING;
        else next_state=READY;
    end
    WORKING:begin
        TO=1'b0;
        busy=1'b1;
        done=1'b0;
        if(data_last) next_state=FINISH;
        else next_state=WORKING;
    end
    FINISH:begin
        TO=1'b0;
        busy=1'b1;
        if(done_div) begin
            next_state=READY;
            done=1'b1;
        end
        else begin
            next_state=FINISH;
            done=1'b0;
        end
    end
    endcase
end

 always @(*)begin
    if(done) data_out=out_div;
    else data_out=33'd0;

 end



always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        state<=PENDING;
        TO_count<=4'd0;
    end
    else begin
        state<=next_state;
        data_last_temp<=data_last;
        if(state==READY) TO_count<=TO_count+1'b1;
        else TO_count<=4'd0;
    end
end

always @(negedge clk) start_div<=data_last_temp;



Sum count(
    .clk(clk),
    .rst_n(rst_n),
    .data_first(data_first),
    .data_last(data_last),
    .data_in(1'b1),
    .data_out(out_count),
    .busy(busy_count),
    .done(done_count)
);
Sum Sum0(
    .clk(clk),
    .rst_n(rst_n),
    .data_first(data_first),
    .data_last(data_last),
    .data_in(data_in),
    .data_out(out_sum),
    .busy(busy_sum),
    .done(done_sum)
);
divu_int #(32) div0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start_div),
    .a(out_sum),
    .b(out_count),
    .busy(busy_div),
    .done(done_div),
    .valid(),
    .dbz(),
    .val(out_div),
    .rem()
);



endmodule
