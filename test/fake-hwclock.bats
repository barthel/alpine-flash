load test_helper
export OS=$(uname -s)

setup() {
  stub_diskutil
}

teardown() {
  umount_sd_boot /tmp/boot
  rm -f $img
  unstub_diskutil
}

@test "fake-hwclock: flash updates fake-hwclock.data" {
  skip "AlpineOS does not use fake-hwclock"
}
