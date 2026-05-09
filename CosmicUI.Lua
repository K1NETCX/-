local loadingScreenScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/K1NETCX/-/refs/heads/main/Cosmic.Loadingscreen"))()

-- 2. Aguarda o loading terminar
task.wait(3.2)

-- ============================================
-- COSMIC UI LIBRARY v3.0
-- Estilo Rayfield - Syntax Super Limpa
-- GitHub Ready - Sem nada integrado
-- ============================================

local Cosmic = {}

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- ============================================
-- CONFIGURAÇÕES
-- ============================================
Cosmic.Versao = "3.0.0"
Cosmic.Platform = nil
Cosmic.Windows = {}
Cosmic.Configs = {}
Cosmic.ConfigFile = "CosmicConfig"

-- Tema Padrão
Cosmic.Theme = {
    Background = Color3.fromRGB(8, 8, 18),
    Primary = Color3.fromRGB(0, 255, 255),
    Secondary = Color3.fromRGB(255, 0, 255),
    Accent = Color3.fromRGB(255, 255, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 170),
    Success = Color3.fromRGB(0, 255, 0),
    Error = Color3.fromRGB(255, 0, 0),
    Warning = Color3.fromRGB(255, 165, 0)
}

-- ============================================
-- DETECÇÃO DE PLATAFORMA
-- ============================================
local function DetectPlatform()
    local platform = UserInputService:GetPlatform()
    Cosmic.Platform = (platform == Enum.Platform.IOS or platform == Enum.Platform.Android) and "Mobile" or "PC"
    return Cosmic.Platform == "Mobile"
end

local isMobile = DetectPlatform()

-- ============================================
-- SISTEMA DE CONFIGURAÇÃO
-- ============================================
local function LoadConfig()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(Cosmic.ConfigFile .. ".json"))
    end)
    Cosmic.Configs = success and type(data) == "table" and data or {}
end

local function SaveConfig()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Cosmic.Configs)
    end)
    if success then
        pcall(function() writefile(Cosmic.ConfigFile .. ".json", encoded) end)
    end
end

local function GetConfig(key, default)
    return Cosmic.Configs[key] ~= nil and Cosmic.Configs[key] or default
end

local function SetConfig(key, value)
    Cosmic.Configs[key] = value
    SaveConfig()
end

LoadConfig()

-- ============================================
-- FUNÇÕES DE UI
-- ============================================
local function GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

local function GetWindowSize()
    local screen = GetScreenSize()
    if isMobile then
        return {Width = math.min(380, screen.X - 40), Height = math.min(550, screen.Y - 100)}
    else
        return {Width = math.min(600, screen.X - 100), Height = math.min(550, screen.Y - 100)}
    end
end

local function GetButtonSize()
    return isMobile and 55 or 45
end

local function GetFontSize()
    return isMobile and 16 or 14
end

-- ============================================
-- NOTIFICAÇÕES
-- ============================================
function Cosmic:Notify(config)
    local title = config.Title or "Notificação"
    local message = config.Text or ""
    local duration = config.Duration or 3
    local icon = config.Icon or "✦"
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, isMobile and 350 or 300, 0, isMobile and 80 or 60)
    notification.Position = UDim2.new(1, 10, 0, 10)
    notification.BackgroundColor3 = self.Theme.Background
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 1
    notification.BorderColor3 = self.Theme.Primary
    notification.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.Theme.Primary
    iconLabel.TextSize = isMobile and 24 or 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, isMobile and 30 or 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Theme.Primary
    titleLabel.TextSize = GetFontSize()
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -50, 1, -30)
    msgLabel.Position = UDim2.new(0, 45, 0, isMobile and 30 or 25)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = self.Theme.Text
    msgLabel.TextSize = GetFontSize() - 2
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = notification
    
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -(isMobile and 370 or 320), 0, 10)
    }):Play()
    
    task.wait(duration)
    
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 10, 0, 10)
    }):Play()
    task.wait(0.3)
    notification:Destroy()
end

function Cosmic:Success(text, duration)
    self:Notify({Title = "SUCESSO", Text = text, Duration = duration or 2, Icon = "✓"})
end

function Cosmic:Error(text, duration)
    self:Notify({Title = "ERRO", Text = text, Duration = duration or 3, Icon = "✕"})
end

function Cosmic:Warning(text, duration)
    self:Notify({Title = "ATENÇÃO", Text = text, Duration = duration or 2, Icon = "⚠"})
