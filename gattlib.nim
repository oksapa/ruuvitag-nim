##
##
##   GattLib - GATT Library
##
##   Copyright (C) 2016-2020 Olivier Martin <olivier@labapart.org>
##
##
##   This program is free software; you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation; either version 2 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with this program; if not, write to the Free Software
##   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
##

{.deadCodeElim: on.}
const
  gattlibdll* = "libgattlib.so"

type
  uuid_t* {.bycopy.} = object
    u_bits*: array[16, cuchar]
when not defined(BDADDR_BREDR):
  ##  GattLib note: BD Address have only been introduced into Bluez v4.100.
  ##                Prior to this version, only BDADDR_BREDR can be supported
  ##  BD Address type
  const
    BDADDR_BREDR* = 0x00000000
    BDADDR_LE_PUBLIC* = 0x00000001
    BDADDR_LE_RANDOM* = 0x00000002
## *
##  @name Gattlib errors
##
## @{

const
  GATTLIB_SUCCESS* = 0
  GATTLIB_INVALID_PARAMETER* = 1
  GATTLIB_NOT_FOUND* = 2
  GATTLIB_OUT_OF_MEMORY* = 3
  GATTLIB_NOT_SUPPORTED* = 4
  GATTLIB_DEVICE_ERROR* = 5
  GATTLIB_ERROR_DBUS* = 6
  GATTLIB_ERROR_BLUEZ* = 7
  GATTLIB_ERROR_INTERNAL* = 8

## @}
## *
##  @name GATT Characteristic Properties Bitfield values
##
## @{

const
  GATTLIB_CHARACTERISTIC_BROADCAST* = 0x00000001
  GATTLIB_CHARACTERISTIC_READ* = 0x00000002
  GATTLIB_CHARACTERISTIC_WRITE_WITHOUT_RESP* = 0x00000004
  GATTLIB_CHARACTERISTIC_WRITE* = 0x00000008
  GATTLIB_CHARACTERISTIC_NOTIFY* = 0x00000010
  GATTLIB_CHARACTERISTIC_INDICATE* = 0x00000020

## @}

## *
##  @name Options for gattlib_connect()
##
##  @note Options with the prefix `GATTLIB_CONNECTION_OPTIONS_LEGACY_`
##        is for Bluez prior to v5.42 (before Bluez) support
##
## @{

const
  GATTLIB_CONNECTION_OPTIONS_LEGACY_BDADDR_LE_PUBLIC* = (1 shl 0)
  GATTLIB_CONNECTION_OPTIONS_LEGACY_BDADDR_LE_RANDOM* = (1 shl 1)
  GATTLIB_CONNECTION_OPTIONS_LEGACY_BT_SEC_LOW* = (1 shl 2)
  GATTLIB_CONNECTION_OPTIONS_LEGACY_BT_SEC_MEDIUM* = (1 shl 3)
  GATTLIB_CONNECTION_OPTIONS_LEGACY_BT_SEC_HIGH* = (1 shl 4)

template GATTLIB_CONNECTION_OPTIONS_LEGACY_PSM*(value: untyped): untyped =
  (((value) and 0x000003FF) shl 11) ## < We encode PSM on 10 bits (up to 1023)

template GATTLIB_CONNECTION_OPTIONS_LEGACY_MTU*(value: untyped): untyped =
  (((value) and 0x000003FF) shl 21) ## < We encode MTU on 10 bits (up to 1023)

template GATTLIB_CONNECTION_OPTIONS_LEGACY_GET_PSM*(options: untyped): untyped =
  (((options) shr 11) and 0x000003FF)

template GATTLIB_CONNECTION_OPTIONS_LEGACY_GET_MTU*(options: untyped): untyped =
  (((options) shr 21) and 0x000003FF)

const
  GATTLIB_CONNECTION_OPTIONS_LEGACY_DEFAULT* = GATTLIB_CONNECTION_OPTIONS_LEGACY_BDADDR_LE_PUBLIC or
      GATTLIB_CONNECTION_OPTIONS_LEGACY_BDADDR_LE_RANDOM or
      GATTLIB_CONNECTION_OPTIONS_LEGACY_BT_SEC_LOW

## @}
## *
##  @name Discover filter
##
## @{

