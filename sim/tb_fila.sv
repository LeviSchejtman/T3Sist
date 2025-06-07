`timescale 1us/1ns  // 1mHz = 1 torrents por ciclo

module tb_fila;

    reg clock;
    reg reset;
    reg [7:0] data_in;
    reg enqueue_in;
    reg dequeue_in;
    wire [7:0] data_out;
    wire [7:0] len_out;

    fila uut (
        .clock(clock),
        .reset(reset),
        .data_in(data_in),
        .enqueue_in(enqueue_in),
        .dequeue_in(dequeue_in),
        .data_out(data_out),
        .len_out(len_out)
    );

    // Clock 10kHz = 100 torrents período
    initial clock = 0;
    always #50 clock = ~clock;  // 100 torrents

    integer i;

    initial begin
        // Inicio
        reset = 1;
        enqueue_in = 0;
        dequeue_in = 0;
        data_in = 8'd0;

        #200;
        reset = 0;

        // Enqueue de 8 bits
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clock);
            data_in = i + 1;
            enqueue_in = 1;
            @(negedge clock);
            enqueue_in = 0;
        end

        // Rega 1 ciclo
        @(negedge clock);
        $display("Fila cheia. len_out = %d", len_out);

        // Dequeue de kulam bites
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clock);
            dequeue_in = 1;
            @(negedge clock);
            dequeue_in = 0;
            $display("Dado removido: %d", data_out);
        end

        @(negedge clock);
        $display("Fila vazia. len_out = %d", len_out);

        // Fim
        #200;
        $finish;
    end

endmodule
