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

## 8GB RAMDisk automount at user login

### /Library/LaunchAgents/8gb.ramdisk.plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>8gb.ramdisk.mount</string>
		<key>Program</key>
		<string>/usr/local/8gb.ramdisk.sh</string>
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

### /usr/local/8gb.ramdisk.sh

```
#!/bin/sh

if [ -f /tmp/.ramdisk.id ]; then
        RAMDISK=`cat /tmp/.ramdisk.id`
        echo "RAMDISK already attached -- $RAMDISK"
        exit
fi

RAMDISK=$(hdiutil attach -nomount -owners off ram://25165824)
echo ${RAMDISK} > /tmp/.ramdisk.id
diskutil erasevolume ExFAT "ramdisk" ${RAMDISK}

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

## Resizing APFS container to reserve some space for optimal SSD performance

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

---

### Creating a macOS bootable USB-drive

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

---

### FREE edition of NTFS for Mac by Paragon Software from Seagate website

https://www.seagate.com/ru/ru/support/software/paragon/

A direct link to version [5.15.90](https://www.seagate.com/files/www-content/support-content/external-products/backup-plus/_shared/downloads/NTFS_Paragon_Driver.dmg)

---

### Preventing auto-mount of any undesired partition with known UUID

Use "diskutil info disk<X>s<Y>" to obtain "Volume UUID", then use "vifs" to safely edit /etc/fstab.

Attention -- the only correct field separator is space (0x20).

```
UUID=Windows_10_UUID none ntfs noauto,ro
UUID=Another_macOS_installation_UUID none apfs ro,noauto
```

---

### Hiding undesired partitions on boot screen

Set ScanPolicy to proper integer value, i.e. to boot from APFS and HFS partitions only from SATA drives:

66307 = 0x00010303 = 0x00000001 + 0x00000002 + 0x00000100 + 0x00000200 + 0x00010000

```
ScanPolicy
Type: plist integer, 32 bit
Failsafe: 0x10F0103
Description: Define operating system detection policy.
This value allows preventing scanning (and booting) untrusted sources based on a bitmask (sum) of a set of flags. As it is not possible to reliably detect every file system or device type, this feature cannot be fully relied upon in open environments, and additional measures are to be applied.
Third party drivers may introduce additional security (and performance) consideratons following the provided scan policy. The active Scan policy is exposed in the scan-policy variable of 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102 GUID for UEFI Boot Services only.
0x00000001 (bit 0) — OC_SCAN_FILE_SYSTEM_LOCK, restricts scanning to only known file systems defined as a part of this policy. File system drivers may not be aware of this policy. Hence, to avoid mounting of undesired file systems, drivers for such file systems should not be loaded. This bit does not affect DMG mounting, which may have any file system. Known file systems are prefixed with OC_SCAN_ALLOW_FS_.
0x00000002 (bit 1) — OC_SCAN_DEVICE_LOCK, restricts scanning to only known device types defined as a part of this policy. It is not always possible to detect protocol tunneling, so be aware that on some systems, it may be possible for e.g. USB HDDs to be recognised as SATA instead. Cases like this must be reported. Known device types are prefixed with OC_SCAN_ALLOW_DEVICE_.
0x00000100 (bit 8) — OC_SCAN_ALLOW_FS_APFS, allows scanning of APFS file system.
0x00000200 (bit 9) — OC_SCAN_ALLOW_FS_HFS, allows scanning of HFS file system.
0x00000400 (bit 10) — OC_SCAN_ALLOW_FS_ESP, allows scanning of EFI System Partition file system.
0x00000800 (bit 11) — OC_SCAN_ALLOW_FS_NTFS, allows scanning of NTFS (Msft Basic Data) file system.
0x00001000 (bit 12) — OC_SCAN_ALLOW_FS_EXT, allows scanning of EXT (Linux Root) file system.
0x00010000 (bit 16) — OC_SCAN_ALLOW_DEVICE_SATA, allow scanning SATA devices.
0x00020000 (bit 17) — OC_SCAN_ALLOW_DEVICE_SASEX, allow scanning SAS and Mac NVMe devices.
0x00040000 (bit 18) — OC_SCAN_ALLOW_DEVICE_SCSI, allow scanning SCSI devices.
0x00080000 (bit 19) — OC_SCAN_ALLOW_DEVICE_NVME, allow scanning NVMe devices.
0x00100000 (bit 20) — OC_SCAN_ALLOW_DEVICE_ATAPI, allow scanning CD/DVD devices and old SATA.
0x00200000 (bit 21) — OC_SCAN_ALLOW_DEVICE_USB, allow scanning USB devices.
0x00400000 (bit 22) — OC_SCAN_ALLOW_DEVICE_FIREWIRE, allow scanning FireWire devices.
0x00800000 (bit 23) — OC_SCAN_ALLOW_DEVICE_SDCARD, allow scanning card reader devices.
0x01000000 (bit 24) — OC_SCAN_ALLOW_DEVICE_PCI, allow scanning devices directly connected to PCI bus (e.g. VIRTIO).
Note: Given the above description, a value of 0xF0103 is expected to do the following:
Permit scanning SATA, SAS, SCSI, and NVMe devices with APFS file systems.
Prevent scanning any devices with HFS or FAT32 file systems.
Prevent scanning APFS file systems on USB, CD, and FireWire drives.
The combination reads as:
OC_SCAN_FILE_SYSTEM_LOCK
OC_SCAN_DEVICE_LOCK
OC_SCAN_ALLOW_FS_APFS
OC_SCAN_ALLOW_DEVICE_SATA
OC_SCAN_ALLOW_DEVICE_SASEX
OC_SCAN_ALLOW_DEVICE_SCSI
OC_SCAN_ALLOW_DEVICE_NVME
```

---

### Fixing non-US keyboards on macOS 10.12 and later

[Technical Note TN2450](https://developer.apple.com/library/archive/technotes/tn2450/_index.html)

```
# "Grave Accent and Tilde" (0x35) to "Left Shift" (0xE1)
# "\ and |" (0x31) to "Return" (0x28)
# "Non-US \ and |" (0x64) to  "Return" (0x28) -- for "Russian PC" layout
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x7000000E1},{"HIDKeyboardModifierMappingSrc":0x700000031,"HIDKeyboardModifierMappingDst":0x700000028},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000028}]}'
```
