var topic = tasmota.cmd("Topic")["Topic"]

var autoload_files_for_topic = {
    "SUITCASE1_1":"/autoexec/suitcase-1.be",
    "SUITCASE1_2":"/autoexec/suitcase-2.be",
    "SUITCASE2_1":"/autoexec/suitcase-1.be",
    "SUITCASE2_2":"/autoexec/suitcase-2.be",
    "SUITCASE3_1":"na.be",
    "SUITCASE3_2":"na.be",
    "SUITCASE4_1":"na.be",
    "SUITCASE4_2":"na.be",
    "SUITCASE5_1":"na.be",
    "SUITCASE5_2":"na.be",
    "RADIO1":"na.be",
    "RADIO2":"na.be",
    "EMBASSY1_1":"na.be",
    "EMBASSY1_2":"na.be",
    "EMBASSY1_3":"na.be",
    "PROJECTOR":"na.be",    
}

print(autoload_files_for_topic[topic])
load(autoload_files_for_topic[topic])