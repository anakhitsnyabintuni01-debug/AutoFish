-- ====================================================================
--                 SAFE AUTO FISH LOADER - CUSTOM GUI VERSION
--          GitHub-Based | Anti-Backdoor | 100% Stable
-- ====================================================================

print("🔒 [Loader] Starting Safe Auto Fish (Custom GUI Edition)...")
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
--                    SAFE ENVIRONMENT CHECK
-- ====================================================================
local function waitForEnvironment()
    print("⏳ [Loader] Waiting for game environment...")
    
    -- Wait for game to be ready
    repeat task.wait(0.5) until game
    repeat task.wait(0.5) until game:GetService("Players")
    repeat task.wait(0.5) until game:GetService("Players").LocalPlayer
    repeat task.wait(0.5) until game:GetService("ReplicatedStorage")
    repeat task.wait(0.5) until game:GetService("CoreGui")
    
    print("✅ [Loader] Environment ready")
end

-- ====================================================================
--                    MODULE LOADER
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
    -- Wait for environment
    task.wait(2)  -- Initial delay
    waitForEnvironment()
    
    print("\n📦 [Loader] Loading modules...")
    
    -- Load core modules
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
    
    -- Load Custom GUI
    print("\n🎨 [Loader] Loading Custom GUI...")
    local UI = loadModule("ui_custom")
    
    -- Load main controller
    print("\n🚀 [Loader] Starting main controller...")
    local Main = loadModule("main")
    
    -- Start main with UI
    Main.start({
        Config = Config,
        Network = Network,
        Fishing = Fishing,
        Teleport = Teleport,
        Target = Target,
        UI = UI
    })
    
    print("\n✅ [Loader] Auto Fish with GUI loaded successfully!")
    print("🔒 [Security] All code loaded from YOUR repository")
    print("🎨 [GUI] Custom GUI ready to use!")
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