const
  GATTLIB_DISCOVER_FILTER_USE_NONE* = 0
  GATTLIB_DISCOVER_FILTER_USE_UUID* = (1 shl 0)
  GATTLIB_DISCOVER_FILTER_USE_RSSI* = (1 shl 1)
  GATTLIB_DISCOVER_FILTER_NOTIFY_CHANGE* = (1 shl 2)

## @}
## *
##  @name Gattlib Eddystone types
##
## @{

const
  GATTLIB_EDDYSTONE_TYPE_UID* = (1 shl 0)
  GATTLIB_EDDYSTONE_TYPE_URL* = (1 shl 1)
  GATTLIB_EDDYSTONE_TYPE_TLM* = (1 shl 2)
  GATTLIB_EDDYSTONE_TYPE_EID* = (1 shl 3)
  GATTLIB_EDDYSTONE_LIMIT_RSSI* = (1 shl 4)

## @}
## *
##  @name Eddystone ID types defined by its specification: https://github.com/google/eddystone
##
## @{

const
  EDDYSTONE_TYPE_UID* = 0x00000000
  EDDYSTONE_TYPE_URL* = 0x00000010
  EDDYSTONE_TYPE_TLM* = 0x00000020
  EDDYSTONE_TYPE_EID* = 0x00000030

## @}

type
  gatt_connection_t* {.bycopy.} = object
  gatt_stream_t* {.bycopy.} = object
## *
##  Structure to represent a GATT Service and its data in the BLE advertisement packet
##

type
  gattlib_advertisement_data_t* {.bycopy.} = object
    uuid*: uuid_t              ## *< UUID of the GATT Service
    data*: ptr uint8            ## *< Data attached to the GATT Service
    data_length*: csize_t      ## *< Length of data attached to the GATT Service

  gattlib_event_handler_t* = proc (uuid: ptr uuid_t; data: ptr uint8;
                                data_length: csize_t; user_data: pointer) {.cdecl.}

## *
##  @brief Handler called on disconnection
##
##  @param connection Connection that is disconnecting
##  @param user_data  Data defined when calling `gattlib_register_on_disconnect()`
##

type
  gattlib_disconnection_handler_t* = proc (user_data: pointer) {.cdecl.}

## *
##  @brief Handler called on new discovered BLE device
##
##  @param adapter is the adapter that has found the BLE device
##  @param addr is the MAC address of the BLE device
##  @param name is the name of BLE device if advertised
##  @param user_data  Data defined when calling `gattlib_register_on_disconnect()`
##

type
  gattlib_discovered_device_t* = proc (adapter: pointer; address: cstring;
                                    name: cstring; user_data: pointer) {.cdecl.}

## *
##  @brief Handler called on new discovered BLE device
##
##  @param adapter is the adapter that has found the BLE device
##  @param addr is the MAC address of the BLE device
##  @param name is the name of BLE device if advertised
##  @param advertisement_data is an array of Service UUID and their respective data
##  @param advertisement_data_count is the number of elements in the advertisement_data array
##  @param manufacturer_id is the ID of the Manufacturer ID
##  @param manufacturer_data is the data following Manufacturer ID
##  @param manufacturer_data_size is the size of manufacturer_data
##  @param user_data  Data defined when calling `gattlib_register_on_disconnect()`
##

type
  gattlib_discovered_device_with_data_t* = proc (adapter: pointer; `addr`: cstring;
      name: cstring; advertisement_data: ptr gattlib_advertisement_data_t;
      advertisement_data_count: csize_t; manufacturer_id: uint16;
      manufacturer_data: ptr uint8; manufacturer_data_size: csize_t;
      user_data: pointer) {.cdecl.}

## *
##  @brief Handler called on asynchronous connection when connection is ready
##
##  @param connection Connection that is disconnecting
##  @param user_data  Data defined when calling `gattlib_register_on_disconnect()`
##

type
  gatt_connect_cb_t* = proc (connection: ptr gatt_connection_t; user_data: pointer) {.
      cdecl.}

## *
##  @brief Callback called when GATT characteristic read value has been received
##
##  @param buffer contains the value to read.
##  @param buffer_len Length of the read data
##
##

