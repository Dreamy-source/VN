mmenter

start:
    msr 0, 1
    msr 1, 1000
    msr 2, 10

    rp 2, 1, timer_handler
    stop

timer_handler:
    retb