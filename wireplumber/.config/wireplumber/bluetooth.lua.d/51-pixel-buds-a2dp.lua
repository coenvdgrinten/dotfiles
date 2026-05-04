-- Force Google Pixel Buds to connect using A2DP (high-quality stereo) profile
-- instead of HFP (hands-free/mono) which degrades audio quality.
--
-- Device MAC: 10:D9:A2:4C:12:8F
-- WirePlumber device name: bluez_card.10_D9_A2_4C_12_8F
--
-- Strategy: Multiple layers of defense:
-- 1. Device-level: Prefer A2DP profile, disable HFP/HSP profiles
-- 2. Node-level: Force A2DP codec on sink nodes
-- 3. Auto-connect: Only auto-connect A2DP

table.insert(bluez_monitor.rules, {
  matches = {
    {
      { "device.name", "equals", "bluez_card.10_D9_A2_4C_12_8F" },
    },
  },
  apply_properties = {
    -- Prefer A2DP profile
    ["device.profile"] = "a2dp-sink",
    -- Disable HFP/HSP profiles at device level
    ["bluez5.profile.headset_head_unit.enabled"] = false,
    ["bluez5.profile.headset_head_set.enabled"] = false,
    -- Auto-connect only A2DP
    ["bluez5.auto-connect"] = "[ a2dp_sink ]",
    -- Force A2DP codec preferences
    ["bluez5.codecs.a2dp-sink"] = "ldac,aptx_hd,aptx,opus,sbc",
    ["bluez5.codecs.headset_head_unit"] = "",
  },
})
