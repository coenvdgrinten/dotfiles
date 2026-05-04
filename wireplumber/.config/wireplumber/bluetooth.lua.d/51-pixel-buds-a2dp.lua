-- Force Google Pixel Buds to connect using A2DP (high-quality stereo) profile
-- instead of HFP (hands-free/mono) which degrades audio quality.
--
-- Device MAC: 10:D9:A2:4C:12:8F
-- WirePlumber device name: bluez_card.10_D9_A2_4C_12_8F

table.insert(bluez_monitor.rules, {
  matches = {
    {
      { "device.name", "equals", "bluez_card.10_D9_A2_4C_12_8F" },
    },
  },
  apply_properties = {
    -- Connect with A2DP (high-quality stereo) instead of HFP (hands-free/mono)
    ["device.profile"] = "a2dp-sink",
    -- Only auto-connect A2DP profiles, not HFP/HSP
    ["bluez5.auto-connect"] = "[ a2dp_sink ]",
  },
})