type
  gatt_read_cb_t* = proc (buffer: pointer; buffer_len: csize_t): pointer {.cdecl.}

## *
##  @brief Constant defining Eddystone common data UID in Advertisement data
##

var gattlib_eddystone_common_data_uuid* {.importc: "gattlib_eddystone_common_data_uuid",
                                        dynlib: gattlibdll.}: uuid_t

## *
##  @brief List of prefix for Eddystone URL Scheme
##

var gattlib_eddystone_url_scheme_prefix*: cstring
## *
##  @brief Open Bluetooth adapter
##
##  @param adapter_name    With value NULL, the default adapter will be selected.
##  @param adapter is the context of the newly opened adapter
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_open*(adapter_name: cstring; adapter: ptr pointer): cint {.cdecl,
    importc: "gattlib_adapter_open", dynlib: gattlibdll.}
## *
##  @brief Enable Bluetooth scanning on a given adapter
##
##  @param adapter is the context of the newly opened adapter
##  @param discovered_device_cb is the function callback called for each new Bluetooth device discovered
##  @param timeout defines the duration of the Bluetooth scanning. When timeout=0, we scan indefinitely.
##  @param user_data is the data passed to the callback `discovered_device_cb()`
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_scan_enable*(adapter: pointer; discovered_device_cb: gattlib_discovered_device_t;
                                 timeout: csize_t; user_data: pointer): cint {.cdecl,
    importc: "gattlib_adapter_scan_enable", dynlib: gattlibdll.}
## *
##  @brief Enable Bluetooth scanning on a given adapter
##
##  @param adapter is the context of the newly opened adapter
##  @param uuid_list is a NULL-terminated list of UUIDs to filter. The rule only applies to advertised UUID.
##         Returned devices would match any of the UUIDs of the list.
##  @param rssi_threshold is the imposed RSSI threshold for the returned devices.
##  @param enabled_filters defines the parameters to use for filtering. There are selected by using the macros
##         GATTLIB_DISCOVER_FILTER_USE_UUID and GATTLIB_DISCOVER_FILTER_USE_RSSI.
##  @param discovered_device_cb is the function callback called for each new Bluetooth device discovered
##  @param timeout defines the duration of the Bluetooth scanning. When timeout=0, we scan indefinitely.
##  @param user_data is the data passed to the callback `discovered_device_cb()`
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_scan_enable_with_filter*(adapter: pointer;
    uuid_list: ptr ptr uuid_t; rssi_threshold: int16; enabled_filters: uint32;
    discovered_device_cb: gattlib_discovered_device_t; timeout: csize_t;
    user_data: pointer): cint {.cdecl, importc: "gattlib_adapter_scan_enable_with_filter",
                             dynlib: gattlibdll.}
## *
##  @brief Enable Eddystone Bluetooth Device scanning on a given adapter
##
##  @param adapter is the context of the newly opened adapter
##  @param rssi_threshold is the imposed RSSI threshold for the returned devices.
##  @param eddystone_types defines the type(s) of Eddystone advertisement data type to select.
##         The types are defined by the macros `GATTLIB_EDDYSTONE_TYPE_*`. The macro `GATTLIB_EDDYSTONE_LIMIT_RSSI`
##         can also be used to limit RSSI with rssi_threshold.
##  @param discovered_device_cb is the function callback called for each new Bluetooth device discovered
##  @param timeout defines the duration of the Bluetooth scanning. When timeout=0, we scan indefinitely.
##  @param user_data is the data passed to the callback `discovered_device_cb()`
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_scan_eddystone*(adapter: pointer; rssi_threshold: int16;
                                    eddystone_types: uint32; discovered_device_cb: gattlib_discovered_device_with_data_t;
                                    timeout: csize_t; user_data: pointer): cint {.
    cdecl, importc: "gattlib_adapter_scan_eddystone", dynlib: gattlibdll.}
## *
##  @brief Disable Bluetooth scanning on a given adapter
##
##  @param adapter is the context of the newly opened adapter
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_scan_disable*(adapter: pointer): cint {.cdecl,
    importc: "gattlib_adapter_scan_disable", dynlib: gattlibdll.}
