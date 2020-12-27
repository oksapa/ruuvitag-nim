import gattlib
import strformat

const scan_time: csize_t = 60 #Scan time in seconds

type
    RuuviTag = object
        name: string
        mac: cstring
        temperature: float
        found: bool

#Ruuvitags to scan
var tags: array[2, RuuviTag] = [
    RuuviTag(name: "",
        mac: "C6:91:E5:75:1F:0C",
        temperature: 0,
        found: false),
    RuuviTag(name: "ﴤ",
        mac: "F0:85:52:29:EB:53",
        temperature: 0,
        found: false),
    
]

proc parse_ruuvi_data(ruuvi : var RuuviTag, data: ptr UncheckedArray[uint8], data_len: Natural) : bool =
    if data_len < 24:
        return false
    
    var temperature_int = (data[1].int16 shl 8) or data[2].int16
    var temperature = temperature_int.toFloat * 0.005
    ruuvi.temperature = temperature
    return true

proc ble_advertising_device (adapter: pointer; address: cstring; name: cstring; user_data: pointer){.cdecl.} =
    var advertisement_data: ptr gattlib_advertisement_data_t
    var advertisement_data_count: csize_t 
    var manufacturer_id: uint16 
    var manufacturer_data: ptr uint8
    var manufacturer_data_size: csize_t
    var ret: int

    ret = gattlib_get_advertisement_data_from_mac(adapter, address,
            addr advertisement_data, addr advertisement_data_count,
            addr manufacturer_id, addr manufacturer_data, addr manufacturer_data_size)

    # if (name.isNil == false):
    #     stdout.write(&"Device {address}- '{name}': ")
    # else:
    #     stdout.write(&"Device {address}: ")
    if manufacturer_data_size > 0:
        for i in tags.mitems:
            if i.mac == address:
                var data = cast[ptr UncheckedArray[uint8]](manufacturer_data)
                if parse_ruuvi_data(i, data, manufacturer_data_size.int):
                    i.found = true

        #for i in countup(0, manufacturer_data_size.int):
        #    stdout.write(&"{data[i]:02x} ")
        #for (size_t i = 0; i < manufacturer_data_size; i++) {
        #    echo("%02x ", manufacturer_data[i])
        #}
    #echo("\n")

when isMainModule:
    var adapter: pointer
    var ret: cint

    ret = gattlib_adapter_open(nil, addr adapter)
    if ret != 0:
        echo("Error")
    ret = gattlib_adapter_scan_enable_with_filter(adapter,
             nil, #/* Do not filter on any specific Service UUID */
             0, #/* RSSI Threshold */,
             GATTLIB_DISCOVER_FILTER_NOTIFY_CHANGE, #/* Notify change of advertising data/RSSI */
             ble_advertising_device,
             scan_time, #/* timeout=0 means infinite loop */
             nil) #/* user_data */);
    if ret != 0:
        echo("Error")
    discard gattlib_adapter_close(adapter)

    stdout.write("| ")
    for tag in tags:
        if tag.found:
            stdout.write(&"{tag.name} / {tag.temperature}℃ | ")
        else:
            stdout.write(&"{tag.name} N/A")
    echo("")