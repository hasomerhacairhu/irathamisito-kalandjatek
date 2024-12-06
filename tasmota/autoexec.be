var topic = tasmota.cmd("Topic")["Topic"]

var autoload_files_for_topic = {
    "SUITCASE1_1":"/autoexec/suitcase1.be",
    "SUITCASE1_2":"/autoexec/suitcase2.be",
    "SUITCASE2_1":"/autoexec/suitcase1.be",
    "SUITCASE2_2":"/autoexec/suitcase2.be",
    "SUITCASE3_1":"/autoexec/suitcase1.be",
    "SUITCASE3_2":"/autoexec/suitcase2.be",
    "SUITCASE4_1":"/autoexec/suitcase1.be",
    "SUITCASE4_2":"/autoexec/suitcase2.be",
    "SUITCASE5_1":"/autoexec/suitcase1.be",
    "SUITCASE5_2":"/autoexec/suitcase2.be",
    "RADIO1":"/autoexec/radio1.be",
    "RADIO2":"/autoexec/radio2.be",
    "EMBASSY1_1":"/autoexec/embassy1.be",
    "EMBASSY1_2":"/autoexec/embassy2.be",
    "PROJECTOR":"/autoexec/projector.be",    
}
import string
log(string.format("Loading: %s", autoload_files_for_topic[topic]))
load(autoload_files_for_topic[topic])