## *
##  @brief Close Bluetooth adapter context
##
##  @param adapter is the context of the newly opened adapter
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_adapter_close*(adapter: pointer): cint {.cdecl,
    importc: "gattlib_adapter_close", dynlib: gattlibdll.}
## *
##  @brief Function to connect to a BLE device
##
##  @param adapter	Local Adaptater interface. When passing NULL, we use default adapter.
##  @param dst		Remote Bluetooth address
##  @param options	Options to connect to BLE device. See `GATTLIB_CONNECTION_OPTIONS_*`
##

proc gattlib_connect*(adapter: pointer; dst: cstring; options: culong): ptr gatt_connection_t {.
    cdecl, importc: "gattlib_connect", dynlib: gattlibdll.}
## *
##  @brief Function to asynchronously connect to a BLE device
##
##  @note This function is mainly used before Bluez v5.42 (prior to D-BUS support)
##
##  @param adapter	Local Adaptater interface. When passing NULL, we use default adapter.
##  @param dst		Remote Bluetooth address
##  @param options	Options to connect to BLE device. See `GATTLIB_CONNECTION_OPTIONS_*`
##  @param connect_cb is the callback to call when the connection is established
##  @param user_data is the user specific data to pass to the callback
##

proc gattlib_connect_async*(adapter: pointer; dst: cstring; options: culong;
                           connect_cb: gatt_connect_cb_t; user_data: pointer): ptr gatt_connection_t {.
    cdecl, importc: "gattlib_connect_async", dynlib: gattlibdll.}
## *
##  @brief Function to disconnect the GATT connection
##
##  @param connection Active GATT connection
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_disconnect*(connection: ptr gatt_connection_t): cint {.cdecl,
    importc: "gattlib_disconnect", dynlib: gattlibdll.}
## *
##  @brief Function to register a callback on GATT disconnection
##
##  @param connection Active GATT connection
##  @param handler is the callaback to invoke on disconnection
##  @param user_data is user specific data to pass to the callaback
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_register_on_disconnect*(connection: ptr gatt_connection_t;
                                    handler: gattlib_disconnection_handler_t;
                                    user_data: pointer) {.cdecl,
    importc: "gattlib_register_on_disconnect", dynlib: gattlibdll.}
## *
##  Structure to represent GATT Primary Service
##

type
  gattlib_primary_service_t* {.bycopy.} = object
    attr_handle_start*: uint16 ## *< First attribute handle of the GATT Primary Service
    attr_handle_end*: uint16   ## *< Last attibute handle of the GATT Primary Service
    uuid*: uuid_t              ## *< UUID of the Primary Service


## *
##  Structure to represent GATT Characteristic
##

type
  gattlib_characteristic_t* {.bycopy.} = object
    handle*: uint16            ## *< Handle of the GATT characteristic
    properties*: uint8         ## *< Property of the GATT characteristic
    value_handle*: uint16      ## *< Handle for the value of the GATT characteristic
    uuid*: uuid_t              ## *< UUID of the GATT characteristic


## *
##  Structure to represent GATT Descriptor
##

type
  gattlib_descriptor_t* {.bycopy.} = object
    handle*: uint16            ## *< Handle of the GATT Descriptor
    uuid16*: uint16            ## *< UUID16 of the GATT Descriptor
    uuid*: uuid_t              ## *< UUID of the GATT Descriptor


## *
##  @brief Function to discover GATT Services
##
##  @note This function can be used to force GATT services/characteristic discovery
##
##  @param connection Active GATT connection
##  @param services array of GATT services allocated by the function. Can be NULL.
##  @param services_count Number of GATT services discovered. Can be NULL
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_discover_primary*(connection: ptr gatt_connection_t;
                              services: ptr ptr gattlib_primary_service_t;
                              services_count: ptr cint): cint {.cdecl,
    importc: "gattlib_discover_primary", dynlib: gattlibdll.}
## *
##  @brief Function to discover GATT Characteristic
##
##  @note This function can be used to force GATT services/characteristic discovery
##
##  @param connection Active GATT connection
##  @param start is the index of the first handle of the range
##  @param end is the index of the last handle of the range
##  @param characteristics array of GATT characteristics allocated by the function. Can be NULL.
##  @param characteristics_count Number of GATT characteristics discovered. Can be NULL
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_discover_char_range*(connection: ptr gatt_connection_t; start: cint;
                                 `end`: cint; characteristics: ptr ptr gattlib_characteristic_t;
                                 characteristics_count: ptr cint): cint {.cdecl,
    importc: "gattlib_discover_char_range", dynlib: gattlibdll.}
