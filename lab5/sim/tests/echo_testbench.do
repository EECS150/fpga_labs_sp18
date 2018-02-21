start echo_testbench
add wave echo_testbench/*
add wave echo_testbench/off_chip_uart/*
add wave echo_testbench/off_chip_uart/uatransmit/*
add wave echo_testbench/off_chip_uart/uareceive/*
add wave echo_testbench/top/*
add wave echo_testbench/top/on_chip_uart/*
add wave echo_testbench/top/on_chip_uart/uareceive/*
add wave echo_testbench/top/on_chip_uart/uatransmit/*
run 10ms
