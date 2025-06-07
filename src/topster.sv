module topster (
    input wire clock1MHz,
    input wire reset,
    input wire data_serial,
    input wire write_serial,
    input wire dequeue_fila,
    input wire ack_serial,
    output wire [7:0] data_parallel,
    output wire data_ready,
    output wire status_busy,
    output wire [7:0] fila_len,
    output wire [7:0] fila_out
);

    reg [2:0] clk_div_100k_cnt = 0;
    reg [6:0] clk_div_10k_cnt = 0;
    reg clk_100k = 0;
    reg clk_10k = 0;

    always @(posedge clock1MHz or posedge reset) begin
        if (reset) begin
            clk_div_100k_cnt <= 0;
            clk_div_10k_cnt  <= 0;
            clk_100k <= 0;
            clk_10k  <= 0;
        end else begin
            // 100 kHz clock
            if (clk_div_100k_cnt == 4) begin
                clk_div_100k_cnt <= 0;
                clk_100k <= ~clk_100k;
            end else begin
                clk_div_100k_cnt <= clk_div_100k_cnt + 1;
            end

            // 10 kHz clock
            if (clk_div_10k_cnt == 49) begin
                clk_div_10k_cnt <= 0;
                clk_10k <= ~clk_10k;
            end else begin
                clk_div_10k_cnt <= clk_div_10k_cnt + 1;
            end
        end
    end

    wire [7:0] deserializador_data;
    wire deserializador_ready;
    wire deserializador_busy;

    wire [7:0] fila_output;
    wire [7:0] fila_length;

    deserializador u_deserializador (
        .clock(clk_100k),
        .reset(reset),
        .data_in(data_serial),
        .write_in(write_serial),
        .ack_in(ack_serial),
        .data_out(deserializador_data),
        .data_ready(deserializador_ready),
        .status_out(deserializador_busy)
    );

    fila u_fila (
        .clock(clk_10k),
        .reset(reset),
        .data_in(deserializador_data),
        .enqueue_in(deserializador_ready && fila_length < 8),
        .dequeue_in(dequeue_fila),
        .data_out(fila_output),
        .len_out(fila_length)
    );

    assign data_parallel  = deserializador_data;
    assign data_ready     = deserializador_ready;
    assign status_busy    = deserializador_busy;
    assign fila_len       = fila_length;
    assign fila_out       = fila_output;

endmodule
