`timescale 1us/1ns  // 1mHz = 1 torrents por ciclo

module tb_deserializador;

    reg clock;
    reg reset;
    reg data_in;
    reg write_in;
    reg ack_in;
    wire [7:0] data_out;
    wire data_ready;
    wire status_out;

    // Instância do deserializador
    deserializador uut (
        .clock(clock),
        .reset(reset),
        .data_in(data_in),
        .write_in(write_in),
        .ack_in(ack_in),
        .data_out(data_out),
        .data_ready(data_ready),
        .status_out(status_out)
    );

    // 100kHz = 10 torrents por ciclo
    initial clock = 0;
    always #5 clock = ~clock;  // 10 torrents de período

    integer i;
    reg [7:0] test_byte = 8'b10110110;

    initial begin
        // Inicio
        reset = 1;
        write_in = 0;
        ack_in = 0;
        data_in = 0;

        #20;
        reset = 0;

        // Envio de 8 bits
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_byte[i];
            write_in = 1;
            #10;
            write_in = 0;
            #10;
        end

        // Rega o data_ready
        wait (data_ready == 1);
        $display("Deserializado: %b", data_out);

        // Confirma leitura no ack_in
        ack_in = 1;
        #10;
        ack_in = 0;

        // Fim
        #30;
        $finish;
    end

endmodule
