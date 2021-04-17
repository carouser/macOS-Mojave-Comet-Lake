# macOS-Mojave-Comet-Lake

## Introduction

Is there any reason to pay $1900 for Mac mini 2018 if a very similar system can be build for 1/3 of the price with a possibility to install a pretty decent dGPU?

Let us know if you are fond of soldered SSD and a generous option of upgrading from 8GB DDR4-2666 to 32GB for $600 😃

This guideline covers specifics of macOS installation on a system with recent [Comet Lake](https://ark.intel.com/content/www/ru/ru/ark/products/codename/90354/comet-lake.html) CPUs.

Unfortunately the latest Catalina release 10.15.6 proved to have numerous annoying bugs and issues. Since it also lacks 32-bit support while not offering any deal-breaking features the previous Mojave 10.14.6 release appears preferable for the time being.

## The list of hardware

| HW | Details | P/N |
| --- | --- | --- |
| CPU | Intel 6C-12T-12M-2.9GHz-4.3GHz | [i5-10400](https://ark.intel.com/content/www/us/en/ark/products/199271/intel-core-i5-10400-processor-12m-cache-up-to-4-30-ghz.html) |
| MB | ASUS ROG STRIX H470-I GAMING | [H470-I](https://www.asus.com/Motherboards/ROG-STRIX-H470-I-GAMING/) |
| RAM | Crucial Ballistix DDR4-2666 16GB x 2 | [BL2K16G26C16U4B](https://www.crucial.com/memory/ddr4/bl2k16g26c16u4b) |
| HDD | Seagate 2.5" 7200rpm 320GB SATA3 | [ST9320423AS](https://www.seagate.com/staticfiles/support/disc/manuals/notebook/momentus/7200.4%20(Holliday)/100534376a.pdf) |
| SSD | Samsung 860 EVO 1TB SATA6 | [MZ-76E1T0BW](https://www.samsung.com/semiconductor/minisite/ssd/product/consumer/860evo/) |
| PSU | OCZ 550W | OCZ550FTY |
| CASE | Thermaltake F1 Supressor | [CA-1E6-00S1WN-00](https://www.thermaltake.com/suppressor-f1.html) |

Luckily Mojave does include support for Macmini8,1 which sports a pretty similar (aside from extra 300Mhz) Coffee Lake CPU — 6C-12T-12M-3.2GHz-4.6GHz — [i7-8700B](https://ark.intel.com/content/www/us/en/ark/products/134905/intel-core-i7-8700b-processor-12m-cache-up-to-4-60-ghz.html).

![About This Mac](./ATM-10.14.6.png)

---

## External resources

[OpenCore 0.6.1](https://github.com/acidanthera/OpenCorePkg/releases) — up to date bootloader

[Dortania Project](https://dortania.github.io/OpenCore-Install-Guide/config.plist/comet-lake.html) — excellent guide

---

## macOS / Windows BT pairing

Mostly extracted from [Soorma07](https://github.com/Soorma07/OS-X-Bluetooth-Pairing-Value-To-Windows-Value):

1.	Download [PsExec](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec) command line tool from Sysinternals package to access registry as SYSTEM
2.	Boot to Windows 10 and pair BT device
3.	Run "psexec -s -i regedit" as Administrator and export the key to REG-file:
	`HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\BD_ADDR`
4.	Reboot to macOS and pair BT device
5.	Export the key:
	`sudo defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist LinkKeys`
6.	Replace the key value in the original REG-file with the one from macOS — use reversed byte order, i.e.
	`00010203 04050607 08090a0b 0c0d0e0f` > `0f0e0d0c 0b0a0908 07060504 03020100`

---

## 8GB RAMDisk

### /Library/LaunchDaemons/8gb.ramdisk.attach.plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>8gb.ramdisk.attach</string>
		<key>Program</key>
		<string>/usr/local/8gb.attach.sh</string>
		<key>RunAtLoad</key>
		<true/>
		<key>StandardErrorPath</key>
		<string>/dev/null</string>
		<key>StandardOutPath</key>
		<string>/dev/null</string>
		<key>Disabled</key>
		<false/>
	</dict>
</plist>
```

### /Library/LaunchAgents/8gb.ramdisk.mount.plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>8gb.ramdisk.mount</string>
		<key>Program</key>
		<string>/usr/local/8gb.mount.sh</string>
		<key>RunAtLoad</key>
		<true/>
		<key>StandardErrorPath</key>
		<string>/dev/null</string>
		<key>StandardOutPath</key>
		<string>/dev/null</string>
		<key>Disabled</key>
		<false/>
	</dict>
</plist>
```

### /usr/local/8gb.attach.sh

```
#!/bin/sh

if [ -f /tmp/.ramdisk.id ]; then
        RAMDISK=`cat /tmp/.ramdisk.id`
        echo "RAMDISK already attached -- $RAMDISK"
        exit
fi

RAMDISK=$(hdiutil attach -nomount -owners off ram://25165824)
echo ${RAMDISK} > /tmp/.ramdisk.id
diskutil erasevolume HFS+ "ramdisk" ${RAMDISK}
```

### /usr/local/8gb.mount.sh

```
#!/bin/sh

RAMDISK=`cat /tmp/.ramdisk.id`

diskutil mount ${RAMDISK}

mkdir /Volumes/ramdisk/tmp
```

---

### To prevent Safari from keeping cache -- clean up and lock up the following directories:

```
~/Library/Safari/LocalStorage/
~/Library/Safari/Databases/
~/Library/Containers/com.apple.Safari/Data/Library/Caches/
```

---

![BTW, pretty good case for the money](https://thermaltake.azureedge.net/pub/media/catalog/product/cache/25e62158742be0ef47d2055284094406/db/imgs/pdt/gallery/CA-1E6-00S1WN-00_8f69b8e1d8f149b89087f802f5a29e35.jpg)

---

diskutil list

```
/dev/disk5 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.1 GB   disk5
   1:                        EFI EFI_T7                  209.7 MB   disk5s1
   2:                 Apple_APFS Container disk6         499.0 GB   disk5s2

/dev/disk6 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +499.0 GB   disk6
                                 Physical Store disk5s2
   1:                APFS Volume T7                      905.2 KB   disk6s1
```

diskutil apfs resizeContainer disk6 400g

https://support.apple.com/en-us/HT211683

Catalina:
https://apps.apple.com/ru/app/macos-catalina/id1466841314?l=en&mt=12


https://support.apple.com/en-us/HT201372

Big Sur:
sudo /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/createinstallmedia --volume /Volumes/MyVolume

Catalina:
sudo /Applications/Install\ macOS\ Catalina.app/Contents/Resources/createinstallmedia --volume /Volumes/MyVolume

Mojave:
sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/MyVolume


```
How to obtain FREE version of NTFS for Mac by Paragon Software:

https://www.seagate.com/ru/ru/support/software/paragon/

direct link -- 10.10 - 10.15 -- https://www.seagate.com/files/www-content/support-content/external-products/backup-plus/_shared/downloads/NTFS_Paragon_Driver.dmg
```
