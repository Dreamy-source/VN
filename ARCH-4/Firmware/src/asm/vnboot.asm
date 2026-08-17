mmenter

start:
    rp 2, 1, timer_handler
    stop

timer_handler:
    load rx1, 1
    retb