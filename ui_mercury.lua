-- ====================================================================
--                 UI MODULE - MERCURY INTERFACE
--          Alternative UI - More Stable than Rayfield
-- ====================================================================

local UI = {}

-- Module references (will be injected)
local Config, Teleport, Target
local callbacks = {}

-- ====================================================================
--                     MERCURY LOADER
-- ====================================================================
local function loadMercury()
    print("📦 [UI] Loading Mercury UI library...")
    
    local success, Mercury = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
    end)
    
    if not success then
        error("❌ Failed to load Mercury UI library: " .. tostring(Mercury))
    end
    
    print("✅ [UI] Mercury loaded successfully")
    return Mercury
end

-- ====================================================================
--                     UI SETUP
-- ====================================================================
function UI.setup(options)
    Config = options.Config
    Teleport = options.Teleport
    Target = options.Target
    callbacks = {
        onAutoFishToggle = options.onAutoFishToggle,
        onGPUSaverToggle = options.onGPUSaverToggle,
        onSellNow = options.onSellNow,
        onFavoriteNow = options.onFavoriteNow,
        onTargetTeleport = options.onTargetTeleport
    }
    
    local Mercury = loadMercury()
    
    local GUI = Mercury:Create{
        Name = "🎣 Auto Fish V5.0 - Safe Edition",
        Size = UDim2.fromOffset(600, 400),
        Theme = Mercury.Themes.Dark,
        Link = "https://github.com/anakhitsnyabintuni01-debug/AutoFish"
    }
    
    -- ====== MAIN TAB ======
    local MainTab = GUI:Tab{
        Name = "🏠 Main",
        Icon = "rbxassetid://4483362458"
    }
    
    MainTab:Toggle{
        Name = "⚡ BLATANT MODE (3x Faster!)",
        StartingState = Config.get("BlatantMode"),
        Callback = function(value)
            Config.set("BlatantMode", value)
            print("[Blatant Mode] " .. (value and "⚡ ENABLED" or "🔴 Disabled"))
        end
    }
    
    MainTab:Toggle{
        Name = "🤖 Auto Fish",
        StartingState = Config.get("AutoFish"),
        Callback = function(value)
            Config.set("AutoFish", value)
            callbacks.onAutoFishToggle(value)
        end
    }
    
    MainTab:Toggle{
        Name = "🎯 Auto Catch (Extra Speed)",
        StartingState = Config.get("AutoCatch"),
        Callback = function(value)
            Config.set("AutoCatch", value)
            print("[Auto Catch] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    }
    
    MainTab:Textbox{
        Name = "Fish Delay (seconds)",
        Placeholder = "Default: 0.9",
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0.1 and num <= 10 then
                Config.set("FishDelay", num)
                print("[Config] ✅ Fish delay: " .. num .. "s")
            end
        end
    }
    
    MainTab:Textbox{
        Name = "Catch Delay (seconds)",
        Placeholder = "Default: 0.2",
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0.1 and num <= 10 then
                Config.set("CatchDelay", num)
                print("[Config] ✅ Catch delay: " .. num .. "s")
            end
        end
    }
    
    MainTab:Toggle{
        Name = "💰 Auto Sell (Keeps Favorited)",
        StartingState = Config.get("AutoSell"),
        Callback = function(value)
            Config.set("AutoSell", value)
            print("[Auto Sell] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    }
    
    MainTab:Textbox{
        Name = "Sell Delay (seconds)",
        Placeholder = "Default: 30",
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 10 and num <= 300 then
                Config.set("SellDelay", num)
                print("[Config] ✅ Sell delay: " .. num .. "s")
            end
        end
    }
    
    MainTab:Button{
        Name = "💰 Sell All Now",
        Callback = function()
            callbacks.onSellNow()
        end
    }
    
    -- ====== TARGET FISH TAB ======
    local TargetTab = GUI:Tab{
        Name = "🎯 Target Fish"
    }
    
    TargetTab:Toggle{
        Name = "🎯 Enable Target Fishing",
        StartingState = false,
        Callback = function(value)
            Target.setEnabled(value)
        end
    }
    
    TargetTab:Button{
        Name = "🐟 Rahasia Tang (205K-240K kg)",
        Callback = function()
            Target.Current.targetFish = "Rahasia Tang"
            Target.Current.minWeight = 205000
            Target.Current.maxWeight = 240000
            Target.setEnabled(true)
            print("[Target] 🎯 Preset: Rahasia Tang (205K-240K)")
        end
    }
    
    TargetTab:Button{
        Name = "🐟 Rahasia Tang BIG (280K-325K kg)",
        Callback = function()
            Target.Current.targetFish = "Rahasia Tang"
            Target.Current.minWeight = 280000
            Target.Current.maxWeight = 325000
            Target.setEnabled(true)
            print("[Target] 🎯 Preset: Rahasia Tang BIG (280K-325K)")
        end
    }
    
    TargetTab:Toggle{
        Name = "🌍 Auto Teleport to Best Location",
        StartingState = false,
        Callback = function(value)
            Target.Current.autoTeleport = value
            print("[Target] " .. (value and "✅ Auto teleport ON" or "❌ Auto teleport OFF"))
        end
    }
    
    TargetTab:Button{
        Name = "🌍 Teleport to Target Now",
        Callback = function()
            if callbacks.onTargetTeleport then
                callbacks.onTargetTeleport()
            end
        end
    }
    
    -- ====== TELEPORT TAB ======
    local TeleportTab = GUI:Tab{
        Name = "🌍 Teleport"
    }
    
    local locationNames = Teleport.getLocationNames()
    for _, locationName in ipairs(locationNames) do
        TeleportTab:Button{
            Name = locationName,
            Callback = function()
                Teleport.to(locationName)
            end
        }
    end
    
    -- ====== SETTINGS TAB ======
    local SettingsTab = GUI:Tab{
        Name = "⚙️ Settings"
    }
    
    SettingsTab:Toggle{
        Name = "🖥️ GPU Saver Mode",
        StartingState = Config.get("GPUSaver"),
        Callback = function(value)
            Config.set("GPUSaver", value)
            callbacks.onGPUSaverToggle(value)
        end
    }
    
    SettingsTab:Toggle{
        Name = "⭐ Auto Favorite Fish",
        StartingState = Config.get("AutoFavorite"),
        Callback = function(value)
            Config.set("AutoFavorite", value)
            print("[Auto Favorite] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    }
    
    SettingsTab:Button{
        Name = "⭐ Favorite All Mythic/Secret Now",
        Callback = function()
            callbacks.onFavoriteNow()
        end
    }
    
    -- ====== INFO TAB ======
    local InfoTab = GUI:Tab{
        Name = "ℹ️ Info"
    }
    
    InfoTab:Label{
        Text = "🔒 Safe Auto Fish - Mercury Edition",
        Font = Enum.Font.GothamBold
    }
    
    InfoTab:Label{
        Text = "✅ GitHub-Based | No Backdoors",
        Font = Enum.Font.Gotham
    }
    
    InfoTab:Label{
        Text = "✅ Target Fishing by Weight",
        Font = Enum.Font.Gotham
    }
    
    InfoTab:Label{
        Text = "✅ Auto Teleport to Best Location",
        Font = Enum.Font.Gotham
    }
    
    InfoTab:Label{
        Text = "✅ 14 Teleport Locations",
        Font = Enum.Font.Gotham
    }
    
    InfoTab:Button{
        Name = "📖 How to Use Target Fishing",
        Callback = function()
            print([[
=== TARGET FISHING GUIDE ===
1. Go to Target Fish tab
2. Click preset (Rahasia Tang)
3. Enable Auto Teleport
4. Go to Main tab
5. Enable Auto Fish
6. Script will auto teleport and fish!
            ]])
        end
    }
    
    print("✅ [UI] Mercury interface loaded")
end

return UI

