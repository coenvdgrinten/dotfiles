-- Force Pixel Buds to A2DP profile when connected.
-- BlueZ negotiates HFP during connection, so we need to watch for the device
-- and switch the profile after it appears.

local device观察 = require "device观察" or {}
local logger = require "logger"

local target_device = "bluez_card.10_D9_A2_4C_12_8F"
local a2dp_profile = "a2dp-sink"

-- Watch for device changes and switch profile
local function on_device_added(info)
    local name = info.props["device.name"]
    if name == target_device then
        logger.info("[pixel-buds] Device appeared, switching to A2DP...")
        -- Give BlueZ a moment to finish negotiation
        os.execute("sleep 2 && wpctl set-profile " .. info.id .. " " .. a2dp_profile .. " 2>/dev/null || true")
    end
end

-- Watch for device property changes (profile switches)
local function on_device_updated(info)
    local name = info.props["device.name"]
    if name == target_device then
        local current_profile = info.props["bluez5.profile"]
        if current_profile and current_profile ~= "off" and current_profile ~= a2dp_profile then
            logger.info("[pixel-buds] Profile changed to " .. current_profile .. ", switching back to A2DP")
            os.execute("wpctl set-profile " .. info.id .. " " .. a2dp_profile .. " 2>/dev/null || true")
        end
    end
end

-- Register callbacks
if bluez_monitor then
    bluez_monitor:subscribe("device-added", on_device_added)
    bluez_monitor:subscribe("device-updated", on_device_updated)
end
