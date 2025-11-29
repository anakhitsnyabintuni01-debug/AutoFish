-- ====================================================================
--                 SAFE AUTO FISH LOADER - NO UI VERSION
--          GitHub-Based | Anti-Backdoor | 100% Stable
-- ====================================================================

print("🔒 [Loader] Starting Safe Auto Fish (No-UI Edition)...")
print("📦 [Loader] Loading from YOUR GitHub repository")

-- ====================================================================
--                    GITHUB CONFIGURATION
-- ====================================================================
local GITHUB_USER = "anakhitsnyabintuni01-debug"
local GITHUB_REPO = "AutoFish"
local GITHUB_BRANCH = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    GITHUB_USER,
    GITHUB_REPO,
    GITHUB_BRANCH
)

print("📍 [Loader] Repository: " .. GITHUB_USER .. "/" .. GITHUB_REPO)

-- ====================================================================
--                    DEPENDENCY CHECK
-- ====================================================================
local function validateEnvironment()
    local required = {
        "game", "workspace", "Players", "RunService", 
        "ReplicatedStorage", "HttpService"
    }
    
    for _, service in ipairs(required) do
        if service == "game" or service == "workspace" then
            if not _G[service] then
                error("❌ Missing: " .. service)
            end
        else
            local success = pcall(function()
                game:GetService(service)
            end)
            if not success then
                error("❌ Missing service: " .. service)
            end
        end
    end
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("❌ LocalPlayer not available")
    end
    
    print("✅ [Loader] Environment validated")
    return true
end

-- ====================================================================
--                    SECURE MODULE LOADER
-- ====================================================================
local LoadedModules = {}

local function loadModule(moduleName)
    if LoadedModules[moduleName] then
        return LoadedModules[moduleName]
    end
    
    local url = BASE_URL .. moduleName .. ".lua"
    print("📥 [Loader] Loading: " .. moduleName)
    
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        
        if not source or source == "" then
            error("Empty response from: " .. url)
        end
        
        local func = loadstring(source)
        if not func then
            error("Failed to compile: " .. moduleName)
        end
        
        return func()
    end)
    
    if not success then
        error("❌ [Loader] Failed to load " .. moduleName .. ": " .. tostring(result))
    end
    
    LoadedModules[moduleName] = result
    print("✅ [Loader] Loaded: " .. moduleName)
    return result
end

