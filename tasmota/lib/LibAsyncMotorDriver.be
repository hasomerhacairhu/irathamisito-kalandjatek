class AsyncMotorDriver
    var enable_pin, dir_pin, step_pin, endstop_home_pin
    var enabled, direction, target_step, current_step
    var step_interval, homing_step_interval
    var last_step_millis, this_step_millis, last_scheduler_millis
    var is_homing

    # Constructor takes GPIO pins for enable, direction, and step
    def init(enable_pin, dir_pin, step_pin, endstop_home_pin)
        self.enable_pin = enable_pin
        self.dir_pin = dir_pin
        self.step_pin = step_pin
        self.endstop_home_pin = endstop_home_pin
        self.step_interval = 20 #50Hz
        self.homing_step_interval = 50 #20Hz
        self.is_homing = false
        
        # Set GPIO pins as output
        gpio.pin_mode(self.enable_pin, gpio.OUTPUT)
        gpio.pin_mode(self.dir_pin, gpio.OUTPUT)
        gpio.pin_mode(self.step_pin, gpio.OUTPUT)
        gpio.pin_mode(self.endstop_home_pin, gpio.INPUT_PULLUP)
        
        # Default values
        self.enabled = true
        self.direction = true # true = CW, false = CCW
        self.target_step = 0
		self.current_step = 0
    end

    def set_step_interval_ms(ms)
        self.step_interval = ms
    end
    def set_homing_step_interval_ms(ms)
        self.homing_step_interval = ms
    end
    def get_current_position()
        return self.current_step
    end
	
    # Method to set current position as home
	def start_homing()
        self.is_homing = true
        self.move(-1)
    end

    def reset_position()
        self.current_step = 0
        self.target_step = 0
    end

    def find_home()
        var are_we_there_yet = false
        are_we_there_yet = !gpio.digital_read(self.endstop_home_pin)
        if are_we_there_yet
            self.is_homing = false
            self.reset_position()
        else
            self.move(-1)
        end
    end
    
    # Method to enable the motor
    def enable()
        log("Enable motor", 3)
        gpio.digital_write(self.enable_pin, gpio.LOW) # LOW to enable the motor
        self.enabled = true
    end
    
    # Method to disable the motor
    def disable()
        log("Disable motor", 3)
        gpio.digital_write(self.enable_pin, gpio.HIGH) # HIGH to disable the motor
        self.enabled = false
    end

    def stop()
        self.is_homing = false
        self.target_step = self.current_step
        self._stop_scheduler()
    end
    
    # Method to set the direction of the motor
    def set_direction(clockwise)
        self.direction = clockwise
    end
    
    # Method to set the delay between steps
    def set_step_delay(microseconds)
        self.step_delay = microseconds
    end
    
    # Method to start moving the motor for a given number of steps
    def move(steps)
        if steps == 0 || !self.enabled
            return
        end

        self.target_step += steps
		self._start_scheduler()     
    end
	
	def go_to_position(step)
		if step == 0 || !self.enabled
			return
		end
		
		self.target_step = step
		self._start_scheduler()        
	end

    def _start_scheduler()
        self.last_scheduler_millis = tasmota.millis()
        self.this_step_millis = self.last_scheduler_millis
        self.last_step_millis = self.last_scheduler_millis
        # tasmota.set_timer(self.step_interval, /-> self._scheduleStep())
        tasmota.add_fast_loop(/-> self.scheduler())
    end

    def _stop_scheduler()
        tasmota.remove_fast_loop(/-> self.scheduler())
    end

    def scheduler()
        var now = tasmota.millis()
        var timePassed = now - self.last_scheduler_millis
        var current_step_interval = self.is_homing ? self.homing_step_interval : self.step_interval
        if timePassed >= current_step_interval
            self.next_step()
            self.last_scheduler_millis = now
        end
    end
    
    # Private method to schedule the next step
    def next_step()
		var stepsAhead =  self.target_step-self.current_step
        self.this_step_millis = tasmota.millis()
        var stepDelay = self.this_step_millis - self.last_step_millis
		
        if stepsAhead != 0 && self.enabled
			
			# Negative steps results in direction change
			var current_direction = int(self.direction) ^ int(stepsAhead < 0)
			gpio.digital_write(self.dir_pin, current_direction)
			
            # Toggle step pin
            gpio.digital_write(self.step_pin, gpio.HIGH)
            tasmota.delay(1) # Short pulse for the step signal
            log ("ms " + str(stepDelay) + "\tstepsAhead: " + str(stepsAhead) + "\t current step: " + str(self.current_step) + "\t target step: " + str(self.target_step),4)
            gpio.digital_write(self.step_pin, gpio.LOW)

            self.current_step += current_direction ? 1 : -1

            if (self.is_homing)
                self.find_home()
            end
            
        else
            self._stop_scheduler()
        end
        self.last_step_millis = self.this_step_millis
    end
end