end

-- ============================================
-- CRIAR JANELA
-- ============================================
function Cosmic:Window(title, config)
    local windowSize = GetWindowSize()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Cosmic_" .. title:gsub(" ", "_")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false
    
    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, windowSize.Width, 0, windowSize.Height)
    frame.Position = UDim2.new(0.5, -windowSize.Width/2, 0.5, -windowSize.Height/2)
    frame.BackgroundColor3 = self.Theme.Background
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    -- Bordas
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 2)
    top.BackgroundColor3 = self.Theme.Primary
    top.BorderSizePixel = 0
    top.Parent = frame
    
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, 0, 2)
    bottom.Position = UDim2.new(0, 0, 1, -2)
    bottom.BackgroundColor3 = self.Theme.Secondary
    bottom.BorderSizePixel = 0
    bottom.Parent = frame
    
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, 2, 1, 0)
    left.BackgroundColor3 = self.Theme.Primary
    left.BorderSizePixel = 0
    left.Parent = frame
    
    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, 2, 1, 0)
    right.Position = UDim2.new(1, -2, 0, 0)
    right.BackgroundColor3 = self.Theme.Secondary
    right.BorderSizePixel = 0
    right.Parent = frame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, GetButtonSize())
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -45, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. title .. " ✦"
    titleText.TextColor3 = self.Theme.Primary
    titleText.TextSize = GetFontSize() + 2
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, GetButtonSize(), 1, 0)
    closeBtn.Position = UDim2.new(1, -GetButtonSize() - 5, 0, 0)
    closeBtn.BackgroundColor3 = self.Theme.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = isMobile and "−" or "✕"
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.TextSize = isMobile and 24 or 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    -- Container
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -GetButtonSize() - 10)
    container.Position = UDim2.new(0, 10, 0, GetButtonSize() + 5)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = isMobile and 6 or 4
    container.ScrollBarImageColor3 = self.Theme.Primary
    container.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.Padding = UDim.new(0, isMobile and 12 or 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Arrastar (PC)
    if not isMobile then
        local drag = false
        local dragStart, frameStart
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true
                dragStart = input.Position
                frameStart = frame.Position
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X,
                                            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            end
        end)
    end
    
    local window = {
        Frame = frame,
        Gui = screenGui,
        Container = container,
        Layout = layout,
        
        Show = function()
            screenGui.Enabled = true
            if config and config.OnOpen then config.OnOpen() end
        end,
        
        Hide = function()
            screenGui.Enabled = false
            if config and config.OnClose then config.OnClose() end
        end,
        
        Close = function()
            screenGui:Destroy()
        end
    }
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Hide()
    end)
    
    -- Controles da janela
    if isMobile then
        -- Botão flutuante para mobile
        local mobileBtn = Instance.new("ImageButton")
        mobileBtn.Size = UDim2.new(0, 55, 0, 55)
        mobileBtn.Position = UDim2.new(1, -70, 1, -80)
        mobileBtn.BackgroundColor3 = self.Theme.Primary
        mobileBtn.BackgroundTransparency = 0.2
        mobileBtn.Image = "rbxassetid://5028857084"
        mobileBtn.ImageColor3 = self.Theme.Primary
        mobileBtn.ImageTransparency = 0.3
        mobileBtn.Parent = LocalPlayer.PlayerGui
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "☰"
        btnText.TextColor3 = self.Theme.Text
        btnText.TextSize = 28
        btnText.Font = Enum.Font.GothamBold
        btnText.Parent = mobileBtn
        
        mobileBtn.MouseButton1Click:Connect(function()
            if screenGui.Enabled then
                window:Hide()
            else
                window:Show()
            end
        end)
        
        window:Hide()
    else
        -- Tecla L para PC
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.L then
                if screenGui.Enabled then
                    window:Hide()
                else
                    window:Show()
                end
            end
        end)
        window:Show()
    end
    
    table.insert(Cosmic.Windows, window)
    return window
end

