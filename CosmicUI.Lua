local loadingScreenScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/K1NETCX/-/refs/heads/main/Cosmic.Loadingscreen"))()

-- 2. Aguarda o loading terminar
task.wait(3.2)
-- 1. LOADING SCREEN
local loadingScreenScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/K1NETCX/-/refs/heads/main/Cosmic.Loadingscreen"))()
task.wait(3.2)

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- TEMA (PRETO E ROXO)
-- ============================================
local Theme = {
    Background = Color3.fromRGB(8, 8, 16),
    Primary = Color3.fromRGB(156, 39, 176),
    Secondary = Color3.fromRGB(103, 58, 183),
    Accent = Color3.fromRGB(186, 104, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(76, 175, 80),
    Error = Color3.fromRGB(244, 67, 54),
    Warning = Color3.fromRGB(255, 152, 0),
    TabActive = Color3.fromRGB(156, 39, 176),
    TabInactive = Color3.fromRGB(30, 30, 45)
}

-- ============================================
-- OBFUSCAÇÃO DE FUNDO
-- ============================================
local function SetObfuscation(active)
    if active then
        local blur = Instance.new("BlurEffect")
        blur.Name = "CosmicBlur"
        blur.Size = 12
        blur.Parent = Lighting
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "CosmicColor"
        colorCorrection.TintColor = Color3.fromRGB(20, 0, 30)
        colorCorrection.Parent = Lighting
    else
        local blur = Lighting:FindFirstChild("CosmicBlur")
        local colorCorrection = Lighting:FindFirstChild("CosmicColor")
        if blur then blur:Destroy() end
        if colorCorrection then colorCorrection:Destroy() end
    end
end

-- ============================================
-- DETECÇÃO DE PLATAFORMA
-- ============================================
local isMobile = (UserInputService:GetPlatform() == Enum.Platform.IOS or UserInputService:GetPlatform() == Enum.Platform.Android)

local function GetButtonSize()
    return isMobile and 55 or 45
end

local function GetFontSize()
    return isMobile and 16 or 14
end

-- ============================================
-- SISTEMA DE CONFIGURAÇÃO
-- ============================================
local Configs = {}
local ConfigFile = "CosmicConfig.json"

local function LoadConfig()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)
    if success and type(data) == "table" then
        Configs = data
    end
end

local function SaveConfig()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Configs)
    end)
    if success then
        pcall(function() writefile(ConfigFile, encoded) end)
    end
end

local function GetConfig(key, default)
    return Configs[key] ~= nil and Configs[key] or default
end

local function SetConfig(key, value)
    Configs[key] = value
    SaveConfig()
end

LoadConfig()

-- ============================================
-- NOTIFICAÇÕES
-- ============================================
local function Notify(title, message, duration, icon)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 320, 0, 70)
    notification.Position = UDim2.new(1, 10, 0, 10)
    notification.BackgroundColor3 = Theme.Background
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 1
    notification.BorderColor3 = Theme.Primary
    notification.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "✦"
    iconLabel.TextColor3 = Theme.Primary
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Primary
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -50, 1, -30)
    msgLabel.Position = UDim2.new(0, 45, 0, 25)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.Text
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = notification
    
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -330, 0, 10)
    }):Play()
    
    task.wait(duration or 3)
    
    TweenService:Create(notification, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 10, 0, 10)
    }):Play()
    task.wait(0.3)
    notification:Destroy()
end

-- ============================================
-- COSMIC UI
-- ============================================
local Cosmic = {
    Windows = {},
    Theme = Theme,
    Notify = function(self, title, message, duration)
        Notify(title, message, duration, "✦")
    end,
    Success = function(self, message)
        Notify("SUCESSO", message, 2, "✓")
    end,
    Error = function(self, message)
        Notify("ERRO", message, 3, "✕")
    end,
    Warning = function(self, message)
        Notify("ATENÇÃO", message, 2, "⚠")
    end
}