## *
##  @brief Function to discover GATT Characteristic
##
##  @note This function can be used to force GATT services/characteristic discovery
##
##  @param connection Active GATT connection
##  @param characteristics array of GATT characteristics allocated by the function. Can be NULL.
##  @param characteristics_count Number of GATT characteristics discovered. Can be NULL
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_discover_char*(connection: ptr gatt_connection_t;
                           characteristics: ptr ptr gattlib_characteristic_t;
                           characteristics_count: ptr cint): cint {.cdecl,
    importc: "gattlib_discover_char", dynlib: gattlibdll.}
## *
##  @brief Function to discover GATT Descriptors in a range of handles
##
##  @param connection Active GATT connection
##  @param start is the index of the first handle of the range
##  @param end is the index of the last handle of the range
##  @param descriptors array of GATT descriptors allocated by the function. Can be NULL.
##  @param descriptors_count Number of GATT descriptors discovered. Can be NULL
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_discover_desc_range*(connection: ptr gatt_connection_t; start: cint;
                                 `end`: cint;
                                 descriptors: ptr ptr gattlib_descriptor_t;
                                 descriptors_count: ptr cint): cint {.cdecl,
    importc: "gattlib_discover_desc_range", dynlib: gattlibdll.}
## *
##  @brief Function to discover GATT Descriptor
##
##  @param connection Active GATT connection
##  @param descriptors array of GATT descriptors allocated by the function. Can be NULL.
##  @param descriptors_count Number of GATT descriptors discovered. Can be NULL
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_discover_desc*(connection: ptr gatt_connection_t;
                           descriptors: ptr ptr gattlib_descriptor_t;
                           descriptors_count: ptr cint): cint {.cdecl,
    importc: "gattlib_discover_desc", dynlib: gattlibdll.}
## *
##  @brief Function to read GATT characteristic
##
##  @note buffer is allocated by the function. It is the responsibility of the caller to free the buffer.
##
##  @param connection Active GATT connection
##  @param uuid UUID of the GATT characteristic to read
##  @param buffer contains the value to read. It is allocated by the function.
##  @param buffer_len Length of the read data
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_read_char_by_uuid*(connection: ptr gatt_connection_t; uuid: ptr uuid_t;
                               buffer: ptr pointer; buffer_len: ptr csize_t): cint {.
    cdecl, importc: "gattlib_read_char_by_uuid", dynlib: gattlibdll.}
## *
##  @brief Function to asynchronously read GATT characteristic
##
##  @param connection Active GATT connection
##  @param uuid UUID of the GATT characteristic to read
##  @param gatt_read_cb is the callback to read when the GATT characteristic is available
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_read_char_by_uuid_async*(connection: ptr gatt_connection_t;
                                     uuid: ptr uuid_t; gatt_read_cb: gatt_read_cb_t): cint {.
    cdecl, importc: "gattlib_read_char_by_uuid_async", dynlib: gattlibdll.}
## *
##  @brief Function to write to the GATT characteristic UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the GATT characteristic to read
##  @param buffer contains the values to write to the GATT characteristic
##  @param buffer_len is the length of the buffer to write
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_char_by_uuid*(connection: ptr gatt_connection_t;
                                uuid: ptr uuid_t; buffer: pointer;
                                buffer_len: csize_t): cint {.cdecl,
    importc: "gattlib_write_char_by_uuid", dynlib: gattlibdll.}
## *
##  @brief Function to write to the GATT characteristic handle
##
##  @param connection Active GATT connection
##  @param handle is the handle of the GATT characteristic
##  @param buffer contains the values to write to the GATT characteristic
##  @param buffer_len is the length of the buffer to write
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_char_by_handle*(connection: ptr gatt_connection_t;
                                  handle: uint16; buffer: pointer;
                                  buffer_len: csize_t): cint {.cdecl,
    importc: "gattlib_write_char_by_handle", dynlib: gattlibdll.}
