
var autoload_module = module("autoload_module")

autoload_module.files = ["lib-RotaryEncoder", "NemletezoFile"]

autoload_module.load = def ()
    for f: autoload_module.files
        import string
        var is_loaded = load(f + ".bec") 
        var message
        if (!is_loaded)
            var is_compiled = tasmota.compile(f + ".be")
            if is_compiled
                is_loaded = load(f + ".bec")
                if (is_loaded)
                    tasmota.cmd("UfsDelete " + f + ".be")
                    message = "%s is compiled and loaded."
                end
            end
            message = "%s is not present!"
        else
            message = "%s is loaded."
        end
        print (string.format(message, f))
    end
end

autoload_module.init = autoload_module.load
return autoload_module