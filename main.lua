-- Cubzh Avatar Tap Counter Module
-- A beautiful dark UI that displays your avatar and persistent tap counter
-- Mobile friendly and centered design

local mod = {}

-- Configuration
local CONFIG = {
    SAVE_KEY = "total_taps_counter",
    BACKGROUND_COLOR = Color(18, 18, 18, 200), -- Dark semi-transparent
    PANEL_COLOR = Color(32, 32, 36, 255), -- Dark panel
    ACCENT_COLOR = Color(138, 43, 226, 255), -- Purple accent
    TEXT_COLOR = Color(255, 255, 255, 255), -- White text
    SHADOW_COLOR = Color(0, 0, 0, 100), -- Subtle shadow
}

-- State
local totalTaps = 0
local ui = {}
local isInitialized = false

-- Load saved tap count
local function loadTapCount()
    local saved = LocalStorage:Get(CONFIG.SAVE_KEY)
    if saved then
        totalTaps = tonumber(saved) or 0
    end
end

-- Save tap count
local function saveTapCount()
    LocalStorage:Set(CONFIG.SAVE_KEY, tostring(totalTaps))
end

-- Create beautiful gradient effect
local function createGradientBackground(frame)
    local gradient = UI:CreateFrame(Color.Transparent)
    gradient.parentDidResize = function()
        gradient.Width = frame.Width
        gradient.Height = frame.Height
    end
    
    -- Create multiple layers for gradient effect
    for i = 1, 5 do
        local layer = UI:CreateFrame(Color(18 + i * 4, 18 + i * 4, 22 + i * 6, 50 - i * 8))
        layer.parentDidResize = function()
            layer.Width = gradient.Width
            layer.Height = gradient.Height * (1.2 - i * 0.2)
            layer.pos.Y = gradient.Height - layer.Height
        end
        gradient:AddChild(layer)
    end
    
    return gradient
end

-- Create avatar display
local function createAvatarDisplay(parent)
    local avatarContainer = UI:CreateFrame(Color.Transparent)
    avatarContainer.Width = 120
    avatarContainer.Height = 120
    
    -- Avatar background circle
    local avatarBg = UI:CreateFrame(CONFIG.PANEL_COLOR)
    avatarBg.Width = 120
    avatarBg.Height = 120
    avatarBg.pos = {0, 0}
    
    -- Create circular mask effect (simulate with rounded corners)
    avatarBg.LocalPosition = {60, 60, 0}
    
    -- Avatar shadow
    local shadow = UI:CreateFrame(CONFIG.SHADOW_COLOR)
    shadow.Width = 130
    shadow.Height = 130
    shadow.pos = {-5, -5}
    
    avatarContainer:AddChild(shadow)
    avatarContainer:AddChild(avatarBg)
    
    -- Try to get and display player's avatar
    if Player and Player.Head then
        local avatarShape = Shape(Player.Head)
        if avatarShape then
            avatarShape.Scale = 0.8
            avatarShape.LocalPosition = {60, 60, 10}
            -- Note: In actual Cubzh, you'd use proper 3D positioning
        end
    end
    
    -- Pulsing effect on tap
    avatarContainer.pulse = function()
        local originalScale = avatarContainer.LocalScale or {1, 1, 1}
        avatarContainer:LocalScaleTo({1.1, 1.1, 1.1}, 0.1, function()
            avatarContainer:LocalScaleTo(originalScale, 0.1)
        end)
    end
    
    return avatarContainer
end

-- Create tap counter display
local function createTapCounter(parent)
    local counterContainer = UI:CreateFrame(Color.Transparent)
    counterContainer.Width = 280
    counterContainer.Height = 80
    
    -- Background panel
    local panel = UI:CreateFrame(CONFIG.PANEL_COLOR)
    panel.Width = 280
    panel.Height = 80
    panel.pos = {0, 0}
    
    -- Accent border
    local border = UI:CreateFrame(CONFIG.ACCENT_COLOR)
    border.Width = 280
    border.Height = 3
    border.pos = {0, 77}
    
    -- Counter text
    local counterText = UI:CreateText("Total Taps: " .. totalTaps, CONFIG.TEXT_COLOR)
    counterText.Font = "arial"
    counterText.FontSize = 24
    counterText.pos = {20, 40}
    
    -- Subtitle
    local subtitle = UI:CreateText("Keep tapping to increase!", Color(180, 180, 180))
    subtitle.Font = "arial"
    subtitle.FontSize = 14
    subtitle.pos = {20, 15}
    
    counterContainer:AddChild(panel)
    counterContainer:AddChild(border)
    counterContainer:AddChild(counterText)
    counterContainer:AddChild(subtitle)
    
    -- Update function
    counterContainer.updateCount = function()
        counterText.Text = "Total Taps: " .. totalTaps
        
        -- Flash effect on update
        counterText.Color = CONFIG.ACCENT_COLOR
        Timer(0.2, function()
            counterText.Color = CONFIG.TEXT_COLOR
        end)
    end
    
    return counterContainer