-- ============================================
-- CRIAR SEÇÃO
-- ============================================
function Cosmic:Section(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 0)
    section.BackgroundTransparency = 1
    section.Parent = parent.Container
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
    header.BackgroundColor3 = self.Theme.Primary
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0
    header.Text = "◈ " .. title .. " ◈"
    header.TextColor3 = self.Theme.Primary
    header.TextSize = isMobile and 16 or 14
    header.Font = Enum.Font.GothamBold
    header.Parent = section
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, isMobile and 40 or 35)
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, isMobile and 8 or 5)
    
    local function updateHeight()
        task.wait()
        local total = (isMobile and 40 or 35) + contentLayout.AbsoluteContentSize.Y
        section.Size = UDim2.new(1, -20, 0, total)
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    updateHeight()
    
    return {Container = content}
end

-- ============================================
-- BOTÃO
-- ============================================
function Cosmic:Button(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, GetButtonSize())
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 1
    btn.BorderColor3 = self.Theme.Primary
    btn.Text = label
    btn.TextColor3 = self.Theme.Text
    btn.TextSize = GetFontSize()
    btn.Font = Enum.Font.Gotham
    btn.Parent = parent.Container
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, BorderColor3 = self.Theme.Accent}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, BorderColor3 = self.Theme.Primary}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================
-- TOGGLE
-- ============================================
function Cosmic:Toggle(parent, label, configKey, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.7, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
    btn.Text = label
    btn.TextColor3 = self.Theme.Text
    btn.TextSize = GetFontSize()
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextPadding = UDim.new(0, 15)
    btn.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, isMobile and 70 or 50, 0, isMobile and 35 or 25)
    indicator.Position = UDim2.new(1, -(isMobile and 80 or 60), 0.5, -(isMobile and 17.5 or 12.5))
    indicator.BackgroundColor3 = self.Theme.Error
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    local indicatorText = Instance.new("TextLabel")
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.Text = "OFF"
    indicatorText.TextColor3 = self.Theme.Text
    indicatorText.TextSize = isMobile and 14 or 11
    indicatorText.Font = Enum.Font.GothamBold
    indicatorText.Parent = indicator
    
    local state = GetConfig(configKey, default)
    
    local function update()
        local newColor = state and self.Theme.Success or self.Theme.Error
        local newText = state and "ON" or "OFF"
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        indicatorText.Text = newText
    end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        SetConfig(configKey, state)
        if callback then callback(state) end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, BorderColor3 = self.Theme.Success}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, BorderColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    
    update()
    
    return {
        SetState = function(newState)
            state = newState
            update()
            SetConfig(configKey, state)
            if callback then callback(state) end
        end,
        GetState = function() return state end
    }
end

