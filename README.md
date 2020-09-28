# macOS-Mojave-i5-10400

This guideline covers specifics of macOS installation on the most recent Comet Lake CPUs (https://ark.intel.com/content/www/ru/ru/ark/products/codename/90354/comet-lake.html).

Unfortunately the latest Catalina release 10.15.6 proved to have numerous annoying bugs and issues. Since it also lacks 32-bit support while not offering any deal-breaking features the previous Mojave 10.14.6 release appears preferable for the time being.

The list of hardware:

	CPU:	Intel i5-10400 (BOX)
	MB:	ASUS H470-I (ITX)
	RAM:	CORSAIR DDR4-2666 16 GB x 2
	HDD:	Seagate 2.5" 7200rpm 320GB
	SSD:	Samsung 970 EVO SATA 1TB
	PSU:	OCZ 470
	CASE:	Thermaltake F1 Supressor
	GPU*:	ASUS NVIDIA 1650 SUPER
	SSD*:	Samsung 970 EVO NVME 500GB
	*used with Windows 10 only

Luckily Mojave does include support for Macmini8,1 which sports a pretty similar CPU (i7-8700B).

OpenCore 0.6.1 -- https://github.com/acidanthera/OpenCorePkg/releases

Excellent guide -- https://dortania.github.io/OpenCore-Install-Guide/config.plist/comet-lake.html

BT Link Key export / import guide -- https://github.com/Soorma07/OS-X-Bluetooth-Pairing-Value-To-Windows-Value

	Download PSEXEC utility to access registry as SYSTEM;
	Pair BT device
	Run "psexec -s -i regedit" with as Administrator and export the key:
		HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\BD_ADDR
	Reverse the byte order for the key (00010203 04050607 08090a0b 0c0d0e0f > 0f0e0d0c 0b0a0908 07060504 03020100)
	Reboot to macOS and import the key:
		sudo defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist LinkKeys
