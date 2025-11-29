-- ====================================================================
--                 SAFE AUTO FISH LOADER - NO UI VERSION
--          GitHub-Based | Anti-Backdoor | 100% Stable
--          WITH DEBUG MODE
-- ====================================================================

-- DEBUG MODE
local DEBUG = true

local function debug_print(msg)
    if DEBUG then
        print("🔍 [DEBUG] " .. msg)
    end
end

print("🔒 [Loader] Starting Safe Auto Fish (No-UI Edition)...")
print("📦 [Loader] Loading from YOUR GitHub repository")
debug_print("Debug mode enabled")

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
--                    DEPENDENCY CHECK (Simplified)
-- ====================================================================
local function validateEnvironment()
    debug_print("Starting environment validation...")
    
    -- Simple wait for essential services
    print("⏳ [Loader] Waiting for game to be ready...")
    
    debug_print("Checking game...")
    repeat 
        debug_print("Waiting for game... current: " .. tostring(game))
        task.wait(0.5) 
    until game
    debug_print("✅ game exists")
    
    debug_print("Getting Players service...")
    local Players
    repeat 
        local success, result = pcall(function()
            return game:GetService("Players")
        end)
        if success then
            Players = result
            debug_print("✅ Players service: " .. tostring(Players))
        else
            debug_print("⏳ Waiting for Players service...")
        end
        task.wait(0.5)
    until Players
    
    debug_print("Getting LocalPlayer...")
    local LocalPlayer
    repeat 
        local success, result = pcall(function()
            return Players.LocalPlayer
        end)
        if success then
            LocalPlayer = result
            debug_print("✅ LocalPlayer: " .. tostring(LocalPlayer))
        else
            debug_print("⏳ Waiting for LocalPlayer...")
        end
        task.wait(0.5)
    until LocalPlayer
    
    debug_print("Getting ReplicatedStorage...")
    local ReplicatedStorage
    repeat 
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage")
        end)
        if success then
            ReplicatedStorage = result
            debug_print("✅ ReplicatedStorage: " .. tostring(ReplicatedStorage))
        else
            debug_print("⏳ Waiting for ReplicatedStorage...")
        end
        task.wait(0.5)
    until ReplicatedStorage
    
    print("✅ [Loader] Environment validated")
    debug_print("All services ready!")
    return true
end

-- ====================================================================
--                    SECURE MODULE LOADER
-- ====================================================================
local LoadedModules = {}

local function loadModule(moduleName)
    debug_print("Attempting to load: " .. moduleName)
    
    if LoadedModules[moduleName] then
        debug_print("Module already loaded: " .. moduleName)
        return LoadedModules[moduleName]
    end
    
    local url = BASE_URL .. moduleName .. ".lua"
    print("📥 [Loader] Loading: " .. moduleName)
    debug_print("URL: " .. url)
    
    local success, result = pcall(function()
        debug_print("Downloading " .. moduleName .. "...")
        local source = game:HttpGet(url)
        debug_print("Downloaded " .. #source .. " characters")
        
        if not source or source == "" then
            error("Empty response from: " .. url)
        end
        
        debug_print("Compiling " .. moduleName .. "...")
        local func = loadstring(source)
        if not func then
            error("Failed to compile: " .. moduleName)
        end
        
        debug_print("Executing " .. moduleName .. "...")
        return func()
    end)
    
    if not success then
        debug_print("❌ Failed to load " .. moduleName)
        debug_print("Error: " .. tostring(result))
        error("❌ [Loader] Failed to load " .. moduleName .. ": " .. tostring(result))
    end
    
    LoadedModules[moduleName] = result
    print("✅ [Loader] Loaded: " .. moduleName)
    debug_print("Module stored: " .. moduleName)
    return result
end

-- ====================================================================
--                    MAIN EXECUTION
-- ====================================================================
local function main()
    debug_print("=== MAIN EXECUTION START ===")
    
    -- Wait for executor to be ready
    print("⏳ [Loader] Waiting for executor to stabilize...")
    debug_print("Waiting 3 seconds...")
    task.wait(3)
    debug_print("Executor wait complete")
    
    debug_print("Calling validateEnvironment()...")
    if not validateEnvironment() then
        debug_print("❌ Validation failed!")
        return
    end
    debug_print("✅ Validation passed!")
    
    print("\n📦 [Loader] Loading modules...")
    debug_print("About to load Config module...")
    
    local Config = loadModule("module/config")
    debug_print("Config loaded successfully")
    
    debug_print("About to load Network module...")
    local Network = loadModule("module/network")
    debug_print("Network loaded successfully")
    
    debug_print("About to load Fishing module...")
    local Fishing = loadModule("module/fishing")
    debug_print("Fishing loaded successfully")
    
    debug_print("About to load Teleport module...")
    local Teleport = loadModule("module/teleport")
    debug_print("Teleport loaded successfully")
    
    debug_print("About to load Target module...")
    local Target = loadModule("module/target")
    debug_print("Target loaded successfully")
    
    print("\n🔌 [Loader] Initializing network...")
    debug_print("Calling Network.initialize()...")
    if not Network.initialize() then
        debug_print("❌ Network initialization failed!")
        error("❌ Failed to initialize network events")
    end
    debug_print("✅ Network initialized")
    
    debug_print("Calling Fishing.initialize()...")
    Fishing.initialize(Network)
    debug_print("✅ Fishing initialized")
    
    print("\n⚙️ [Loader] Loading configuration...")
    debug_print("Calling Config.load()...")
    Config.load()
    debug_print("✅ Config loaded")
    
    print("\n✅ [Loader] Auto Fish loaded successfully!")
    print("🔒 [Security] All code loaded from YOUR repository")
    debug_print("=== MAIN EXECUTION COMPLETE ===")
    
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
debug_print("Starting error handler...")

local success, error_msg = pcall(main)

if not success then
    debug_print("❌ EXECUTION FAILED!")
    debug_print("Error type: " .. type(error_msg))
    debug_print("Error message: " .. tostring(error_msg))
    
    warn("❌ ═══════════════════════════════════════════")
    warn("❌ AUTO FISH FAILED TO LOAD")
    warn("❌ ═══════════════════════════════════════════")
    warn("❌ Error: " .. tostring(error_msg))
    
    -- Try to extract more info
    if type(error_msg) == "string" then
        if error_msg:find("Missing") then
            warn("❌ Missing dependency detected")
        elseif error_msg:find("404") then
            warn("❌ File not found on GitHub")
        elseif error_msg:find("game") then
            warn("❌ Game environment issue")
        end
    end
    
    warn("❌ ═══════════════════════════════════════════")
else
    debug_print("✅ EXECUTION SUCCESSFUL!")
end

