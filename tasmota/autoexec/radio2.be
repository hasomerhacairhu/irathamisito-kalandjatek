    #motor endstop

    # UART logot ki kell kapcsolni, mert motor vezerjel megy rajta
    import string
    var motor_config = [
        {"enable_pin": 0, "dir_pin":1, "step_pin":2, "endstop_home_pin": 25, "step_interval": 30, "homing_step_interval":400},
        {"enable_pin": 3, "dir_pin":4, "step_pin":5, "endstop_home_pin": 26, "step_interval": 30, "homing_step_interval":400},
        {"enable_pin": 12, "dir_pin":13, "step_pin":14, "endstop_home_pin": 27, "step_interval": 30, "homing_step_interval":400},
        {"enable_pin": 15, "dir_pin":18, "step_pin":19, "endstop_home_pin": 32, "step_interval": 30, "homing_step_interval":400},
        {"enable_pin": 21, "dir_pin":22, "step_pin":23, "endstop_home_pin": 33, "step_interval": 30, "homing_step_interval":400},
    ]

    var manager = AsyncMotorManager()
    for c: motor_config
        var motor = manager.add_motor(c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"])
        motor.set_step_interval_ms(c["step_interval"])
        motor.set_homing_step_interval_ms(c["homing_step_interval"])
        #tasmota.cmd(string.format("AddAsyncMotor {\"enable_pin\": %d, \"dir_pin\": %d, \"step_pin\": %d, \"endstop_home_pin\": %d }", c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"]))
    end


    #tasmota.cmd("MotorRPM 200")



    # tasmota.cmd("AddAsyncMotor {\"enable_pin\": 16, \"dir_pin\": 17, \"step_pin\": 18, \"endstop_home_pin\": 19 }")
    # tasmota.cmd("AddAsyncMotor {\"enable_pin\": 20, \"dir_pin\": 21, \"step_pin\": 22, \"endstop_home_pin\": 23 }")
    # tasmota.cmd("SetMotorStepInterval1 30")
    # tasmota.cmd("SetMotorHomingStepInterval1 500")

    # tasmota.cmd("SetMotorStepInterval2 60")
    # tasmota.cmd("SetMotorHomingStepInterval2 400")