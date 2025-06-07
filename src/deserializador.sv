module deserializador (
    input wire clock,
    input wire reset,
    input wire data_in,          // Entrada serial (1 bit)
    input wire write_in,            // Habilita escrita de 1 bit
    input wire ack_in,           // Confirma recebimento dos 8 bits
    output reg [7:0] data_out,    // Saída paralela de 8 bits
    output reg data_ready,          // Indica que data_out está válido
    output reg status_out         // 1 = ocupado / travado
);

    reg [7:0] buffer;
    reg [2:0] contador;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            buffer      <= 8'd0;
            contador    <= 3'd0;
            data_out     <= 8'd0;
            data_ready     <= 1'b0;
            status_out   <= 1'b0;
        end else begin
            if (!data_ready) begin
                if (write_in) begin
                    buffer <= {buffer[6:0], data_in};
                    contador <= contador + 1;

                    if (contador == 3'd7) begin
                        data_out <= {buffer[6:0], data_in};
                        data_ready <= 1'b1;
                        status_out <= 1'b1; // ocupado até ack_in
                    end
                end
            end else begin
                if (ack_in) begin
                    data_ready <= 1'b0;
                    status_out <= 1'b0;
                    contador <= 3'd0;
                end
            end
        end
    end

endmodule
