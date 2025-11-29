-- ====================================================================
--                 SAFE AUTO FISH LOADER
--          GitHub-Based | Anti-Backdoor | Open Source
-- ====================================================================
--
-- CARA PAKAI:
-- loadstring(game:HttpGet('https://raw.githubusercontent.com/USERNAME/REPO/main/loader.lua'))()
--
-- Ganti USERNAME dan REPO dengan GitHub Anda!
-- ====================================================================

print("🔒 [Loader] Starting Safe Auto Fish...")
print("📦 [Loader] Loading from YOUR GitHub repository")

-- ====================================================================
--                    GITHUB CONFIGURATION
-- ====================================================================
-- EDIT INI SESUAI GITHUB ANDA:
local GITHUB_USER = "anakhitsnyabintuni01-debug"  -- ⚠️ GANTI INI
local GITHUB_REPO = "AutoFish"      -- ⚠️ GANTI INI
local GITHUB_BRANCH = "main"        -- atau "master"

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
        
        -- Basic security check
        if not source or source == "" then
            error("Empty response from: " .. url)
        end
        
        -- Check for suspicious patterns (optional)
        local suspicious = {
            "require%(game%.HttpGet",  -- Nested loadstring
            "getfenv",                  -- Environment manipulation
            "setfenv",                  -- Environment manipulation
        }
        
        for _, pattern in ipairs(suspicious) do
            if source:match(pattern) then
                warn("⚠️ [Security] Suspicious pattern found in: " .. moduleName)
                warn("⚠️ Pattern: " .. pattern)
            end
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
    -- Step 1: Validate environment
    if not validateEnvironment() then
        return
    end
    
    -- Step 2: Load core modules
    print("\n📦 [Loader] Loading modules...")
    
    local Config = loadModule("module/config")
    local Network = loadModule("module/network")
    local Fishing = loadModule("module/fishing")
    local Teleport = loadModule("module/teleport")
    local Target = loadModule("module/target")
    
    -- Step 3: Initialize network
    print("\n🔌 [Loader] Initializing network...")
    if not Network.initialize() then
        error("❌ Failed to initialize network events")
    end
    
    -- Step 3.5: Initialize fishing with network
    Fishing.initialize(Network)
    
    -- Step 4: Load configuration
    print("\n⚙️ [Loader] Loading configuration...")
    Config.load()
    
    -- Step 5: Wait for CoreGui to be ready
    print("\n⏳ [Loader] Waiting for CoreGui...")
    local CoreGui = game:GetService("CoreGui")
    local StarterGui = game:GetService("StarterGui")
    
    -- Test if we can create UI elements
    local testSuccess = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
    end)
    
    if not testSuccess then
        warn("⚠️ [Loader] CoreGui not ready, waiting...")
        task.wait(5)
    end
    
    print("✅ [Loader] CoreGui ready")
    
    -- Extra safety wait
    task.wait(2)
    
    -- Step 6: Load UI (Mercury - more stable than Rayfield)
    print("\n🎨 [Loader] Loading UI (Mercury)...")
    local UI = loadModule("ui_mercury")
    
    -- Step 7: Start main controller
    print("\n🚀 [Loader] Starting main controller...")
    local Main = loadModule("main")
    Main.start({
        Config = Config,
        Network = Network,
        Fishing = Fishing,
        Teleport = Teleport,
        Target = Target,
        UI = UI
    })
    
    print("\n✅ [Loader] Auto Fish loaded successfully!")
    print("🔒 [Security] All code loaded from YOUR repository")
    print("📖 [Info] Check your GitHub for source code")
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
    warn("❌")
    warn("❌ Possible causes:")
    warn("❌ 1. GitHub URL tidak benar")
    warn("❌ 2. Repository private (harus public)")
    warn("❌ 3. File tidak ada di repository")
    warn("❌ 4. Game tidak compatible")
    warn("❌ ═══════════════════════════════════════════")
end


