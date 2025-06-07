module fila (
    input wire clock,
    input wire reset,
    input wire [7:0] data_in,
    input wire enqueue_in,
    input wire dequeue_in,
    output reg [7:0] data_out,
    output reg [7:0] len_out // número de elementos na fila (0 a 8)
);

    reg [7:0] mem [0:7];      // memória FIFO com 8 posições de 8 bits
    reg [2:0] comeco, fim;     // leitura (dequeue) e escrita (enqueue)
    integer i;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            len_out  <= 8'd0;
            comeco     <= 3'd0;
            fim     <= 3'd0;
            data_out <= 8'd0;
            for (i = 0; i < 8; i = i + 1)
                mem[i] <= 8'd0;
        end else begin
            // ENQUEUE
            if (enqueue_in && len_out < 8) begin
                mem[fim] <= data_in;
                fim <= (fim + 1) % 8;
                len_out <= len_out + 1;
            end

            // DEQUEUE
            if (dequeue_in && len_out > 0) begin
                data_out <= mem[comeco];
                comeco <= (comeco + 1) % 8;
                len_out <= len_out - 1;
            end
        end
    end

endmodule
