-- ====================================================================
--                 CUSTOM SIMPLE GUI
--          No External Libraries | 100% Stable | Full Control
-- ====================================================================

local UI = {}

-- Module references (will be injected)
local Config, Teleport, Target
local callbacks = {}

-- ====================================================================
--                     SAFE GUI CREATION
-- ====================================================================
local function createGUI()
    print("🎨 [UI] Creating custom GUI...")
    
    -- Wait for CoreGui to be ready
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Create main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoFishGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🎣 Safe Auto Fish V5.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 5)
    MinCorner.Parent = MinimizeButton
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 500, 0, 40)
            MinimizeButton.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 500, 0, 400)
            MinimizeButton.Text = "−"
        end
    end)
    
    -- Content Frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    ContentFrame.Parent = MainFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentFrame
    
    -- Helper Functions
    local yOffset = 0
    
    local function createSection(name)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(1, -10, 0, 25)
        Section.BackgroundTransparency = 1
        Section.Text = name
        Section.TextColor3 = Color3.fromRGB(100, 200, 255)
        Section.TextSize = 16
        Section.Font = Enum.Font.GothamBold
        Section.TextXAlignment = Enum.TextXAlignment.Left
        Section.LayoutOrder = yOffset
        Section.Parent = ContentFrame
        yOffset = yOffset + 1
        return Section
    end
    
    local function createToggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.LayoutOrder = yOffset
        ToggleFrame.Parent = ContentFrame
        yOffset = yOffset + 1
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 5)
        ToggleCorner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 5)
        BtnCorner.Parent = ToggleButton
        
        local state = default
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            ToggleButton.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
            ToggleButton.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        return ToggleButton
    end
    
    local function createButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.Font = Enum.Font.GothamBold
        Button.BorderSizePixel = 0
        Button.LayoutOrder = yOffset
        Button.Parent = ContentFrame
        yOffset = yOffset + 1
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 5)
        BtnCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    
    -- ====================================================================
    --                     MAIN TAB CONTENT
    -- ====================================================================
    
    createSection("⚡ FISHING CONTROLS")
    
    createToggle("Blatant Mode (3x Faster!)", Config.get("BlatantMode"), function(value)
        Config.set("BlatantMode", value)
        print("[Blatant Mode] " .. (value and "⚡ ON" or "❌ OFF"))
    end)
    
    createToggle("Auto Fish", Config.get("AutoFish"), function(value)
        Config.set("AutoFish", value)
        callbacks.onAutoFishToggle(value)
    end)
    
    createToggle("Auto Catch (Extra Speed)", Config.get("AutoCatch"), function(value)
        Config.set("AutoCatch", value)
        print("[Auto Catch] " .. (value and "✅ ON" or "❌ OFF"))
    end)
    
    createSection("💰 AUTO SELL")
    
    createToggle("Auto Sell (Keeps Favorited)", Config.get("AutoSell"), function(value)
        Config.set("AutoSell", value)
        print("[Auto Sell] " .. (value and "✅ ON" or "❌ OFF"))
    end)
    
    createButton("💰 Sell All Now", function()
        callbacks.onSellNow()
    end)
    
    createSection("🎯 TARGET FISHING")
    
    createToggle("Enable Target Fishing", false, function(value)
        Target.setEnabled(value)
    end)
    
    createButton("🐟 Rahasia Tang (205K-240K kg)", function()
        Target.Current.targetFish = "Rahasia Tang"
        Target.Current.minWeight = 205000
        Target.Current.maxWeight = 240000
        Target.setEnabled(true)
        print("[Target] 🎯 Rahasia Tang (205K-240K)")
    end)
    
    createButton("🐟 Rahasia Tang BIG (280K-325K kg)", function()
        Target.Current.targetFish = "Rahasia Tang"
        Target.Current.minWeight = 280000
        Target.Current.maxWeight = 325000
        Target.setEnabled(true)
        print("[Target] 🎯 Rahasia Tang BIG (280K-325K)")
    end)
    
    createToggle("Auto Teleport to Best Location", false, function(value)
        Target.Current.autoTeleport = value
        print("[Target] " .. (value and "🌍 Auto Teleport ON" or "❌ Auto Teleport OFF"))
    end)
    
    createButton("🌍 Teleport to Target Now", function()
        if callbacks.onTargetTeleport then
            callbacks.onTargetTeleport()
        end
    end)
    
    createSection("🌍 QUICK TELEPORTS")
    
    local quickLocations = {
        "Ancient Jungle",
        "Sisyphus Statue",
        "Coral Reefs",
        "Esoteric Depths",
        "Mount Hallow"
    }
    
    for _, location in ipairs(quickLocations) do
        createButton("📍 " .. location, function()
            Teleport.to(location)
        end)
    end
    
    createSection("⚙️ SETTINGS")
    
    createToggle("GPU Saver Mode", Config.get("GPUSaver"), function(value)
        Config.set("GPUSaver", value)
        callbacks.onGPUSaverToggle(value)
    end)
    
    createToggle("Auto Favorite (Mythic/Secret)", Config.get("AutoFavorite"), function(value)
        Config.set("AutoFavorite", value)
        print("[Auto Favorite] " .. (value and "✅ ON" or "❌ OFF"))
    end)
    
    createButton("⭐ Favorite All Mythic/Secret Now", function()
        callbacks.onFavoriteNow()
    end)
    
    -- Parent to CoreGui
    ScreenGui.Parent = CoreGui
    
    print("✅ [UI] Custom GUI loaded successfully")
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
    
    -- Create GUI with safety
    local success, err = pcall(createGUI)
    
    if not success then
        warn("❌ [UI] Failed to create GUI: " .. tostring(err))
        error("Failed to create custom GUI")
    end
end

return UI

