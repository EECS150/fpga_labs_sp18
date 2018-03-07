start system_testbench
add wave system_testbench/*
add wave system_testbench/DUT/*
add wave system_testbench/DUT/audio_controller/*
add wave system_testbench/DUT/streamer/*
add wave system_testbench/DUT/piezo_controller/*
add wave system_testbench/DUT/fsm/*
add wave system_testbench/model/*
add wave system_testbench/model/control_regs/*
add wave system_testbench/model/raw_bit_clk/*
add wave system_testbench/model/bit_clk_enable/*
add wave system_testbench/model/codec_ready/*
add wave system_testbench/model/prev_sync_value/*
add wave system_testbench/model/slot_0/*
add wave system_testbench/model/slot_1/*
add wave system_testbench/model/slot_2/*
add wave system_testbench/model/slot_3/*
add wave system_testbench/model/slot_4/*
add wave system_testbench/model/sdata_out_shift/*
add wave system_testbench/model/bit_counter/*
add wave system_testbench/off_chip_uart/*
add wave system_testbench/off_chip_uart/uareceive/*
add wave system_testbench/off_chip_uart/uatransmit/*
run 1000ms
