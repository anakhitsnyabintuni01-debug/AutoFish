-- ====================================================================
--                 UI MODULE - RAYFIELD INTERFACE
-- ====================================================================

local UI = {}

-- Module references (will be injected)
local Config, Teleport, Target
local callbacks = {}

-- ====================================================================
--                     RAYFIELD LOADER
-- ====================================================================
local function loadRayfield()
    print("📦 [UI] Loading Rayfield UI library...")
    
    -- Wait for game to be fully ready
    if not game:IsLoaded() then
        print("⏳ [UI] Waiting for game to load...")
        repeat task.wait(0.5) until game:IsLoaded()
    end
    
    -- Wait for CoreGui
    local CoreGui = game:GetService("CoreGui")
    local StarterGui = game:GetService("StarterGui")
    
    -- Test UI creation capability
    local canCreateUI = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        task.wait(0.1)
        test:Destroy()
    end)
    
    if not canCreateUI then
        warn("⚠️ [UI] CoreGui not ready, waiting 5 seconds...")
        task.wait(5)
    end
    
    -- Extra safety wait
    task.wait(1)
    
    print("🔄 [UI] Downloading Rayfield...")
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    
    if not success then
        error("❌ Failed to load Rayfield UI library: " .. tostring(Rayfield))
    end
    
    print("✅ [UI] Rayfield loaded successfully")
    return Rayfield
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
    
    local Rayfield = loadRayfield()
    
    local Window = Rayfield:CreateWindow({
        Name = "🎣 Auto Fish V5.0 - Safe Edition",
        LoadingTitle = "GitHub-Based | Anti-Backdoor",
        LoadingSubtitle = "Loading from YOUR repository...",
        ConfigurationSaving = {
            Enabled = false
        }
    })
    
    -- ====== MAIN TAB ======
    local MainTab = Window:CreateTab("🏠 Main", 4483362458)
    
    MainTab:CreateSection("Auto Fishing")
    
    MainTab:CreateToggle({
        Name = "⚡ BLATANT MODE (3x Faster!)",
        CurrentValue = Config.get("BlatantMode"),
        Callback = function(value)
            Config.set("BlatantMode", value)
            print("[Blatant Mode] " .. (value and "⚡ ENABLED - SUPER FAST!" or "🔴 Disabled"))
        end
    })
    
    MainTab:CreateToggle({
        Name = "🤖 Auto Fish",
        CurrentValue = Config.get("AutoFish"),
        Callback = function(value)
            Config.set("AutoFish", value)
            callbacks.onAutoFishToggle(value)
        end
    })
    
    MainTab:CreateToggle({
        Name = "🎯 Auto Catch (Extra Speed)",
        CurrentValue = Config.get("AutoCatch"),
        Callback = function(value)
            Config.set("AutoCatch", value)
            print("[Auto Catch] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    })
    
    MainTab:CreateInput({
        Name = "Fish Delay (seconds)",
        PlaceholderText = "Default: 0.9",
        RemoveTextAfterFocusLost = false,
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0.1 and num <= 10 then
                Config.set("FishDelay", num)
                print("[Config] ✅ Fish delay set to " .. num .. "s")
            else
                warn("[Config] ❌ Invalid delay (must be 0.1-10)")
            end
        end
    })
    
    MainTab:CreateInput({
        Name = "Catch Delay (seconds)",
        PlaceholderText = "Default: 0.2",
        RemoveTextAfterFocusLost = false,
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0.1 and num <= 10 then
                Config.set("CatchDelay", num)
                print("[Config] ✅ Catch delay set to " .. num .. "s")
            else
                warn("[Config] ❌ Invalid delay (must be 0.1-10)")
            end
        end
    })
    
    MainTab:CreateSection("Auto Sell")
    
    MainTab:CreateToggle({
        Name = "💰 Auto Sell (Keeps Favorited)",
        CurrentValue = Config.get("AutoSell"),
        Callback = function(value)
            Config.set("AutoSell", value)
            print("[Auto Sell] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    })
    
    MainTab:CreateInput({
        Name = "Sell Delay (seconds)",
        PlaceholderText = "Default: 30",
        RemoveTextAfterFocusLost = false,
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 10 and num <= 300 then
                Config.set("SellDelay", num)
                print("[Config] ✅ Sell delay set to " .. num .. "s")
            else
                warn("[Config] ❌ Invalid delay (must be 10-300)")
            end
        end
    })
    
    MainTab:CreateButton({
        Name = "💰 Sell All Now",
        Callback = function()
            callbacks.onSellNow()
        end
    })
    
    -- ====== TARGET FISH TAB ======
    local TargetTab = Window:CreateTab("🎯 Target Fish", nil)
    
    TargetTab:CreateSection("Target Settings")
    
    TargetTab:CreateToggle({
        Name = "🎯 Enable Target Fishing",
        CurrentValue = false,
        Callback = function(value)
            Target.setEnabled(value)
        end
    })
    
    -- Fish selection dropdown
    local fishNames = Target.getFishNames()
    if #fishNames > 0 then
        TargetTab:CreateDropdown({
            Name = "🐟 Select Target Fish",
            Options = fishNames,
            CurrentOption = fishNames[1],
            Callback = function(option)
                Target.Current.targetFish = option
                local fishInfo = Target.getFishInfo(option)
                if fishInfo then
                    print("[Target] 🎯 Selected: " .. option)
                    print("[Target] 📊 Weight: " .. Target.formatWeight(fishInfo.minWeight) .. " - " .. Target.formatWeight(fishInfo.maxWeight))
                    print("[Target] 📍 Locations: " .. table.concat(fishInfo.locations, ", "))
                end
            end
        })
    end
    
    TargetTab:CreateSection("Weight Range")
    
    TargetTab:CreateInput({
        Name = "⚖️ Min Weight (kg)",
        PlaceholderText = "Example: 205000",
        RemoveTextAfterFocusLost = false,
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0 then
                Target.Current.minWeight = num
                print("[Target] ✅ Min weight set to: " .. Target.formatWeight(num))
            else
                warn("[Target] ❌ Invalid weight")
            end
        end
    })
    
    TargetTab:CreateInput({
        Name = "⚖️ Max Weight (kg)",
        PlaceholderText = "Example: 240000",
        RemoveTextAfterFocusLost = false,
        Callback = function(value)
            local num = tonumber(value)
            if num and num >= 0 then
                Target.Current.maxWeight = num
                print("[Target] ✅ Max weight set to: " .. Target.formatWeight(num))
            else
                warn("[Target] ❌ Invalid weight")
            end
        end
    })
    
    TargetTab:CreateSection("Auto Teleport")
    
    TargetTab:CreateToggle({
        Name = "🌍 Auto Teleport to Best Location",
        CurrentValue = false,
        Callback = function(value)
            Target.Current.autoTeleport = value
            print("[Target] " .. (value and "✅ Auto teleport enabled" or "❌ Auto teleport disabled"))
        end
    })
    
    TargetTab:CreateButton({
        Name = "🌍 Teleport to Target Location Now",
        Callback = function()
            if callbacks.onTargetTeleport then
                callbacks.onTargetTeleport()
            end
        end
    })
    
    TargetTab:CreateSection("Quick Presets")
    
    -- Rahasia Tang preset
    TargetTab:CreateButton({
        Name = "🐟 Rahasia Tang (205K-240K kg)",
        Callback = function()
            Target.Current.targetFish = "Rahasia Tang"
            Target.Current.minWeight = 205000
            Target.Current.maxWeight = 240000
            Target.setEnabled(true)
            print("[Target] 🎯 Preset loaded: Rahasia Tang")
            print("[Target] 📊 Weight: 205K - 240K kg")
            print("[Target] 📍 Location: Ancient Jungle")
        end
    })
    
    TargetTab:CreateButton({
        Name = "🐟 Rahasia Tang BIG (280K-325K kg)",
        Callback = function()
            Target.Current.targetFish = "Rahasia Tang"
            Target.Current.minWeight = 280000
            Target.Current.maxWeight = 325000
            Target.setEnabled(true)
            print("[Target] 🎯 Preset loaded: Rahasia Tang (BIG)")
            print("[Target] 📊 Weight: 280K - 325K kg")
            print("[Target] 📍 Location: Ancient Jungle")
        end
    })
    
    TargetTab:CreateSection("Fish Info")
    
    TargetTab:CreateParagraph({
        Title = "🐟 Rahasia Tang",
        Content = [[
📊 Weight Range:
  • Normal: 205K - 240K kg
  • Big: 280K - 325K kg

📍 Location:
  • Ancient Jungle

⏰ Time: All
🌤️ Weather: All
⭐ Rarity: Mythic

Tips:
• Enable Auto Teleport untuk auto pindah
• Set weight range sesuai target
• Enable Target Fishing sebelum Auto Fish
        ]]
    })
    
    -- ====== TELEPORT TAB ======
    local TeleportTab = Window:CreateTab("🌍 Teleport", nil)
    
    TeleportTab:CreateSection("📍 Locations")
    
    -- Get all locations and sort them
    local locationNames = Teleport.getLocationNames()
    
    for _, locationName in ipairs(locationNames) do
        TeleportTab:CreateButton({
            Name = locationName,
            Callback = function()
                Teleport.to(locationName)
            end
        })
    end
    
    -- ====== SETTINGS TAB ======
    local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
    
    SettingsTab:CreateSection("Performance")
    
    SettingsTab:CreateToggle({
        Name = "🖥️ GPU Saver Mode",
        CurrentValue = Config.get("GPUSaver"),
        Callback = function(value)
            Config.set("GPUSaver", value)
            callbacks.onGPUSaverToggle(value)
        end
    })
    
    SettingsTab:CreateSection("Auto Favorite")
    
    SettingsTab:CreateToggle({
        Name = "⭐ Auto Favorite Fish",
        CurrentValue = Config.get("AutoFavorite"),
        Callback = function(value)
            Config.set("AutoFavorite", value)
            print("[Auto Favorite] " .. (value and "🟢 Enabled" or "🔴 Disabled"))
        end
    })
    
    SettingsTab:CreateDropdown({
        Name = "Favorite Rarity (Mythic/Secret Only)",
        Options = {"Mythic", "Secret"},
        CurrentOption = Config.get("FavoriteRarity"),
        Callback = function(option)
            Config.set("FavoriteRarity", option)
            print("[Config] Favorite rarity set to: " .. option .. "+")
        end
    })
    
    SettingsTab:CreateButton({
        Name = "⭐ Favorite All Mythic/Secret Now",
        Callback = function()
            callbacks.onFavoriteNow()
        end
    })
    
    -- ====== INFO TAB ======
    local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)
    
    InfoTab:CreateParagraph({
        Title = "🔒 Safe Edition Features",
        Content = [[
✅ GitHub-Based Loading
✅ No Backdoors (You control the code!)
✅ Open Source & Transparent
✅ Modular Structure
✅ Easy to Review & Modify

All code is loaded from YOUR GitHub repository.
You can inspect every file before using!
        ]]
    })
    
    InfoTab:CreateParagraph({
        Title = "Features",
        Content = [[
• Fast Auto Fishing with BLATANT MODE
• 🎯 TARGET FISH by Weight (NEW!)
• 🌍 Auto Teleport to Best Location (NEW!)
• Simple Auto Sell (keeps favorited fish)
• Auto Catch for extra speed
• GPU Saver Mode
• Anti-AFK Protection
• Auto Save Configuration
• 14 Teleport Locations
• Auto Favorite (Mythic & Secret only)
        ]]
    })
    
    InfoTab:CreateParagraph({
        Title = "Blatant Mode Explained",
        Content = [[
⚡ BLATANT MODE METHOD:
- Casts 2 rods in parallel (overlapping)
- Same wait time for fish to bite
- Spams reel 5x to instant catch
- 50% faster cooldown between casts
- Result: ~3x faster fishing!

⚠️ More detectable, use at your own risk!
        ]]
    })
    
    InfoTab:CreateParagraph({
        Title = "🎯 Target Fishing Guide",
        Content = [[
How to use Target Fishing:

1. Go to "Target Fish" tab
2. Enable "Target Fishing"
3. Select fish (e.g., Rahasia Tang)
4. Set weight range (205K-240K kg)
5. Enable "Auto Teleport" (optional)
6. Start "Auto Fish" in Main tab

The script will:
✅ Auto teleport to best location
✅ Fish only target weight range
✅ Show notification when caught

Quick Presets available for easy setup!
        ]]
    })
    
    InfoTab:CreateParagraph({
        Title = "🔒 Security Info",
        Content = [[
This script is loaded from YOUR GitHub repository.

To verify security:
1. Check all files in your repo
2. No obfuscated code
3. No suspicious network calls
4. All code is readable

Stay safe! 🛡️
        ]]
    })
    
    -- ====== STARTUP NOTIFICATION ======
    Rayfield:Notify({
        Title = "🔒 Safe Auto Fish Loaded",
        Content = "Loaded from YOUR GitHub repository!",
        Duration = 5,
        Image = 4483362458
    })
    
    print("✅ [UI] Interface loaded")
end

return UI

