class AsyncMotorManager
    
    var motors
    
    def init()
        self.motors = []
        tasmota.add_cmd('AddAsyncMotor', / cmd idx payload payload_json -> self.add_motor_cmd(cmd, idx, payload, payload_json))
        tasmota.add_cmd('AsyncMotorMove', / cmd idx payload payload_json -> self.move_motor_cmd(cmd, idx, payload, payload_json))
        tasmota.add_cmd('GoToMotorPoistion', / cmd idx payload payload_json -> self.go_to_motor_position_cmd(cmd, idx, payload, payload_json))
        tasmota.add_cmd('SetMotorStepInterval', / cmd idx payload payload_json -> self.set_step_interval_cmd(cmd, idx, payload, payload_json))
        tasmota.add_cmd('SetMotorHomingStepInterval', / cmd idx payload payload_json -> self.set_homing_step_interval_cmd(cmd, idx, payload, payload_json))
    end

    def get_motor(idx)
        if idx > self.motors.size()
            log("Invalid motor index")
            return nil
        end
        return self.motors.item(idx-1)
    end

    def add_motor(enable_pin, dir_pin, step_pin, endstop_home_pin)
        # import AsyncStepperMotorDriver
        var motor = AsyncMotorDriver(enable_pin, dir_pin, step_pin, endstop_home_pin)
        self.motors.push(motor)
        return motor
    end

    def add_motor_cmd(cmd, idx, payload, payload_json)
        if (payload_json==nil) 
            tasmota.resp_cmnd_error()
            return
        end
        if (payload_json.contains('enable_pin') && payload_json.contains('dir_pin') && payload_json.contains('step_pin') && payload_json.contains('endstop_home_pin'))
            self.add_motor(int(payload_json['enable_pin']), int(payload_json['dir_pin']), int(payload_json['step_pin']), int(payload_json['endstop_home_pin']))
            tasmota.resp_cmnd_done()
        else
            tasmota.resp_cmnd_str("Missing parameter. Required parameters: enable_pin, dir_pin, step_pin, endstop_home_pin")
        end
    end
  
    def move_motor_cmd(cmd, idx, payload, payload_json)
        var motor = self.get_motor(idx)
        if (motor) 
            motor.move(int(payload))
            tasmota.resp_cmnd_done()
        else
            tasmota.resp_cmnd_error()
        end
    end

    def go_to_motor_position_cmd(cmd, idx, payload, payload_json)
        var motor = self.get_motor(idx)
        if (motor)
            motor.go_to_position(int(payload))
            tasmota.resp_cmnd_done()
        else
            tasmota.resp_cmnd_error()
        end
    end

    def set_step_interval_cmd(cmd, idx, payload, payload_json)
        import string
        var motor = self.get_motor(idx)
        if (motor)
            var ms = int(payload)
            motor.set_step_interval_ms(ms)
            log(string.format("Step interval: %dms", ms))
            tasmota.resp_cmnd_done()
        else
            tasmota.resp_cmnd_error()
        end
    end
    
    def set_homing_step_interval_cmd(cmd, idx, payload, payload_json)
        import string
        var motor = self.get_motor(idx)
        if (motor)
            var ms = int(payload)
            motor.set_homing_step_interval_ms(ms)
            log(string.format("Homing step interval: %dms", ms))
            tasmota.resp_cmnd_done()
        else
            tasmota.resp_cmnd_error()
        end
    end
end


