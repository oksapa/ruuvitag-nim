# ruuvitag-nim
Simple ruuvi tag scanner for polybar usage.

# Dependencies

* [Nim](https://nim-lang.org/)
* [GattLib](https://github.com/labapart/gattlib)

# Install

Use choosenim or other method to get nim up and running.
Compile and install gattlib.

Clone and compile ruuvitag.nim:
```
nim -c -d:release ruuvitag.nim
```

Adjust your own tag macs in to the code before compiling.

# Known issues

* Polybar is locked for the whole time script is running. Scan time can be adjusted by adjusting const variable scan_time
* Made for my own usage to learn how to generate wrapers to C-libraries with c2nim and to learn nim.
* Almost no error handling
* For some reason it takes a really long time to get data from all the tags. My android phone gets updates atleast once a second but it takes much longer with this app.
* Most likely the gattlib bindings are not complete. I tested only the parts I needed in this project. All others remain untested.
* If it locks up your BT it's not my fault. You have been warned.




