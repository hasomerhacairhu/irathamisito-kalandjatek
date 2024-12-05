
var autoload_module = module("autoload_module")

autoload_module.update_files = [
    "autoexec.be",
    "preinit.be",
    "autoload.be",
    "autoexec/embassy-1/autoexec.bat",
    "autoexec/embassy-1/autoexec.be",
    "autoexec/embassy-2/autoexec.bat",
    "autoexec/embassy-2/autoexec.be",

]

autoload_module.lib_files = [
    "lib/RotaryEncoder.be",
    "lib/LibRotaryEncoder.be",
]


autoload_module.fetch_url = "https://raw.githubusercontent.com/hasomerhacairhu/irathamisito-kalandjatek/refs/heads/main/tasmota/"
autoload_module.self_update_path = "lib/autoload.be"

autoload_module.load = def ()
    for f: autoload_module.lib_files
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

autoload_module.fetch_be_and_delete_compiled = def (url, filename_without_extension)
    import string
    try
        var file_size = tasmota.urlfetch(url)
        if (file_size)
            tasmota.cmd("UfsDelete " + filename_without_extension + ".bec")
        end
    except .. as variable, message
        print (string.format("Could not fetch %s. Error: %s (%s)", url, variable, message)) 
    end 
end

autoload_module.fetch = def (url, filepath)
    import string
    try
        var file_size = tasmota.urlfetch(url, filepath)
        if (file_size)
            #tasmota.cmd("UfsDelete " + filepath)
        end
    except .. as variable, message
        print (string.format("Could not fetch %s. Error: %s (%s)", url, variable, message)) 
    end 
end

autoload_module.update = def ()
    #update autoloader
    var self_update_url = autoload_module.fetch_url + autoload_module.self_update_path
    autoload_module.fetch_be_and_delete_compiled(self_update_url, "autoload")
    #fetch all berry component
    for f: autoload_module.files
        var url = autoload_module.fetch_url + "lib/" + f + ".be"
        autoload_module.fetch_be_and_delete_compiled(url, f)
    end
end

autoload_module.update_system = def ()
    #fetch all berry component
    for f: autoload_module.update_files
        var url = autoload_module.fetch_url + f
        print(url)
        autoload_module.fetch(url, f)
    end
end

return autoload_module