tasmota.cmd("SetOption114 1")
tasmota.cmd("SwitchMode0 16")
tasmota.cmd("SerialLog 3")

class StepperDriver
    def every_second()
        if (self.ser.available() > 0)
            import string
            import mqtt
            var data = self.ser.read()
            if (data != nil)
                #tasmota.cmd(string.format("Publish tele/%s/stepper %s", self.topic, data.asstring()))
                mqtt.publish("tele/" + self.topic + "/stepper", data.asstring())

            end
        end
    end
    var ser, topic
    def stepper_command(cmd, idx, payload, payload_json)
        payload += "\n"
        self.ser.write(bytes().fromstring(payload))
        tasmota.resp_cmnd_done()
    end

    def go_home()
        self.ser.write(bytes().fromstring("HOMEALL\n"))
        log("Automatic homing sequence started.")
    end

    def init()
        self.topic = tasmota.cmd("Topic")["Topic"]
        self.ser = serial(16, 17, 9600, serial.SERIAL_8N1)
        tasmota.add_cmd('stepper', /cmd, idx, payload, payload_json-> self.stepper_command(cmd, idx, payload, payload_json))
        tasmota.set_timer(15000, /-> self.go_home())
    end
end

tasmota.add_driver(StepperDriver())