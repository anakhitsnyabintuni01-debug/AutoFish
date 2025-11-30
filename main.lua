-- ====================================================================
--                 MAIN CONTROLLER
--          Orchestrates all modules and features
-- ====================================================================

local Main = {}

-- Services
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Module references (will be injected)
local Config, Network, Fishing, Teleport, Target, UI

-- State
local fishingActive = false
local isFishing = false
local favoritedItems = {}

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
local function setupAntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    print("[Anti-AFK] ✅ Protection enabled")
end

-- ====================================================================
--                     GPU SAVER
-- ====================================================================
local gpuActive = false
local gpuScreen = nil

local function enableGPUSaver()
    if gpuActive then return end
    gpuActive = true
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        setfpscap(8)
    end)
    
    gpuScreen = Instance.new("ScreenGui")
    gpuScreen.ResetOnSpawn = false
    gpuScreen.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.Parent = gpuScreen
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 400, 0, 100)
    label.Position = UDim2.new(0.5, -200, 0.5, -50)
    label.BackgroundTransparency = 1
    label.Text = "🟢 GPU SAVER ACTIVE\n\nAuto Fish Running..."
    label.TextColor3 = Color3.new(0, 1, 0)
    label.TextSize = 28
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    gpuScreen.Parent = game.CoreGui
    print("[GPU] ✅ GPU Saver enabled")
end

local function disableGPUSaver()
    if not gpuActive then return end
    gpuActive = false
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 100000
        setfpscap(0)
    end)
    
    if gpuScreen then
        gpuScreen:Destroy()
        gpuScreen = nil
    end
    print("[GPU] ✅ GPU Saver disabled")
end

-- ====================================================================
--                     AUTO FAVORITE
-- ====================================================================
local RarityTiers = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7
}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

local function getFishRarity(itemData)
    if not itemData or not itemData.Data then return "Common" end
    return itemData.Data.Rarity or "Common"
end

local function isItemFavorited(uuid)
    local success, result = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local PlayerData = Replion.Client:WaitReplion("Data")
        
        local items = PlayerData:GetExpect("Inventory").Items
        for _, item in ipairs(items) do
            if item.UUID == uuid then
                return item.Favorited == true
            end
        end
        return false
    end)
    return success and result or false
end

local function autoFavoriteByRarity()
    if not Config.get("AutoFavorite") then return end
    
    local targetRarity = Config.get("FavoriteRarity")
    local targetValue = getRarityValue(targetRarity)
    
    if targetValue < 6 then
        targetValue = 6  -- Minimum Mythic
    end
    
    local favorited = 0
    
    local success = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        local Replion = require(ReplicatedStorage.Packages.Replion)
        local PlayerData = Replion.Client:WaitReplion("Data")
        
        local items = PlayerData:GetExpect("Inventory").Items
        
        if not items or #items == 0 then return end
        
        for i, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local itemName = data.Data.Name or "Unknown"
                local rarity = getFishRarity(data)
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue and rarityValue >= 6 then
                    if not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                        Network.Events.favorite:FireServer(item.UUID)
                        favoritedItems[item.UUID] = true
                        favorited = favorited + 1
                        print("[Auto Favorite] ⭐ #" .. favorited .. " - " .. itemName .. " (" .. rarity .. ")")
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
    
    if favorited > 0 then
        print("[Auto Favorite] ✅ Complete! Favorited: " .. favorited)
    end
end

-- Start auto favorite loop
local function startAutoFavoriteLoop()
    task.spawn(function()
        while true do
            task.wait(10)
            if Config.get("AutoFavorite") then
                autoFavoriteByRarity()
            end
        end
    end)
end

-- ====================================================================
--                     AUTO SELL
-- ====================================================================
local function sellAll()
    print("╔═══════════════════════════════════╗")
    print("[Auto Sell] 💰 Selling all non-favorited items...")
    
    local success = pcall(function()
        return Network.Events.sell:InvokeServer()
    end)
    
    if success then
        print("[Auto Sell] ✅ SOLD! (Favorited fish kept safe)")
    else
        warn("[Auto Sell] ❌ Sell failed")
    end
    print("╚═══════════════════════════════════╝")
end

-- Start auto sell loop
local function startAutoSellLoop()
    task.spawn(function()
        while true do
            task.wait(Config.get("SellDelay"))
            if Config.get("AutoSell") then
                sellAll()
            end
        end
    end)
end

