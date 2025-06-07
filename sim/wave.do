vsim tb_topster -onfinish stop

add wave -divider "Entradas principais"
add wave tb_topster/clock1MHz
add wave tb_topster/reset
add wave tb_topster/data_serial
add wave tb_topster/write_serial
add wave tb_topster/ack_serial
add wave tb_topster/dequeue_fila

add wave -divider "Saidas do sistema"
add wave tb_topster/data_parallel
add wave tb_topster/data_ready
add wave -color yellow tb_topster/status_busy
add wave -color red tb_topster/fila_len
add wave tb_topster/fila_out

add wave -divider "Topster"
add wave -recursive tb_topster/uut/*

run -all
