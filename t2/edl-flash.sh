#!/bin/sh

# This is edl flash shell script for surabaya/colombo.
# Make sure you phone can "adb reboot edl" to edl mode,
# or enter edl mode by yourself.Enjoy your caffee time.

adb devices |  sed -n 2p | grep device > /dev/null
if [ $? = 0 ]; then
    adb reboot edl
    sleep 2
fi

loop_time=0
lsusb | grep 'QDL mode'
while [ $? != 0 ]
do
    echo "wait for COM(9008)"
    sleep 2
    loop_time=$(expr $loop_time + 1)
    if [ $loop_time = 10 ]; then
        echo "###################################"
        echo "######   No Device Found!!   ######"
        echo "###################################"
        exit 1
    fi
    lsusb | grep 'QDL mode'
done

port_num=$(ls /sys/bus/usb-serial/drivers/qcserial/ | grep tty)

script_dir=`dirname "$0"`
$script_dir/apps/emmcdl -p $port_num -f $script_dir/prog_emmc_firehose_8992_ddr.mbn -x rawprogram_unsparse.xml
sleep 5
$script_dir/apps/emmcdl -p $port_num -f $script_dir/prog_emmc_firehose_8992_ddr.mbn -x patch0.xml

$script_dir/apps/fh_loader --port=/dev/$port_num --noprompt --showpercentagecomplete --zlpawarehost=0 --memoryname=eMMC --reset

echo "###################################"
echo "######  EDL Flash Done!!!  ########"
echo "###################################"