-- ============================================
-- CRIAR JANELA PRINCIPAL
-- ============================================
function Cosmic:CreateWindow(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Cosmic_" .. title:gsub(" ", "_")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Enabled = false
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    local windowWidth = math.min(700, screenSize.X - 100)
    local windowHeight = math.min(550, screenSize.Y - 100)
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    mainFrame.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Bordas
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 2)
    top.BackgroundColor3 = Theme.Primary
    top.BorderSizePixel = 0
    top.Parent = mainFrame
    
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, 0, 0, 2)
    bottom.Position = UDim2.new(0, 0, 1, -2)
    bottom.BackgroundColor3 = Theme.Secondary
    bottom.BorderSizePixel = 0
    bottom.Parent = mainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, GetButtonSize())
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -45, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. title .. " ✦"
    titleText.TextColor3 = Theme.Primary
    titleText.TextSize = GetFontSize() + 2
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, GetButtonSize(), 1, 0)
    closeBtn.Position = UDim2.new(1, -GetButtonSize() - 5, 0, 0)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = isMobile and "−" or "✕"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = isMobile and 24 or 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    -- ============================================
    -- CONTAINER DE ABAS (ESQUERDA)
    -- ============================================
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 140, 1, -GetButtonSize() - 10)
    tabContainer.Position = UDim2.new(0, 10, 0, GetButtonSize() + 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabContainer
    tabList.Padding = UDim.new(0, 8)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- ============================================
    -- CONTAINER DE CONTEÚDO (DIREITA)
    -- ============================================
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -165, 1, -GetButtonSize() - 10)
    contentContainer.Position = UDim2.new(0, 155, 0, GetButtonSize() + 5)
    contentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    contentContainer.BackgroundTransparency = 0.3
    contentContainer.BorderSizePixel = 1
    contentContainer.BorderColor3 = Theme.Secondary
    contentContainer.ScrollBarThickness = 4
    contentContainer.ScrollBarImageColor3 = Theme.Primary
    contentContainer.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentContainer
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- ============================================
    -- SISTEMA DE ABAS
    -- ============================================
    local Tabs = {}
    local CurrentTab = nil
    
    local function SwitchTab(tab)
        if CurrentTab then
            CurrentTab.Container.Visible = false
            TweenService:Create(CurrentTab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.TabInactive,
                BackgroundTransparency = 0.5
            }):Play()
        end
        CurrentTab = tab
        tab.Container.Visible = true
        TweenService:Create(tab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.TabActive,
            BackgroundTransparency = 0.2
        }):Play()
    end
    
    -- ============================================
    -- CRIAR ABA
    -- ============================================
    function Cosmic:CreateTab(name, icon)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 45)
        tabButton.BackgroundColor3 = Theme.TabInactive
        tabButton.BackgroundTransparency = 0.5
        tabButton.BorderSizePixel = 0
        tabButton.Text = "  " .. (icon or "✦") .. "  " .. name
        tabButton.TextColor3 = Theme.Text
        tabButton.TextSize = 13
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = tabContainer
        
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, -20, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = tabContent
        tabLayout.Padding = UDim.new(0, 10)
        tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local function updateHeight()
            task.wait()
            local totalHeight = tabLayout.AbsoluteContentSize.Y + 20
            tabContent.Size = UDim2.new(1, -20, 0, totalHeight)
            contentContainer.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end
        
        tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
        
        local tab = {
            Name = name,
            Button = tabButton,
            Container = tabContent,
            Layout = tabLayout
        }
        
        tabButton.MouseButton1Click:Connect(function()
            SwitchTab(tab)
        end)
        
        table.insert(Tabs, tab)
        
        if not CurrentTab then
            SwitchTab(tab)
        end
        
        return {
            Container = tabContent,
            Layout = tabLayout,
            AddSection = function(self, sectionName)
                return Cosmic:Section(self, sectionName)
            end
        }
    end
    
    -- ============================================
    -- CRIAR SEÇÃO
    -- ============================================
    function Cosmic:Section(parent, title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, -20, 0, 0)
        section.BackgroundTransparency = 1
        section.Parent = parent.Container or parent
        
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 35)
        header.BackgroundColor3 = Theme.Secondary
        header.BackgroundTransparency = 0.85
        header.BorderSizePixel = 0
        header.Text = "◈ " .. title .. " ◈"
        header.TextColor3 = Theme.Primary
        header.TextSize = 14
        header.Font = Enum.Font.GothamBold
        header.Parent = section
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Position = UDim2.new(0, 0, 0, 40)
        content.BackgroundTransparency = 1
        content.Parent = section
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Parent = content
        contentLayout.Padding = UDim.new(0, 8)
        
        local function updateHeight()
            task.wait()
            local total = 40 + contentLayout.AbsoluteContentSize.Y
            section.Size = UDim2.new(1, -20, 0, total)
            if parent.Layout then
                parent.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
            end
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
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Theme.Primary
        btn.Text = label
        btn.TextColor3 = Theme.Text
        btn.TextSize = GetFontSize()
        btn.Font = Enum.Font.Gotham
        btn.Parent = parent.Container
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, BorderColor3 = Theme.Accent}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4, BorderColor3 = Theme.Primary}):Play()
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- ============================================
    -- TOGGLE
    -- ============================================
    function Cosmic:Toggle(parent, label, flag, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.7, 0, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = label
        btn.TextColor3 = Theme.Text
        btn.TextSize = GetFontSize()
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextPadding = UDim.new(0, 15)
        btn.Parent = frame
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, isMobile and 70 or 50, 0, isMobile and 35 or 25)
        indicator.Position = UDim2.new(1, -(isMobile and 80 or 60), 0.5, -(isMobile and 17.5 or 12.5))
        indicator.BackgroundColor3 = Theme.Error
        indicator.BorderSizePixel = 0
        indicator.Parent = frame
        
        local indicatorText = Instance.new("TextLabel")
        indicatorText.Size = UDim2.new(1, 0, 1, 0)
        indicatorText.BackgroundTransparency = 1
        indicatorText.Text = "OFF"
        indicatorText.TextColor3 = Theme.Text
        indicatorText.TextSize = isMobile and 14 or 11
        indicatorText.Font = Enum.Font.GothamBold
        indicatorText.Parent = indicator
        
        local state = GetConfig(flag, default)
        
        local function update()
            local newColor = state and Theme.Success or Theme.Error
            local newText = state and "ON" or "OFF"
            TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
            indicatorText.Text = newText
        end
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            update()
            SetConfig(flag, state)
            if callback then callback(state) end
        end)
        
        update()
        
        return {
            SetState = function(s) state = s; update(); SetConfig(flag, state); if callback then callback(state) end end,
            GetState = function() return state end
        }
    end
    
    -- ============================================
    -- SLIDER
    -- ============================================
    function Cosmic:Slider(parent, label, min, max, default, flag, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, isMobile and 90 or 70)
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 25)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Theme.Text
        labelText.TextSize = GetFontSize()
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.3, 0, 0, 25)
        valueText.Position = UDim2.new(0.7, 0, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.Text = tostring(default)
        valueText.TextColor3 = Theme.Primary
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
        local savedValue = GetConfig(flag, default)
        local percent = (savedValue - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Primary
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, isMobile and 24 or 16, 0, isMobile and 24 or 16)
        handle.Position = UDim2.new(percent, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
        handle.BackgroundColor3 = Theme.Accent
        handle.BorderSizePixel = 0
        handle.Parent = slider
        
        local current = savedValue
        local dragging = false
        
        local function update(posX)
            local rel = math.clamp((posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            current = min + (max - min) * rel
            current = math.floor(current * 100) / 100
            
            fill.Size = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
            valueText.Text = tostring(current)
            SetConfig(flag, current)
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
                SetConfig(flag, current)
                if callback then callback(current) end
            end,
            GetValue = function() return current end
        }
    end
    
    -- ============================================
    -- DROPDOWN
    -- ============================================
    function Cosmic:Dropdown(parent, label, options, multiSelect, flag, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 25)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Theme.Text
        labelText.TextSize = GetFontSize()
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(1, 0, 0, 35)
        dropdownBtn.Position = UDim2.new(0, 0, 0, 30)
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        dropdownBtn.BackgroundTransparency = 0.4
        dropdownBtn.BorderSizePixel = 1
        dropdownBtn.BorderColor3 = Theme.Primary
        dropdownBtn.Text = multiSelect and "Selecione opções..." or "Selecione uma opção..."
        dropdownBtn.TextColor3 = Theme.Text
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
        dropdownList.BorderColor3 = Theme.Primary
        dropdownList.ScrollBarThickness = 4
        dropdownList.Visible = false
        dropdownList.Parent = frame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = dropdownList
        listLayout.Padding = UDim.new(0, 2)
        
        local saved = GetConfig(flag, {})
        local selected = type(saved) == "table" and saved or (multiSelect and {} or {saved})
        
        local function updateText()
            if multiSelect then
                dropdownBtn.Text = #selected == 0 and "Selecione opções..." or table.concat(selected, ", ")
            else
                dropdownBtn.Text = #selected > 0 and selected[1] or "Selecione uma opção..."
            end
            SetConfig(flag, selected)
            if callback then callback(selected) end
        end
        
        local function createOption(opt)
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -10, 0, 35)
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            optBtn.BackgroundTransparency = 0.5
            optBtn.Text = opt
            optBtn.TextColor3 = Theme.Text
            optBtn.TextSize = 13
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = dropdownList
            
            local isSelected = false
            for _, s in pairs(selected) do
                if s == opt then isSelected = true; break end
            end
            if isSelected then
                optBtn.BackgroundColor3 = Theme.Success
                optBtn.BackgroundTransparency = 0.5
            end
            
            optBtn.MouseButton1Click:Connect(function()
                if multiSelect then
                    local index = table.find(selected, opt)
                    if index then
                        table.remove(selected, index)
                        optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    else
                        table.insert(selected, opt)
                        optBtn.BackgroundColor3 = Theme.Success
                    end
                else
                    selected = {opt}
                    for _, btn in pairs(dropdownList:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                        end
                    end
                    optBtn.BackgroundColor3 = Theme.Success
                    dropdownList.Visible = false
                end
                updateText()
            end)
        end
        
        for _, opt in ipairs(options) do
            createOption(opt)
        end
        
        dropdownBtn.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        updateText()
        
        return {
            SetOptions = function(newOptions)
                for _, child in pairs(dropdownList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                selected = {}
                for _, opt in ipairs(newOptions) do
                    createOption(opt)
                end
                updateText()
            end,
            GetSelected = function() return selected end
        }
    end
    
    -- ============================================
    -- KEYBIND
    -- ============================================
    function Cosmic:Keybind(parent, label, defaultKey, flag, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.5, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Theme.Text
        labelText.TextSize = GetFontSize()
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local savedKey = GetConfig(flag, defaultKey)
        local currentKey = savedKey
        local waiting = false
        
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0, 120, 0, 35)
        keyBtn.Position = UDim2.new(1, -130, 0.5, -17.5)
        keyBtn.BackgroundColor3 = Theme.Primary
        keyBtn.BackgroundTransparency = 0.5
        keyBtn.BorderSizePixel = 1
        keyBtn.BorderColor3 = Theme.Primary
        keyBtn.Text = currentKey ~= "None" and currentKey or "Nenhuma"
        keyBtn.TextColor3 = Theme.Text
        keyBtn.TextSize = 12
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.Parent = frame
        
        keyBtn.MouseButton1Click:Connect(function()
            waiting = true
            keyBtn.Text = "..."
            keyBtn.BackgroundColor3 = Theme.Warning
            
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if waiting then
                    local key = input.KeyCode.Name
                    if key ~= "Unknown" then
                        waiting = false
                        currentKey = key
                        keyBtn.Text = key
                        keyBtn.BackgroundColor3 = Theme.Primary
                        SetConfig(flag, key)
                        if callback then callback(key) end
                        conn:Disconnect()
                    end
                end
            end)
        end)
        
        return {GetKey = function() return currentKey end}
    end
    
    -- ============================================
    -- COLOR PICKER
    -- ============================================
    function Cosmic:ColorPicker(parent, label, defaultColor, flag, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.6, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Theme.Text
        labelText.TextSize = GetFontSize()
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local savedColor = GetConfig(flag, defaultColor)
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0, 40, 0, 30)
        colorDisplay.Position = UDim2.new(0.7, 0, 0.5, -15)
        colorDisplay.BackgroundColor3 = savedColor
        colorDisplay.BorderSizePixel = 1
        colorDisplay.BorderColor3 = Theme.Primary
        colorDisplay.Parent = frame
        
        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(0, 60, 0, 30)
        selectBtn.Position = UDim2.new(1, -70, 0.5, -15)
        selectBtn.BackgroundColor3 = Theme.Primary
        selectBtn.BackgroundTransparency = 0.5
        selectBtn.BorderSizePixel = 0
        selectBtn.Text = "Selecionar"
        selectBtn.TextColor3 = Theme.Text
        selectBtn.TextSize = 12
        selectBtn.Font = Enum.Font.GothamBold
        selectBtn.Parent = frame
        
        selectBtn.MouseButton1Click:Connect(function()
            local picker = Instance.new("Frame")
            picker.Size = UDim2.new(0, 250, 0, 300)
            picker.Position = UDim2.new(0.5, -125, 0.5, -150)
            picker.BackgroundColor3 = Theme.Background
            picker.BorderSizePixel = 2
            picker.BorderColor3 = Theme.Primary
            picker.Parent = LocalPlayer.PlayerGui
            
            local R, G, B = savedColor.R * 255, savedColor.G * 255, savedColor.B * 255
            
            local function updateColor()
                local color = Color3.fromRGB(R, G, B)
                colorDisplay.BackgroundColor3 = color
                SetConfig(flag, {R = R, G = G, B = B})
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
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
            confirm.BackgroundColor3 = Theme.Success
            confirm.BackgroundTransparency = 0.3
            confirm.Text = "Confirmar"
            confirm.TextColor3 = Theme.Text
            confirm.Parent = picker
            
            confirm.MouseButton1Click:Connect(function()
                picker:Destroy()
            end)
        end)
        
        return {SetColor = function(c) colorDisplay.BackgroundColor3 = c end}
    end
    
    -- ============================================
    -- INPUT TEXT
    -- ============================================
    function Cosmic:TextInput(parent, label, placeholder, flag, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
        frame.BackgroundTransparency = 1
        frame.Parent = parent.Container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 20)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Theme.Text
        labelText.TextSize = GetFontSize()
        labelText.Font = Enum.Font.Gotham
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = frame
        
        local saved = GetConfig(flag, "")
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, 0, 0, 35)
        input.Position = UDim2.new(0, 0, 0, 25)
        input.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        input.BackgroundTransparency = 0.4
        input.BorderSizePixel = 1
        input.BorderColor3 = Theme.Primary
        input.PlaceholderText = placeholder or "Digite aqui..."
        input.PlaceholderColor3 = Theme.TextDark
        input.Text = saved
        input.TextColor3 = Theme.Text
        input.TextSize = 14
        input.Font = Enum.Font.Gotham
        input.Parent = frame
        
        input.FocusLost:Connect(function()
            SetConfig(flag, input.Text)
            if callback then callback(input.Text) end
        end)
        
        return {
            GetText = function() return input.Text end,
            SetText = function(t) input.Text = t; SetConfig(flag, t) end
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
        label.TextColor3 = color or Theme.TextDark
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
        line.BackgroundColor3 = Theme.Primary
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        line.Parent = parent.Container
        return line
    end
    
    -- ============================================
    -- CONTROLES DA JANELA
    -- ============================================
    local windowObj = {
        Gui = screenGui,
        IsOpen = false,
        Show = function()
            screenGui.Enabled = true
            windowObj.IsOpen = true
            SetObfuscation(true)
        end,
        Hide = function()
            screenGui.Enabled = false
            windowObj.IsOpen = false
            SetObfuscation(false)
        end,
        Toggle = function()
            if windowObj.IsOpen then windowObj:Hide() else windowObj:Show() end
        end,
        Close = function()
            screenGui:Destroy()
            SetObfuscation(false)
        end
    }
    
    closeBtn.MouseButton1Click:Connect(function()
        windowObj:Hide()
    end)
    
    -- Tecla L para PC
    if not isMobile then
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.L then
                windowObj:Toggle()
            end
        end)
        windowObj:Show()
    else
        -- Botão flutuante mobile
        local mobileBtn = Instance.new("ImageButton")
        mobileBtn.Size = UDim2.new(0, 55, 0, 55)
        mobileBtn.Position = UDim2.new(1, -70, 1, -80)
        mobileBtn.BackgroundColor3 = Theme.Primary
        mobileBtn.BackgroundTransparency = 0.2
        mobileBtn.Image = "rbxassetid://5028857084"
        mobileBtn.ImageColor3 = Theme.Primary
        mobileBtn.ImageTransparency = 0.3
        mobileBtn.Parent = LocalPlayer.PlayerGui
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "☰"
        btnText.TextColor3 = Theme.Text
        btnText.TextSize = 28
        btnText.Font = Enum.Font.GothamBold
        btnText.Parent = mobileBtn
        
        mobileBtn.MouseButton1Click:Connect(function()
            windowObj:Toggle()
        end)
        
        windowObj:Hide()
    end
    
    table.insert(Cosmic.Windows, windowObj)
    return windowObj
end

-- ============================================
-- EXPORTAR E INICIALIZAR
-- ============================================
return Cosmic