-- ============================================
-- SLIDER
-- ============================================
function Cosmic:Slider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 90 or 70)
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 0, isMobile and 25 or 20)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.Text
    labelText.TextSize = GetFontSize()
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.3, 0, 0, 25)
    valueText.Position = UDim2.new(0.7, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default)
    valueText.TextColor3 = self.Theme.Primary
    valueText.TextSize = GetFontSize()
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, isMobile and 8 or 4)
    slider.Position = UDim2.new(0, 0, 0, isMobile and 50 or 35)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    local percent = (default - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, isMobile and 24 or 16, 0, isMobile and 24 or 16)
    handle.Position = UDim2.new(percent, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
    handle.BackgroundColor3 = self.Theme.Accent
    handle.BorderSizePixel = 0
    handle.Parent = slider
    
    local current = default
    local dragging = false
    
    local function update(posX)
        local rel = math.clamp((posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        current = min + (max - min) * rel
        current = math.floor(current * 100) / 100
        
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
        valueText.Text = tostring(current)
        
        if callback then callback(current) end
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
        end
    end)
    
    return {
        SetValue = function(val)
            current = math.clamp(val, min, max)
            local newPercent = (current - min) / (max - min)
            fill.Size = UDim2.new(newPercent, 0, 1, 0)
            handle.Position = UDim2.new(newPercent, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
            valueText.Text = tostring(current)
            if callback then callback(current) end
        end,
        GetValue = function() return current end
    }
end

-- ============================================
-- LABEL
-- ============================================
function Cosmic:Label(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or self.Theme.TextDark
    label.TextSize = GetFontSize() - 2
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent.Container
    return label
end

-- ============================================
-- SEPARADOR
-- ============================================
function Cosmic:Separator(parent)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = self.Theme.Primary
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = parent.Container
    return line
end

-- ============================================
-- KEYBIND
-- ============================================
function Cosmic:Keybind(parent, label, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.Text
    labelText.TextSize = GetFontSize()
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 100, 0, 35)
    keyBtn.Position = UDim2.new(1, -110, 0.5, -17.5)
    keyBtn.BackgroundColor3 = self.Theme.Primary
    keyBtn.BackgroundTransparency = 0.5
    keyBtn.BorderSizePixel = 1
    keyBtn.BorderColor3 = self.Theme.Primary
    keyBtn.Text = defaultKey or "None"
    keyBtn.TextColor3 = self.Theme.Text
    keyBtn.TextSize = 12
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Parent = frame
    
    local waiting = false
    local current = defaultKey or "None"
    
    keyBtn.MouseButton1Click:Connect(function()
        waiting = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = self.Theme.Warning
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if waiting then
                local key = input.KeyCode.Name
                if key ~= "Unknown" then
                    waiting = false
                    current = key
                    keyBtn.Text = key
                    keyBtn.BackgroundColor3 = self.Theme.Primary
                    if callback then callback(key) end
                    conn:Disconnect()
                end
            end
        end)
    end)
    
    return {GetKey = function() return current end}
end

-- ============================================
-- DROPDOWN
-- ============================================
function Cosmic:Dropdown(parent, label, options, multiSelect, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 0, 25)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.Text
    labelText.TextSize = GetFontSize()
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, 0, 0, 35)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 30)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    dropdownBtn.BackgroundTransparency = 0.5
    dropdownBtn.BorderSizePixel = 1
    dropdownBtn.BorderColor3 = self.Theme.Primary
    dropdownBtn.Text = multiSelect and "Selecione opções..." or "Selecione uma opção..."
    dropdownBtn.TextColor3 = self.Theme.Text
    dropdownBtn.TextSize = 13
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.TextPadding = UDim.new(0, 10)
    dropdownBtn.Parent = frame
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 0, 150)
    dropdownList.Position = UDim2.new(0, 0, 0, 65)
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    dropdownList.BackgroundTransparency = 0.3
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = self.Theme.Primary
    dropdownList.ScrollBarThickness = 4
    dropdownList.Visible = false
    dropdownList.Parent = frame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    listLayout.Padding = UDim.new(0, 2)
    
    local selected = {}
    
    local function updateText()
        if multiSelect then
            dropdownBtn.Text = #selected == 0 and "Selecione opções..." or table.concat(selected, ", ")
        else
            dropdownBtn.Text = #selected > 0 and selected[1] or "Selecione uma opção..."
        end
        if callback then callback(selected) end
    end
    
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -10, 0, 35)
        optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        optBtn.BackgroundTransparency = 0.5
        optBtn.Text = opt
        optBtn.TextColor3 = self.Theme.Text
        optBtn.TextSize = 13
        optBtn.Font = Enum.Font.Gotham
        optBtn.Parent = dropdownList
        
        optBtn.MouseButton1Click:Connect(function()
            if multiSelect then
                local index = table.find(selected, opt)
                if index then
                    table.remove(selected, index)
                    optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                else
                    table.insert(selected, opt)
                    optBtn.BackgroundColor3 = self.Theme.Success
                    optBtn.BackgroundTransparency = 0.5
                end
            else
                selected = {opt}
                for _, btn in pairs(dropdownList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                optBtn.BackgroundColor3 = self.Theme.Success
                dropdownList.Visible = false
            end
            updateText()
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    return {
        SetOptions = function(newOptions)
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            selected = {}
            for _, opt in ipairs(newOptions) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, -10, 0, 35)
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                optBtn.BackgroundTransparency = 0.5
                optBtn.Text = opt
                optBtn.TextColor3 = self.Theme.Text
                optBtn.TextSize = 13
                optBtn.Font = Enum.Font.Gotham
                optBtn.Parent = dropdownList
                
                optBtn.MouseButton1Click:Connect(function()
                    if multiSelect then
                        local idx = table.find(selected, opt)
                        if idx then
                            table.remove(selected, idx)
                            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                        else
                            table.insert(selected, opt)
                            optBtn.BackgroundColor3 = self.Theme.Success
                        end
                    else
                        selected = {opt}
                        for _, btn in pairs(dropdownList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                            end
                        end
                        optBtn.BackgroundColor3 = self.Theme.Success
                        dropdownList.Visible = false
                    end
                    updateText()
                end)
            end
            updateText()
        end,
        GetSelected = function() return selected end
    }
end

-- ============================================
-- COLOR PICKER
-- ============================================
function Cosmic:ColorPicker(parent, label, defaultColor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.Text
    labelText.TextSize = GetFontSize()
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 40, 0, 30)
    colorDisplay.Position = UDim2.new(0.7, 0, 0.5, -15)
    colorDisplay.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 255)
    colorDisplay.BorderSizePixel = 1
    colorDisplay.BorderColor3 = self.Theme.Primary
    colorDisplay.Parent = frame
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0, 60, 0, 30)
    selectBtn.Position = UDim2.new(1, -70, 0.5, -15)
    selectBtn.BackgroundColor3 = self.Theme.Primary
    selectBtn.BackgroundTransparency = 0.5
    selectBtn.BorderSizePixel = 0
    selectBtn.Text = "Selecionar"
    selectBtn.TextColor3 = self.Theme.Text
    selectBtn.TextSize = 12
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.Parent = frame
    
    selectBtn.MouseButton1Click:Connect(function()
        local picker = Instance.new("Frame")
        picker.Size = UDim2.new(0, 250, 0, 300)
        picker.Position = UDim2.new(0.5, -125, 0.5, -150)
        picker.BackgroundColor3 = self.Theme.Background
        picker.BorderSizePixel = 2
        picker.BorderColor3 = self.Theme.Primary
        picker.Parent = LocalPlayer.PlayerGui
        
        local R, G, B = 255, 0, 0
        
        local function updateColor()
            local color = Color3.fromRGB(R, G, B)
            colorDisplay.BackgroundColor3 = color
            if callback then callback(color) end
        end
        
        local function createSlider(y, color, getVal, setVal)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0.8, 0, 0, 30)
            sliderFrame.Position = UDim2.new(0.1, 0, 0, y)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = picker
            
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0.7, 0, 0, 4)
            slider.Position = UDim2.new(0, 0, 0.5, -2)
            slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            slider.BorderSizePixel = 0
            slider.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(getVal() / 255, 0, 1, 0)
            fill.BackgroundColor3 = color
            fill.BorderSizePixel = 0
            fill.Parent = slider
            
            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 10, 0, 10)
            handle.Position = UDim2.new(getVal() / 255, -5, 0.5, -5)
            handle.BackgroundColor3 = color
            handle.BorderSizePixel = 0
            handle.Parent = slider
            
            local drag = false
            
            local function update(posX)
                local rel = math.clamp((posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local val = math.floor(rel * 255)
                setVal(val)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                handle.Position = UDim2.new(rel, -5, 0.5, -5)
                updateColor()
            end
            
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    drag = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    drag = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input.Position.X)
                end
            end)
            
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    update(input.Position.X)
                end
            end)
        end
        
        createSlider(50, Color3.fromRGB(255, 0, 0), function() return R end, function(v) R = v end)
        createSlider(100, Color3.fromRGB(0, 255, 0), function() return G end, function(v) G = v end)
        createSlider(150, Color3.fromRGB(0, 0, 255), function() return B end, function(v) B = v end)
        
        local confirm = Instance.new("TextButton")
        confirm.Size = UDim2.new(0.4, 0, 0, 40)
        confirm.Position = UDim2.new(0.3, 0, 0, 220)
        confirm.BackgroundColor3 = self.Theme.Success
        confirm.BackgroundTransparency = 0.3
        confirm.Text = "Confirmar"
        confirm.TextColor3 = self.Theme.Text
        confirm.Parent = picker
        
        confirm.MouseButton1Click:Connect(function()
            picker:Destroy()
        end)
        
        updateColor()
    end)
    
    return {SetColor = function(c) colorDisplay.BackgroundColor3 = c end}
end

-- ============================================
-- INPUT TEXT
-- ============================================
function Cosmic:TextInput(parent, label, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.Text
    labelText.TextSize = GetFontSize()
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 35)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    input.BackgroundTransparency = 0.5
    input.BorderSizePixel = 1
    input.BorderColor3 = self.Theme.Primary
    input.PlaceholderText = placeholder or "Digite aqui..."
    input.PlaceholderColor3 = self.Theme.TextDark
    input.Text = ""
    input.TextColor3 = self.Theme.Text
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.Parent = frame
    
    input.FocusLost:Connect(function()
        if callback then callback(input.Text) end
    end)
    
    return {GetText = function() return input.Text end, SetText = function(t) input.Text = t end}
end

-- ============================================
-- FINAL
-- ============================================
return Cosmic
