load test_helper

setup() {
  stub_diskutil
}

teardown() {
  umount_sd_boot /tmp/boot
  rm -f $img
  unstub_diskutil
}

@test "device-init: flash works" {
  skip "device-init.yaml is a legacy format not used in AlpineOS"
}

@test "device-init: flash --hostname sets hostname" {
  skip "device-init.yaml is a legacy format not used in AlpineOS"
}

@test "device-init: flash --ssid sets WiFi" {
  skip "device-init.yaml is a legacy format not used in AlpineOS"
}

@test "device-init: flash --config replaces device-init.yaml" {
  skip "device-init.yaml is a legacy format not used in AlpineOS"
}

@test "device-init: flash --bootconf replaces config.txt" {
  skip "device-init.yaml is a legacy format not used in AlpineOS"
}