-- ====================================================================
--                     AUTO CATCH (SPAM)
-- ====================================================================
local function startAutoCatchLoop()
    task.spawn(function()
        while true do
            if Config.get("AutoCatch") and not isFishing then
                pcall(function() 
                    Network.Events.fishing:FireServer() 
                end)
            end
            task.wait(Config.get("CatchDelay"))
        end
    end)
end

-- ====================================================================
--                     FISHING CONTROL
-- ====================================================================
local function startFishing()
    print("🔍 [DEBUG] startFishing() called")
    print("🔍 [DEBUG] fishingActive before: " .. tostring(fishingActive))
    
    if fishingActive then 
        print("⚠️ [DEBUG] Already fishing, returning")
        return 
    end
    
    fishingActive = true
    local blatantMode = Config.get("BlatantMode")
    
    print("[Auto Fish] 🟢 Started " .. (blatantMode and "(BLATANT MODE)" or "(Normal)"))
    print("🔍 [DEBUG] Calling Fishing.start()...")
    print("🔍 [DEBUG] Config.Current.FishDelay: " .. tostring(Config.Current.FishDelay))
    print("🔍 [DEBUG] Config.Current.CatchDelay: " .. tostring(Config.Current.CatchDelay))
    
    Fishing.start(Config.Current, blatantMode)
    print("🔍 [DEBUG] Fishing.start() called successfully")
end

local function stopFishing()
    print("🔍 [DEBUG] stopFishing() called")
    
    if not fishingActive then 
        print("⚠️ [DEBUG] Not fishing, returning")
        return 
    end
    
    fishingActive = false
    print("[Auto Fish] 🔴 Stopped")
    
    Fishing.stop()
end

-- ====================================================================
--                     TARGET FISHING
-- ====================================================================
local function onTargetFishCaught(fishName, weight)
    if not Target.Current.enabled then return end
    
    local matches = Target.checkCatch(fishName, weight)
    
    if matches then
        print("╔═══════════════════════════════════╗")
        print("[Target] 🎯 TARGET CAUGHT!")
        print("[Target] 🐟 Fish: " .. fishName)
        print("[Target] ⚖️ Weight: " .. Target.formatWeight(weight))
        print("╚═══════════════════════════════════╝")
        
        -- Optional: Play sound or notification
    else
        print("[Target] ❌ Not target fish (continuing...)")
    end
end

-- Auto teleport to best location for target fish
local function autoTeleportToTarget()
    if not Target.Current.enabled or not Target.Current.autoTeleport then return end
    if not Target.Current.targetFish then return end
    
    local bestLocation = Target.getBestLocation(Target.Current.targetFish)
    if bestLocation then
        print("[Target] 🌍 Auto teleporting to: " .. bestLocation)
        Teleport.to(bestLocation)
        Target.Current.currentLocation = bestLocation
    end
end

-- ====================================================================
--                     PUBLIC API
-- ====================================================================
function Main.start(modules)
    -- Inject dependencies
    Config = modules.Config
    Network = modules.Network
    Fishing = modules.Fishing
    Teleport = modules.Teleport
    Target = modules.Target
    UI = modules.UI
    
    -- Setup core features
    setupAntiAFK()
    
    -- Start background loops
    startAutoFavoriteLoop()
    startAutoSellLoop()
    startAutoCatchLoop()
    
    -- Setup UI callbacks
    UI.setup({
        Config = Config,
        Teleport = Teleport,
        Target = Target,
        onAutoFishToggle = function(enabled)
            print("🔍 [DEBUG] onAutoFishToggle callback triggered!")
            print("🔍 [DEBUG] enabled = " .. tostring(enabled))
            
            if enabled then
                print("🔍 [DEBUG] Calling startFishing()...")
                startFishing()
                
                -- Auto teleport if target fishing enabled
                if Target.Current.enabled and Target.Current.autoTeleport then
                    print("🔍 [DEBUG] Auto teleporting...")
                    autoTeleportToTarget()
                end
            else
                print("🔍 [DEBUG] Calling stopFishing()...")
                stopFishing()
            end
            
            print("🔍 [DEBUG] onAutoFishToggle callback complete")
        end,
        onGPUSaverToggle = function(enabled)
            if enabled then
                enableGPUSaver()
            else
                disableGPUSaver()
            end
        end,
        onSellNow = sellAll,
        onFavoriteNow = autoFavoriteByRarity,
        onTargetTeleport = autoTeleportToTarget
    })
    
    print("✅ [Main] Controller initialized")
end

return Main