## *
##  @brief Function to write without response to the GATT characteristic UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the GATT characteristic to read
##  @param buffer contains the values to write to the GATT characteristic
##  @param buffer_len is the length of the buffer to write
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_without_response_char_by_uuid*(
    connection: ptr gatt_connection_t; uuid: ptr uuid_t; buffer: pointer;
    buffer_len: csize_t): cint {.cdecl, importc: "gattlib_write_without_response_char_by_uuid",
                              dynlib: gattlibdll.}
## *
##  @brief Create a stream to a GATT characteristic to write data in continue
##
##  @note: The GATT characteristic must support 'Write-Without-Response'
##
##  @param connection Active GATT connection
##  @param uuid UUID of the GATT characteristic to write
##  @param stream is the object that is attached to the GATT characteristic that is used to write data to
##  @param mtu is the MTU of the GATT connection to optimise the stream writting
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_char_by_uuid_stream_open*(connection: ptr gatt_connection_t;
    uuid: ptr uuid_t; stream: ptr ptr gatt_stream_t; mtu: ptr uint16): cint {.cdecl,
    importc: "gattlib_write_char_by_uuid_stream_open", dynlib: gattlibdll.}
## *
##  @brief Write data to the stream previously created with `gattlib_write_char_by_uuid_stream_open()`
##
##  @param stream is the object that is attached to the GATT characteristic that is used to write data to
##  @param buffer is the data to write to the stream
##  @param buffer_len is the length of the buffer to write
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_char_stream_write*(stream: ptr gatt_stream_t; buffer: pointer;
                                     buffer_len: csize_t): cint {.cdecl,
    importc: "gattlib_write_char_stream_write", dynlib: gattlibdll.}
## *
##  @brief Close the stream previously created with `gattlib_write_char_by_uuid_stream_open()`
##
##  @param stream is the object that is attached to the GATT characteristic that is used to write data to
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_char_stream_close*(stream: ptr gatt_stream_t): cint {.cdecl,
    importc: "gattlib_write_char_stream_close", dynlib: gattlibdll.}
## *
##  @brief Function to write without response to the GATT characteristic handle
##
##  @param connection Active GATT connection
##  @param handle is the handle of the GATT characteristic
##  @param buffer contains the values to write to the GATT characteristic
##  @param buffer_len is the length of the buffer to write
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_write_without_response_char_by_handle*(
    connection: ptr gatt_connection_t; handle: uint16; buffer: pointer;
    buffer_len: csize_t): cint {.cdecl, importc: "gattlib_write_without_response_char_by_handle",
                              dynlib: gattlibdll.}
##
##  @brief Enable notification on GATT characteristic represented by its UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the characteristic that will trigger the notification
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_notification_start*(connection: ptr gatt_connection_t; uuid: ptr uuid_t): cint {.
    cdecl, importc: "gattlib_notification_start", dynlib: gattlibdll.}
##
##  @brief Disable notification on GATT characteristic represented by its UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the characteristic that will trigger the notification
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_notification_stop*(connection: ptr gatt_connection_t; uuid: ptr uuid_t): cint {.
    cdecl, importc: "gattlib_notification_stop", dynlib: gattlibdll.}
##
##  @brief Enable indication on GATT characteristic represented by its UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the characteristic that will trigger the indication
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_indication_start*(connection: ptr gatt_connection_t; uuid: ptr uuid_t): cint {.
    cdecl, importc: "gattlib_indication_start", dynlib: gattlibdll.}
##
##  @brief Disable indication on GATT characteristic represented by its UUID
##
##  @param connection Active GATT connection
##  @param uuid UUID of the characteristic that will trigger the indication
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_indication_stop*(connection: ptr gatt_connection_t; uuid: ptr uuid_t): cint {.
    cdecl, importc: "gattlib_indication_stop", dynlib: gattlibdll.}
##
##  @brief Register a handle for the GATT notifications
##
##  @param connection Active GATT connection
##  @param notification_handler is the handler to call on notification
##  @param user_data if the user specific data to pass to the handler
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_register_notification*(connection: ptr gatt_connection_t;
    notification_handler: gattlib_event_handler_t; user_data: pointer) {.cdecl,
    importc: "gattlib_register_notification", dynlib: gattlibdll.}
