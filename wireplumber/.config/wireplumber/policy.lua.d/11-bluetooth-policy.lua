-- Disable automatically switching to Headset (hands-free) profile
-- when an application tries to use the microphone.
-- This prevents the Pixel Buds' audio quality from suddenly dropping
-- due to auto-switching when an app like 'cava' captures audio.

bluetooth_policy.policy["media-role.use-headset-profile"] = false