end

-- Create tap button
local function createTapButton(parent)
    local button = UI:CreateButton("TAP ME!")
    button.Width = 200
    button.Height = 60
    button.Color = CONFIG.ACCENT_COLOR
    button.ColorPressed = Color(110, 30, 200)
    button.TextColor = Color.White
    button.Font = "arial"
    button.FontSize = 20
    
    -- Button styling
    local buttonShadow = UI:CreateFrame(CONFIG.SHADOW_COLOR)
    buttonShadow.Width = 210
    buttonShadow.Height = 70
    buttonShadow.pos = {-5, -5}
    
    parent:AddChild(buttonShadow)
    parent:AddChild(button)
    
    -- Tap handler
    button.OnPress = function()
        totalTaps = totalTaps + 1
        saveTapCount()
        
        if ui.counterContainer then
            ui.counterContainer.updateCount()
        end
        
        if ui.avatarContainer then
            ui.avatarContainer.pulse()
        end
        
        -- Haptic feedback (if supported)
        if System and System.Vibrate then
            System.Vibrate(50)
        end
    end
    
    return button
end

-- Main UI creation
local function createUI()
    if isInitialized then return end
    
    -- Main container
    ui.mainContainer = UI:CreateFrame(Color.Transparent)
    ui.mainContainer.Width = Screen.Width
    ui.mainContainer.Height = Screen.Height
    
    -- Background
    ui.background = createGradientBackground(ui.mainContainer)
    ui.mainContainer:AddChild(ui.background)
    
    -- Content panel
    ui.contentPanel = UI:CreateFrame(Color.Transparent)
    ui.contentPanel.Width = 320
    ui.contentPanel.Height = 400
    ui.contentPanel.pos = {(Screen.Width - 320) / 2, (Screen.Height - 400) / 2}
    
    -- Title
    local title = UI:CreateText("My Cubzh Stats", CONFIG.TEXT_COLOR)
    title.Font = "arial"
    title.FontSize = 28
    title.pos = {80, 350}
    ui.contentPanel:AddChild(title)
    
    -- Avatar display
    ui.avatarContainer = createAvatarDisplay(ui.contentPanel)
    ui.avatarContainer.pos = {100, 200}
    ui.contentPanel:AddChild(ui.avatarContainer)
    
    -- Tap counter
    ui.counterContainer = createTapCounter(ui.contentPanel)
    ui.counterContainer.pos = {20, 100}
    ui.contentPanel:AddChild(ui.counterContainer)
    
    -- Tap button
    ui.tapButton = createTapButton(ui.contentPanel)
    ui.tapButton.pos = {60, 20}
    
    ui.mainContainer:AddChild(ui.contentPanel)
    
    -- Handle screen resizing for mobile
    ui.mainContainer.parentDidResize = function()
        ui.mainContainer.Width = Screen.Width
        ui.mainContainer.Height = Screen.Height
        ui.contentPanel.pos = {(Screen.Width - 320) / 2, (Screen.Height - 400) / 2}
    end
    
    isInitialized = true
end

-- Module functions
function mod:init()
    loadTapCount()
    createUI()
    print("Avatar Tap Counter Module loaded! Total taps: " .. totalTaps)
end

function mod:onStart()
    if not isInitialized then
        self:init()
    end
end

function mod:onStop()
    saveTapCount()
    if ui.mainContainer then
        ui.mainContainer:Remove()
    end
    isInitialized = false
    print("Avatar Tap Counter Module stopped. Progress saved!")
end

-- Public API
function mod:getTotalTaps()
    return totalTaps
end

function mod:resetTaps()
    totalTaps = 0
    saveTapCount()
    if ui.counterContainer then
        ui.counterContainer.updateCount()
    end
end

function mod:addTaps(amount)
    totalTaps = totalTaps + (amount or 1)
    saveTapCount()
    if ui.counterContainer then
        ui.counterContainer.updateCount()
    end
end

-- Export module
return mod
