    #motor endstop

    # UART logot ki kell kapcsolni, mert motor vezerjel megy rajta
    import string
    var motor_config = [
        {"enable_pin": 2, "dir_pin":0, "step_pin":1, "endstop_home_pin": 25, "step_interval": 10, "homing_step_interval":30},
        {"enable_pin": 5, "dir_pin":3, "step_pin":4, "endstop_home_pin": 26, "step_interval": 10, "homing_step_interval":30},
        {"enable_pin": 14, "dir_pin":12, "step_pin":13, "endstop_home_pin": 27, "step_interval": 10, "homing_step_interval":30},
        {"enable_pin": 19, "dir_pin":15, "step_pin":18, "endstop_home_pin": 32, "step_interval": 10, "homing_step_interval":30},
        {"enable_pin": 23, "dir_pin":21, "step_pin":22, "endstop_home_pin": 33, "step_interval": 10, "homing_step_interval":30},
    ]

    var manager = AsyncMotorManager()
    for c: motor_config
        var motor = manager.add_motor(c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"])
        motor.set_step_interval_ms(c["step_interval"])
        motor.set_homing_step_interval_ms(c["homing_step_interval"])
        #tasmota.cmd(string.format("AddAsyncMotor {\"enable_pin\": %d, \"dir_pin\": %d, \"step_pin\": %d, \"endstop_home_pin\": %d }", c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"]))
    end