-- ====================================================================
--                    MAIN EXECUTION
-- ====================================================================
local function main()
    if not validateEnvironment() then
        return
    end
    
    print("\n📦 [Loader] Loading modules...")
    
    local Config = loadModule("module/config")
    local Network = loadModule("module/network")
    local Fishing = loadModule("module/fishing")
    local Teleport = loadModule("module/teleport")
    local Target = loadModule("module/target")
    
    print("\n🔌 [Loader] Initializing network...")
    if not Network.initialize() then
        error("❌ Failed to initialize network events")
    end
    
    Fishing.initialize(Network)
    
    print("\n⚙️ [Loader] Loading configuration...")
    Config.load()
    
    print("\n✅ [Loader] Auto Fish loaded successfully!")
    print("🔒 [Security] All code loaded from YOUR repository")
    
    -- ====================================================================
    --                    GLOBAL COMMANDS
    -- ====================================================================
    print("\n" .. string.rep("=", 60))
    print("🎣 AUTO FISH COMMANDS (No-UI Version)")
    print(string.rep("=", 60))
    
    -- Auto Fish Commands
    _G.fish_start = function()
        Config.set("AutoFish", true)
        Fishing.start(Config.Current, Config.get("BlatantMode"))
        print("✅ Auto Fish: STARTED")
    end
    
    _G.fish_stop = function()
        Config.set("AutoFish", false)
        Fishing.stop()
        print("❌ Auto Fish: STOPPED")
    end
    
    _G.blatant_on = function()
        Config.set("BlatantMode", true)
        Fishing.setBlatantMode(true)
        print("⚡ Blatant Mode: ON (3x faster!)")
    end
    
    _G.blatant_off = function()
        Config.set("BlatantMode", false)
        Fishing.setBlatantMode(false)
        print("🔴 Blatant Mode: OFF")
    end
    
    -- Teleport Commands
    _G.tp = function(location)
        Teleport.to(location)
    end
    
    _G.tp_list = function()
        print("\n📍 Available Locations:")
        local names = Teleport.getLocationNames()
        for i, name in ipairs(names) do
            print("  " .. i .. ". " .. name)
        end
        print('\nUsage: tp("Ancient Jungle")')
    end
    
    -- Target Fishing Commands
    _G.target_rahasia = function()
        Target.Current.targetFish = "Rahasia Tang"
        Target.Current.minWeight = 205000
        Target.Current.maxWeight = 240000
        Target.setEnabled(true)
        Target.Current.autoTeleport = true
        print("🎯 Target: Rahasia Tang (205K-240K kg)")
        print("🌍 Auto teleport to Ancient Jungle")
        Teleport.to("Ancient Jungle")
    end
    
    _G.target_rahasia_big = function()
        Target.Current.targetFish = "Rahasia Tang"
        Target.Current.minWeight = 280000
        Target.Current.maxWeight = 325000
        Target.setEnabled(true)
        Target.Current.autoTeleport = true
        print("🎯 Target: Rahasia Tang BIG (280K-325K kg)")
        print("🌍 Auto teleport to Ancient Jungle")
        Teleport.to("Ancient Jungle")
    end
    
    _G.target_off = function()
        Target.setEnabled(false)
        print("❌ Target Fishing: OFF")
    end
    
    -- Auto Sell Commands
    _G.sell_on = function()
        Config.set("AutoSell", true)
        print("✅ Auto Sell: ON")
    end
    
    _G.sell_off = function()
        Config.set("AutoSell", false)
        print("❌ Auto Sell: OFF")
    end
    
    _G.sell_now = function()
        local success = pcall(function()
            return Network.Events.sell:InvokeServer()
        end)
        if success then
            print("💰 Sold all items!")
        else
            warn("❌ Sell failed")
        end
    end
    
    -- Help Command
    _G.help = function()
        print("\n" .. string.rep("=", 60))
        print("🎣 COMMAND LIST")
        print(string.rep("=", 60))
        print("\n📌 BASIC COMMANDS:")
        print("  fish_start()          - Start auto fishing")
        print("  fish_stop()           - Stop auto fishing")
        print("  blatant_on()          - Enable blatant mode (3x faster)")
        print("  blatant_off()         - Disable blatant mode")
        print("")
        print("📌 TELEPORT COMMANDS:")
        print('  tp("Ancient Jungle")   - Teleport to location')
        print("  tp_list()             - Show all locations")
        print("")
        print("📌 TARGET FISHING:")
        print("  target_rahasia()      - Target Rahasia Tang 205K-240K")
        print("  target_rahasia_big()  - Target Rahasia Tang BIG 280K-325K")
        print("  target_off()          - Disable target fishing")
        print("")
        print("📌 AUTO SELL:")
        print("  sell_on()             - Enable auto sell")
        print("  sell_off()            - Disable auto sell")
        print("  sell_now()            - Sell all now")
        print("")
        print("📌 QUICK START:")
        print("  1. target_rahasia()   - Setup target fishing")
        print("  2. fish_start()       - Start fishing")
        print("  3. sell_on()          - Enable auto sell")
        print(string.rep("=", 60))
    end
    
    -- Show help on load
    _G.help()
    
    print("\n🎉 Ready to fish! Type help() to see commands again.")
end

-- ====================================================================
--                    ERROR HANDLING
-- ====================================================================
local success, error_msg = pcall(main)

if not success then
    warn("❌ ═══════════════════════════════════════════")
    warn("❌ AUTO FISH FAILED TO LOAD")
    warn("❌ ═══════════════════════════════════════════")
    warn("❌ Error: " .. tostring(error_msg))
    warn("❌ ═══════════════════════════════════════════")
end