##
##  @brief Register a handle for the GATT indications
##
##  @param connection Active GATT connection
##  @param notification_handler is the handler to call on indications
##  @param user_data if the user specific data to pass to the handler
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_register_indication*(connection: ptr gatt_connection_t;
                                 indication_handler: gattlib_event_handler_t;
                                 user_data: pointer) {.cdecl,
    importc: "gattlib_register_indication", dynlib: gattlibdll.}
## *
##  @brief Function to retrieve RSSI from a MAC Address
##
##  @note: This function is mainly used before a connection is established. Once the connection
##  established, the function `gattlib_get_rssi()` should be preferred.
##
##  @param adapter is the adapter the new device has been seen
##  @param mac_address is the MAC address of the device to get the RSSI
##  @param rssi is the Received Signal Strength Indicator of the remote device
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_get_rssi_from_mac*(adapter: pointer; mac_address: cstring;
                               rssi: ptr int16): cint {.cdecl,
    importc: "gattlib_get_rssi_from_mac", dynlib: gattlibdll.}
## *
##  @brief Function to retrieve Advertisement Data from a MAC Address
##
##  @param connection Active GATT connection
##  @param advertisement_data is an array of Service UUID and their respective data
##  @param advertisement_data_count is the number of elements in the advertisement_data array
##  @param manufacturer_id is the ID of the Manufacturer ID
##  @param manufacturer_data is the data following Manufacturer ID
##  @param manufacturer_data_size is the size of manufacturer_data
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_get_advertisement_data*(connection: ptr gatt_connection_t;
    advertisement_data: ptr ptr gattlib_advertisement_data_t;
                                    advertisement_data_count: ptr csize_t;
                                    manufacturer_id: ptr uint16;
                                    manufacturer_data: ptr ptr uint8;
                                    manufacturer_data_size: ptr csize_t): cint {.
    cdecl, importc: "gattlib_get_advertisement_data", dynlib: gattlibdll.}
## *
##  @brief Function to retrieve Advertisement Data from a MAC Address
##
##  @param adapter is the adapter the new device has been seen
##  @param mac_address is the MAC address of the device to get the RSSI
##  @param advertisement_data is an array of Service UUID and their respective data
##  @param advertisement_data_count is the number of elements in the advertisement_data array
##  @param manufacturer_id is the ID of the Manufacturer ID
##  @param manufacturer_data is the data following Manufacturer ID
##  @param manufacturer_data_size is the size of manufacturer_data
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_get_advertisement_data_from_mac*(adapter: pointer;
    mac_address: cstring;
    advertisement_data: ptr ptr gattlib_advertisement_data_t;
    advertisement_data_count: ptr csize_t; manufacturer_id: ptr uint16;
    manufacturer_data: ptr ptr uint8; manufacturer_data_size: ptr csize_t): cint {.
    cdecl, importc: "gattlib_get_advertisement_data_from_mac", dynlib: gattlibdll.}
## *
##  @brief Convert a UUID into a string
##
##  @param uuid is the UUID to convert
##  @param str is the buffer that will contain the string
##  @param size is the size of the buffer
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_uuid_to_string*(uuid: ptr uuid_t; str: cstring; size: csize_t): cint {.
    cdecl, importc: "gattlib_uuid_to_string", dynlib: gattlibdll.}
## *
##  @brief Convert a string representing a UUID into a UUID structure
##
##  @param str is the buffer containing the string
##  @param size is the size of the buffer
##  @param uuid is the UUID structure that would receive the UUID
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_string_to_uuid*(str: cstring; size: csize_t; uuid: ptr uuid_t): cint {.
    cdecl, importc: "gattlib_string_to_uuid", dynlib: gattlibdll.}
## *
##  @brief Compare two UUIDs
##
##  @param uuid1 is the one of the UUID to compare with
##  @param uuid2 is the other UUID to compare with
##
##  @return GATTLIB_SUCCESS on success or GATTLIB_* error code
##

proc gattlib_uuid_cmp*(uuid1: ptr uuid_t; uuid2: ptr uuid_t): cint {.cdecl,
    importc: "gattlib_uuid_cmp", dynlib: gattlibdll.}