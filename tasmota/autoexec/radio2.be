tasmota.cmd("SetOption114 1")
tasmota.cmd("SwitchMode0 16")
tasmota.cmd("SerialLog 3")

class StepperDriver
    def every_second()
        if (self.ser.available() > 0)
            import string
            var data = self.ser.read()
            if (data != nil)
                tasmota.cmd(string.format("Publish tele/%s/stepper %s", self.topic, data.asstring()))
            end
        end
    end
    var ser, topic
    def stepper_command(cmd, idx, payload, payload_json)
        print(self.ser)

        print(cmd)
        print(idx)
        print(payload)
        print(payload_json)
        self.ser.write(bytes().fromstring(payload))
        tasmota.resp_cmnd_done()
    end

    def init()
        self.topic = tasmota.cmd("Topic")["Topic"]
        self.ser = serial(16, 17, 9600, serial.SERIAL_8N1)
        tasmota.add_cmd('stepper', /cmd, idx, payload, payload_json-> self.stepper_command(cmd, idx, payload, payload_json))
        tasmota.add_cron("* * * * * *", /-> self.every_second(), "parse_serial")
    end
end

tasmota.add_driver(StepperDriver())

#motor endstop

# UART logot ki kell kapcsolni, mert motor vezerjel megy rajta
# import string
# var motor_config = [
#     {"enable_pin": 5, "dir_pin":3, "step_pin":4, "endstop_home_pin": 26, "step_interval": 10, "homing_step_interval":30},
#     {"enable_pin": 23, "dir_pin":21, "step_pin":22, "endstop_home_pin": 33, "step_interval": 10, "homing_step_interval":30},
#     {"enable_pin": 14, "dir_pin":12, "step_pin":13, "endstop_home_pin": 27, "step_interval": 10, "homing_step_interval":30},
#     {"enable_pin": 19, "dir_pin":15, "step_pin":18, "endstop_home_pin": 32, "step_interval": 10, "homing_step_interval":30},
#     {"enable_pin": 2, "dir_pin":0, "step_pin":1, "endstop_home_pin": 25, "step_interval": 10, "homing_step_interval":30},

# ]

# var manager = AsyncMotorManager()
# for c: motor_config
#     var motor = manager.add_motor(c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"])
#     motor.set_step_interval_ms(c["step_interval"])
#     motor.set_homing_step_interval_ms(c["homing_step_interval"])
#     #tasmota.cmd(string.format("AddAsyncMotor {\"enable_pin\": %d, \"dir_pin\": %d, \"step_pin\": %d, \"endstop_home_pin\": %d }", c["enable_pin"],c["dir_pin"],c["step_pin"],c["endstop_home_pin"]))
# end