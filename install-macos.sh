#!/bin/bash

# Bash strict mode, exit on failing command
set -e

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"

qemu-system-x86_64 \
    -enable-kvm \
    -m 2G \
    -machine q35,accel=kvm \
    -smp 4,cores=2 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -serial mon:stdio \
    -drive if=pflash,format=raw,readonly,file=packaged-firmware/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=firmware/OVMF_VARS-1024x768.fd \
    -device virtio-vga-gl \
    -display sdl,gl=on \
    -vga std \
    -L /usr/share/seabios/ \
    -L /usr/lib/ipxe/qemu/ \
    -audiodev pa,id=pa,server="/run/user/$(id -u)/pulse/native" \
    -device ich9-intel-hda -device hda-output,audiodev=pa \
    -usb -device usb-kbd -device usb-mouse \
    -netdev user,id=net0 \
    -device vmxnet3,netdev=net0,id=net0 \
    -drive id=ESP,if=virtio,format=qcow2,file=ESP.qcow2 \
    -drive id=InstallMedia,format=raw,if=virtio,file=BaseSystem/BaseSystem.img \
    -drive id=SystemDisk,if=virtio,file=macos.qcow2 \
