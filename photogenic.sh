#/bin/bash
# Takes screenshots of the current screen (Default screen only) from all the connected devices and emulators.
# Copies them to the working directory.
# And nothing more.


# TODO: see "dumpsys SurfaceFlinger --display-id" for valid display IDs.
# TODO: add device name? E.g: Pixel, etc


# Runs wm (to obtain screen characteristics) from a device.
# $1 The device ID.
# $2 The argument to the wm command.
function wm() {
    # adb shell wm density
    output=$(eval "adb -s $1 shell wm $2 | head -n 1")
    echo $output 
}


# Finds the approximated density qualifier.
# $1: The density: 420dp, 240 dp, etc.
function density_qualifier() {
    dq="mdpi"
    density_int=$(($1 + 0))
    if [ $density_int -le 200 ]
    then
        dq="mdpi"

    elif [ $density_int -le 280 ]
    then
        dq="hdpi"

    elif [ $density_int -le 430 ]
    then
        dq="xhdpi"

    elif [ $density_int -le 590 ]
    then
        dq="xxhdpi"

    else
        dq="xxxdpi"
    fi

    echo "$dq"
}


# Prints a useful name. Name will be device-{DEVICE-ID}-{DQ}-{DENSITY}-dp.png
# DQ is the density qualifier: mdpi, hdpi, etc.
function image_name() {
    density_output=$(wm $1 density)
    # Example output: Physical density: 440
    density=${density_output:18}
    resolution_output=$(wm $1 size)
    # Example output: Physical size: 1080x2160
    resolution=${resolution_output:15}
    dq=$(density_qualifier $density)

    echo "device-$1-$dq-$density-dp.png"
}


# Given a device ID, take a screen capture and copy it to the working dir.
# $1: The device ID
function screencap() {
    printf "Taking shot at %s\n" $1
    file_name=$(image_name $1)
    # echo $name
    eval "adb -s $1 shell screencap -p /sdcard/$file_name"
    eval "adb -s $1 pull /sdcard/$file_name"
}

# Find the IDs of the connected devices.
array=( $(adb devices) )
length=${#array[@]}

echo "Running..."
for index in ${!array[*]}
do
    # Skip first four elements, which correspond to "List of devices attached"
    if [ $index -gt 3 ]
    then
        # Device IDs will be the pair elements, see "adb devices"
        if (( $index % 2 == 0 ))
        then
            device_id=${array[$index]}
            # printf "%4d: %s\n" $index $device_id
            screencap $device_id
        fi
    fi
done
echo "Done."
