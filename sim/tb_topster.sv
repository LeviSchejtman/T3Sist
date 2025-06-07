`timescale 1us/1ns  // 1mHz = 1 torrents por ciclo

module tb_topster;

    reg clock1MHz;
    reg reset;
    reg data_serial;
    reg write_serial;
    reg ack_serial;
    reg dequeue_fila;

    wire [7:0] data_parallel;
    wire data_ready;
    wire status_busy;
    wire [7:0] fila_len;
    wire [7:0] fila_out;

    topster uut (
        .clock1MHz(clock1MHz),
        .reset(reset),
        .data_serial(data_serial),
        .write_serial(write_serial),
        .ack_serial(ack_serial),
        .dequeue_fila(dequeue_fila),
        .data_parallel(data_parallel),
        .data_ready(data_ready),
        .status_busy(status_busy),
        .fila_len(fila_len),
        .fila_out(fila_out)
    );

    // 1mHz = 1 torrents por ciclo
    initial clock1MHz = 0;
    always #0.5 clock1MHz = ~clock1MHz;

    // Procedimentos
   reg [7:0] tmp_byte;

    task enviar_byte;
        input [7:0] in_byte;
        integer i;
        begin
            tmp_byte = in_byte;
            for (i = 7; i >= 0; i = i - 1) begin
                data_serial = tmp_byte[i];
                write_serial = 1;
                #(10);  // 1 ciclo de 100kHz = 10 torrents
                write_serial = 0;
                #(10);
            end
        end
    endtask

    task esperar_data_ready_e_ack;
        begin
            wait(data_ready);
            ack_serial = 1;
            #(10);
            ack_serial = 0;
        end
    endtask

    initial begin
        // Inicio
        reset = 1;
        data_serial = 0;
        write_serial = 0;
        ack_serial = 0;
        dequeue_fila = 0;

        #(100);  // Aguarda clocks se estabilizarem
        reset = 0;

        // Bad Ending - Preencher a Fila até travar o deserializador
        $display("\nCASO RUIM: Fila cheia, deserializador deve travar");
        repeat (8) begin
            enviar_byte($random % 256);
            esperar_data_ready_e_ack;
        end

        // Tenta enviar mais byte (sem dequeues)
        enviar_byte(8'hAA);
        #(100);
        $display("Deserializador travado? status_busy = %b (esperado: 1)", status_busy);

        // Good Ending - Consome dados da fila entre envios
        $display("\nCASO BOM: Envia e consome sem travar");
        dequeue_fila = 1;
        #(100);  // 1 ciclo de 10kHz
        dequeue_fila = 0;

        repeat (4) begin
            enviar_byte($random % 256);
            esperar_data_ready_e_ack;

            // dequeues intercalados
            dequeue_fila = 1;
            #(100);
            dequeue_fila = 0;
        end

        #(500);
        $finish;
    end

endmodule
