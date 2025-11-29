-- ====================================================================
--                 TARGET FISH MODULE
--          Safe | No Backdoors | GitHub-Based
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Target = {}

-- Fish database with locations and weights
Target.FishDatabase = {
    ["Rahasia Tang"] = {
        minWeight = 205000,  -- 205K kg
        maxWeight = 240000,  -- 240K kg
        bigWeight = 280000,  -- 280K kg (big variant)
        bigMaxWeight = 325000, -- 325K kg
        locations = {"Ancient Jungle"},
        rarity = "Mythic",
        time = "All",
        weather = "All"
    },
    -- Add more fish here as needed
}

-- Current target settings
Target.Current = {
    enabled = false,
    targetFish = nil,
    minWeight = 0,
    maxWeight = 999999999,
    autoTeleport = false,
    currentLocation = nil
}

-- Check if caught fish matches target
function Target.checkCatch(fishName, weight)
    if not Target.Current.enabled then return true end
    if not Target.Current.targetFish then return true end
    
    local targetData = Target.FishDatabase[Target.Current.targetFish]
    if not targetData then return true end
    
    -- Check if fish name matches
    if fishName ~= Target.Current.targetFish then
        return false
    end
    
    -- Check weight range
    if weight < Target.Current.minWeight or weight > Target.Current.maxWeight then
        return false
    end
    
    return true
end

-- Get best location for target fish
function Target.getBestLocation(fishName)
    local fishData = Target.FishDatabase[fishName]
    if not fishData or not fishData.locations or #fishData.locations == 0 then
        return nil
    end
    
    -- Return first location (can be enhanced with priority logic)
    return fishData.locations[1]
end

-- Get all fish names
function Target.getFishNames()
    local names = {}
    for name, _ in pairs(Target.FishDatabase) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Get fish info
function Target.getFishInfo(fishName)
    return Target.FishDatabase[fishName]
end

-- Set target fish
function Target.setTarget(fishName, minWeight, maxWeight, autoTeleport)
    Target.Current.targetFish = fishName
    Target.Current.minWeight = minWeight or 0
    Target.Current.maxWeight = maxWeight or 999999999
    Target.Current.autoTeleport = autoTeleport or false
    
    local fishData = Target.FishDatabase[fishName]
    if fishData then
        print("[Target] 🎯 Target set: " .. fishName)
        print("[Target] 📊 Weight range: " .. minWeight .. " - " .. maxWeight .. " kg")
        print("[Target] 📍 Best locations: " .. table.concat(fishData.locations, ", "))
    end
end

-- Enable/disable targeting
function Target.setEnabled(enabled)
    Target.Current.enabled = enabled
    if enabled then
        print("[Target] ✅ Fish targeting enabled")
    else
        print("[Target] ❌ Fish targeting disabled")
    end
end

-- Format weight for display
function Target.formatWeight(weight)
    if weight >= 1000000 then
        return string.format("%.1fM kg", weight / 1000000)
    elseif weight >= 1000 then
        return string.format("%.1fK kg", weight / 1000)
    else
        return weight .. " kg"
    end
end

-- Add custom fish to database
function Target.addFish(name, minWeight, maxWeight, locations, rarity, time, weather)
    Target.FishDatabase[name] = {
        minWeight = minWeight,
        maxWeight = maxWeight,
        locations = locations or {"Unknown"},
        rarity = rarity or "Common",
        time = time or "All",
        weather = weather or "All"
    }
    print("[Target] ✅ Added fish: " .. name)
end

return Target

