local loadingScreenScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/K1NETCX/-/refs/heads/main/Cosmic.Loadingscreen"))()

-- 2. Aguarda o loading terminar
task.wait(3.2)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

-- ============================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================
local Cosmic = {
    Versao = "3.0.0",
    Platform = nil,
    Windows = {},
    ActiveWindow = nil,
    Configs = {},
    ConfigFile = "CosmicUI_Config",
    Notifications = {},
    RichPresence = nil,
    IsOpen = false,
    CurrentWindow = nil,
    
    Theme = {
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
-- SISTEMA DE CONFIGURAÇÃO (JSON SAVING)
-- ============================================
local function LoadConfig()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(Cosmic.ConfigFile .. ".json"))
    end)
    
    if success and type(data) == "table" then
        Cosmic.Configs = data
        return true
    end
    
    Cosmic.Configs = {}
    return false
end

local function SaveConfig()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Cosmic.Configs)
    end)
    
    if success then
        pcall(function()
            writefile(Cosmic.ConfigFile .. ".json", encoded)
        end)
    end
end

local function GetConfigValue(key, defaultValue)
    if Cosmic.Configs[key] ~= nil then
        return Cosmic.Configs[key]
    end
    return defaultValue
end

local function SetConfigValue(key, value)
    Cosmic.Configs[key] = value
    SaveConfig()
end

-- ============================================
-- SISTEMA DE NOTIFICAÇÕES (RAYFIELD STYLE)
-- ============================================
function Cosmic:Notify(Config)
    local title = Config.Title or "Notificação"
    local message = Config.Text or ""
    local duration = Config.Duration or 3
    local icon = Config.Icon or "✦"
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, isMobile and 350 or 300, 0, isMobile and 80 or 60)
    notification.Position = UDim2.new(1, -(isMobile and 370 or 320), 0, 10)
    notification.BackgroundColor3 = self.Theme.Background
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 1
    notification.BorderColor3 = self.Theme.Primary
    notification.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Ícone
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.Theme.Primary
    iconLabel.TextSize = isMobile and 24 or 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    -- Título
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
    
    -- Mensagem
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
    
    -- Animação
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

function Cosmic:Success(Text, Duration)
    self:Notify({Title = "SUCESSO", Text = Text, Duration = Duration or 2, Icon = "✓"})
end

function Cosmic:Error(Text, Duration)
    self:Notify({Title = "ERRO", Text = Text, Duration = Duration or 3, Icon = "✕"})
end

function Cosmic:Warning(Text, Duration)
    self:Notify({Title = "ATENÇÃO", Text = Text, Duration = Duration or 2, Icon = "⚠"})
end

-- ============================================
-- DISCORD RICH PRESENCE
-- ============================================
local function SetupRichPresence()
    local DiscordLib = {}
    
    pcall(function()
        DiscordLib = require(script:WaitForChild("DiscordLib") or Instance.new("ModuleScript"))
    end)
    
    if DiscordLib and DiscordLib.Start then
        DiscordLib:Start({
            client_id = "YOUR_CLIENT_ID_HERE",
            large_image = "cosmic_logo",
            large_text = "Cosmic UI v3.0"
        })
        
        local presence = {
            state = "Usando Cosmic UI",
            details = "Menu Carregado",
            startTimestamp = os.time()
        }
        
        DiscordLib:UpdatePresence(presence)
        
        Cosmic.RichPresence = DiscordLib
        
        return true
    end
    
    return false
end

function Cosmic:UpdatePresence(Details, State, ImageText)
    if Cosmic.RichPresence and Cosmic.RichPresence.UpdatePresence then
        Cosmic.RichPresence:UpdatePresence({
            details = Details or "Navegando no Menu",
            state = State or "Cosmic UI v" .. self.Versao,
            large_text = ImageText or "Cosmic UI Evolved"
        })
    end
end

function Cosmic:CopyInvite(InviteCode)
    if setclipboard then
        setclipboard("https://discord.gg/" .. InviteCode)
        self:Success("Convite copiado! " .. "discord.gg/" .. InviteCode)
    else
        self:Error("Executor não suporta clipboard!")
    end
end

-- ============================================
-- FUNÇÕES DE UI (ADAPTADAS)
-- ============================================
local function GetScreenSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    return {X = viewport.X, Y = viewport.Y}
end

local function GetWindowSize()
    local screen = GetScreenSize()
    if isMobile then
        return {
            Width = math.min(380, screen.X - 40),
            Height = math.min(550, screen.Y - 100)
        }
    else
        return {
            Width = math.min(600, screen.X - 100),
            Height = math.min(550, screen.Y - 100)
        }
    end
end

local function GetButtonSize()
    return isMobile and 55 or 45
end

local function GetFontSize()
    return isMobile and 16 or 14
end

-- ============================================
-- COLOR PICKER
-- ============================================
function Cosmic:ColorPicker(Parent, Label, DefaultColor, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = Label
    label.TextColor3 = Cosmic.Theme.Text
    label.TextSize = GetFontSize()
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 40, 0, 30)
    colorDisplay.Position = UDim2.new(0.7, 0, 0.5, -15)
    colorDisplay.BackgroundColor3 = DefaultColor or Color3.fromRGB(255, 0, 255)
    colorDisplay.BorderSizePixel = 1
    colorDisplay.BorderColor3 = Cosmic.Theme.Primary
    colorDisplay.Parent = frame
    
    local selectButton = Instance.new("TextButton")
    selectButton.Size = UDim2.new(0, 60, 0, 30)
    selectButton.Position = UDim2.new(1, -70, 0.5, -15)
    selectButton.BackgroundColor3 = Cosmic.Theme.Primary
    selectButton.BackgroundTransparency = 0.5
    selectButton.BorderSizePixel = 0
    selectButton.Text = "Selecionar"
    selectButton.TextColor3 = Cosmic.Theme.Text
    selectButton.TextSize = 12
    selectButton.Font = Enum.Font.GothamBold
    selectButton.Parent = frame
    
    selectButton.MouseButton1Click:Connect(function()
        local ColorPickerFrame = Instance.new("Frame")
        ColorPickerFrame.Size = UDim2.new(0, 250, 0, 300)
        ColorPickerFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
        ColorPickerFrame.BackgroundColor3 = Cosmic.Theme.Background
        ColorPickerFrame.BorderSizePixel = 2
        ColorPickerFrame.BorderColor3 = Cosmic.Theme.Primary
        ColorPickerFrame.Parent = LocalPlayer.PlayerGui
        
        local R, G, B = 255, 0, 255
        local RSlider, GSlider, BSlider
        
        local function UpdateColor()
            local color = Color3.fromRGB(R, G, B)
            colorDisplay.BackgroundColor3 = color
            if Callback then Callback(color) end
        end
        
        local function CreateSlider(parent, y, color)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0.8, 0, 0, 30)
            sliderFrame.Position = UDim2.new(0.1, 0, 0, y)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = parent
            
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0.7, 0, 0, 4)
            slider.Position = UDim2.new(0, 0, 0.5, -2)
            slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            slider.BorderSizePixel = 0
            slider.Parent = sliderFrame
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0.5, 0, 1, 0)
            fill.BackgroundColor3 = color
            fill.BorderSizePixel = 0
            fill.Parent = slider
            
            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 10, 0, 10)
            handle.Position = UDim2.new(0.5, -5, 0.5, -5)
            handle.BackgroundColor3 = color
            handle.BorderSizePixel = 0
            handle.Parent = slider
            
            return {Slider = slider, Fill = fill, Handle = handle}
        end
        
        local RSliderObj = CreateSlider(ColorPickerFrame, 50, Color3.fromRGB(255, 0, 0))
        local GSliderObj = CreateSlider(ColorPickerFrame, 100, Color3.fromRGB(0, 255, 0))
        local BSliderObj = CreateSlider(ColorPickerFrame, 150, Color3.fromRGB(0, 0, 255))
        
        local confirm = Instance.new("TextButton")
        confirm.Size = UDim2.new(0.4, 0, 0, 40)
        confirm.Position = UDim2.new(0.3, 0, 0, 220)
        confirm.BackgroundColor3 = Cosmic.Theme.Success
        confirm.BackgroundTransparency = 0.3
        confirm.Text = "Confirmar"
        confirm.TextColor3 = Cosmic.Theme.Text
        confirm.Parent = ColorPickerFrame
        
        confirm.MouseButton1Click:Connect(function()
            ColorPickerFrame:Destroy()
        end)
        
        UpdateColor()
    end)
    
    return {SetColor = function(c) colorDisplay.BackgroundColor3 = c end}
end

-- ============================================
-- KEYBIND
-- ============================================
function Cosmic:Keybind(Parent, Label, DefaultKey, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = Label
    label.TextColor3 = Cosmic.Theme.Text
    label.TextSize = GetFontSize()
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0, 100, 0, 35)
    keyButton.Position = UDim2.new(1, -110, 0.5, -17.5)
    keyButton.BackgroundColor3 = Cosmic.Theme.Primary
    keyButton.BackgroundTransparency = 0.5
    keyButton.BorderSizePixel = 1
    keyButton.BorderColor3 = Cosmic.Theme.Primary
    keyButton.Text = DefaultKey or "None"
    keyButton.TextColor3 = Cosmic.Theme.Text
    keyButton.TextSize = 12
    keyButton.Font = Enum.Font.GothamBold
    keyButton.Parent = frame
    
    local waiting = false
    local currentKey = DefaultKey or "None"
    
    keyButton.MouseButton1Click:Connect(function()
        waiting = true
        keyButton.Text = "..."
        keyButton.BackgroundColor3 = Cosmic.Theme.Warning
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if waiting then
                local key = input.KeyCode.Name
                if key ~= "Unknown" then
                    waiting = false
                    currentKey = key
                    keyButton.Text = key
                    keyButton.BackgroundColor3 = Cosmic.Theme.Primary
                    if Callback then Callback(key) end
                    connection:Disconnect()
                end
            end
        end)
    end)
    
    return {GetKey = function() return currentKey end}
end

-- ============================================
-- DROPDOWN MULTI-SELEÇÃO
-- ============================================
function Cosmic:Dropdown(Parent, Label, Options, MultiSelect, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = Label
    label.TextColor3 = Cosmic.Theme.Text
    label.TextSize = GetFontSize()
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 0, 35)
    dropdownButton.Position = UDim2.new(0, 0, 0, 30)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    dropdownButton.BackgroundTransparency = 0.5
    dropdownButton.BorderSizePixel = 1
    dropdownButton.BorderColor3 = Cosmic.Theme.Primary
    dropdownButton.Text = MultiSelect and "Selecione opções..." or "Selecione uma opção..."
    dropdownButton.TextColor3 = Cosmic.Theme.Text
    dropdownButton.TextSize = 13
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.TextPadding = UDim.new(0, 10)
    dropdownButton.Parent = frame
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 0, 150)
    dropdownList.Position = UDim2.new(0, 0, 0, 65)
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    dropdownList.BackgroundTransparency = 0.3
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = Cosmic.Theme.Primary
    dropdownList.ScrollBarThickness = 4
    dropdownList.Visible = false
    dropdownList.Parent = frame
    
    local dropdownLayout = Instance.new("UIListLayout")
    dropdownLayout.Parent = dropdownList
    dropdownLayout.Padding = UDim.new(0, 2)
    
    local selectedOptions = {}
    
    local function UpdateSelectedText()
        if MultiSelect then
            if #selectedOptions == 0 then
                dropdownButton.Text = "Selecione opções..."
            else
                dropdownButton.Text = table.concat(selectedOptions, ", ")
            end
        else
            dropdownButton.Text = #selectedOptions > 0 and selectedOptions[1] or "Selecione uma opção..."
        end
        if Callback then Callback(selectedOptions) end
    end
    
    local function CreateOption(option)
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -10, 0, 35)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        optionButton.BackgroundTransparency = 0.5
        optionButton.Text = option
        optionButton.TextColor3 = Cosmic.Theme.Text
        optionButton.TextSize = 13
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = dropdownList
        
        optionButton.MouseButton1Click:Connect(function()
            if MultiSelect then
                local index = table.find(selectedOptions, option)
                if index then
                    table.remove(selectedOptions, index)
                    optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                else
                    table.insert(selectedOptions, option)
                    optionButton.BackgroundColor3 = Cosmic.Theme.Success
                    optionButton.BackgroundTransparency = 0.5
                end
            else
                selectedOptions = {option}
                for _, btn in pairs(dropdownList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                optionButton.BackgroundColor3 = Cosmic.Theme.Success
                dropdownList.Visible = false
            end
            UpdateSelectedText()
        end)
    end
    
    for _, option in ipairs(Options) do
        CreateOption(option)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
    end)
    
    return {
        SetOptions = function(newOptions)
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            selectedOptions = {}
            for _, opt in ipairs(newOptions) do
                CreateOption(opt)
            end
            UpdateSelectedText()
        end,
        GetSelected = function() return selectedOptions end
    }
end

-- ============================================
-- INPUT TEXT
-- ============================================
function Cosmic:TextInput(Parent, Label, Placeholder, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = Label
    label.TextColor3 = Cosmic.Theme.Text
    label.TextSize = GetFontSize()
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 35)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    input.BackgroundTransparency = 0.5
    input.BorderSizePixel = 1
    input.BorderColor3 = Cosmic.Theme.Primary
    input.PlaceholderText = Placeholder or "Digite aqui..."
    input.PlaceholderColor3 = Cosmic.Theme.TextDark
    input.Text = ""
    input.TextColor3 = Cosmic.Theme.Text
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.Parent = frame
    
    input.FocusLost:Connect(function()
        if Callback then Callback(input.Text) end
    end)
    
    return {GetText = function() return input.Text end, SetText = function(t) input.Text = t end}
end

-- ============================================
-- SLIDER AVANÇADO
-- ============================================
function Cosmic:Slider(Parent, Label, Min, Max, Default, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, isMobile and 90 or 70)
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, isMobile and 25 or 20)
    label.BackgroundTransparency = 1
    label.Text = Label
    label.TextColor3 = Cosmic.Theme.Text
    label.TextSize = GetFontSize()
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Default)
    valueLabel.TextColor3 = Cosmic.Theme.Primary
    valueLabel.TextSize = GetFontSize()
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, isMobile and 8 or 4)
    slider.Position = UDim2.new(0, 0, 0, isMobile and 50 or 35)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    local percent = (Default - Min) / (Max - Min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Cosmic.Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, isMobile and 24 or 16, 0, isMobile and 24 or 16)
    handle.Position = UDim2.new(percent, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
    handle.BackgroundColor3 = Cosmic.Theme.Accent
    handle.BorderSizePixel = 0
    handle.Parent = slider
    
    local currentValue = Default
    local dragging = false
    
    local function UpdateSlider(posX)
        local relative = math.clamp((posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        currentValue = Min + (Max - Min) * relative
        currentValue = math.floor(currentValue * 100) / 100
        
        fill.Size = UDim2.new(relative, 0, 1, 0)
        handle.Position = UDim2.new(relative, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
        valueLabel.Text = tostring(currentValue)
        
        if Callback then Callback(currentValue) end
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end)
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input.Position.X)
        end
    end)
    
    return {
        SetValue = function(val)
            currentValue = math.clamp(val, Min, Max)
            local newPercent = (currentValue - Min) / (Max - Min)
            fill.Size = UDim2.new(newPercent, 0, 1, 0)
            handle.Position = UDim2.new(newPercent, -(isMobile and 12 or 8), 0.5, -(isMobile and 12 or 8))
            valueLabel.Text = tostring(currentValue)
            if Callback then Callback(currentValue) end
        end,
        GetValue = function() return currentValue end
    }
end

-- ============================================
-- TOGGLE (COM SAVE)
-- ============================================
function Cosmic:Toggle(Parent, Label, ConfigKey, Default, Callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, GetButtonSize())
    frame.BackgroundTransparency = 1
    frame.Parent = Parent.Container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.7, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(60, 60, 80)
    button.Text = Label
    button.TextColor3 = Cosmic.Theme.Text
    button.TextSize = GetFontSize()
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextPadding = UDim.new(0, 15)
    button.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, isMobile and 70 or 50, 0, isMobile and 35 or 25)
    indicator.Position = UDim2.new(1, -(isMobile and 80 or 60), 0.5, -(isMobile and 17.5 or 12.5))
    indicator.BackgroundColor3 = Cosmic.Theme.Error
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    local indicatorText = Instance.new("TextLabel")
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.Text = "OFF"
    indicatorText.TextColor3 = Cosmic.Theme.Text
    indicatorText.TextSize = isMobile and 14 or 11
    indicatorText.Font = Enum.Font.GothamBold
    indicatorText.Parent = indicator
    
    local savedValue = GetConfigValue(ConfigKey, Default)
    local state = savedValue
    
    local function UpdateToggle()
        local newColor = state and Cosmic.Theme.Success or Cosmic.Theme.Error
        local newText = state and "ON" or "OFF"
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        indicatorText.Text = newText
    end
    
    button.MouseButton1Click:Connect(function()
        state = not state
        UpdateToggle()
        SetConfigValue(ConfigKey, state)
        if Callback then Callback(state) end
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, BorderColor3 = Cosmic.Theme.Success}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, BorderColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    
    UpdateToggle()
    
    return {
        SetState = function(newState)
            state = newState
            UpdateToggle()
            SetConfigValue(ConfigKey, state)
            if Callback then Callback(state) end
        end,
        GetState = function() return state end
    }
end

-- ============================================
-- BOTÃO
-- ============================================
function Cosmic:Button(Parent, Label, Callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, GetButtonSize())
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 1
    button.BorderColor3 = Cosmic.Theme.Primary
    button.Text = Label
    button.TextColor3 = Cosmic.Theme.Text
    button.TextSize = GetFontSize()
    button.Font = Enum.Font.Gotham
    button.Parent = Parent.Container
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, BorderColor3 = Cosmic.Theme.Accent}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, BorderColor3 = Cosmic.Theme.Primary}):Play()
    end)
    
    button.MouseButton1Click:Connect(Callback)
    
    return button
end

-- ============================================
-- LABEL
-- ============================================
function Cosmic:Label(Parent, Text, Color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 25)
    label.BackgroundTransparency = 1
    label.Text = Text
    label.TextColor3 = Color or Cosmic.Theme.TextDark
    label.TextSize = GetFontSize() - 2
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Parent.Container
    
    return label
end

-- ============================================
-- SEPARADOR
-- ============================================
function Cosmic:Separator(Parent)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = Cosmic.Theme.Primary
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = Parent.Container
    
    return line
end

-- ============================================
-- CRIAR SEÇÃO
-- ============================================
function Cosmic:Section(Parent, Title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 0)
    section.BackgroundTransparency = 1
    section.Parent = Parent.Container
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
    header.BackgroundColor3 = Cosmic.Theme.Primary
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0
    header.Text = "◈ " .. Title .. " ◈"
    header.TextColor3 = Cosmic.Theme.Primary
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
        task.wait(0.05)
        local totalHeight = (isMobile and 40 or 35) + contentLayout.AbsoluteContentSize.Y
        section.Size = UDim2.new(1, -20, 0, totalHeight)
        if Parent.Layout then
            Parent.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
        end
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    updateHeight()
    
    return {
        Type = "Section",
        Container = content,
        Layout = contentLayout
    }
end

-- ============================================
-- CRIAR JANELA PRINCIPAL
-- ============================================
function Cosmic:Window(Title, Config)
    LoadConfig()
    
    local windowSize = GetWindowSize()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CosmicWindow_" .. Title:gsub(" ", "_")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, windowSize.Width, 0, windowSize.Height)
    frame.Position = UDim2.new(0.5, -windowSize.Width/2, 0.5, -windowSize.Height/2)
    frame.BackgroundColor3 = Cosmic.Theme.Background
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    -- Bordas neon
    local topBorder = Instance.new("Frame")
    topBorder.Size = UDim2.new(1, 0, 0, 2)
    topBorder.BackgroundColor3 = Cosmic.Theme.Primary
    topBorder.BorderSizePixel = 0
    topBorder.Parent = frame
    
    local bottomBorder = Instance.new("Frame")
    bottomBorder.Size = UDim2.new(1, 0, 0, 2)
    bottomBorder.Position = UDim2.new(0, 0, 1, -2)
    bottomBorder.BackgroundColor3 = Cosmic.Theme.Secondary
    bottomBorder.BorderSizePixel = 0
    bottomBorder.Parent = frame
    
    local leftBorder = Instance.new("Frame")
    leftBorder.Size = UDim2.new(0, 2, 1, 0)
    leftBorder.BackgroundColor3 = Cosmic.Theme.Primary
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = frame
    
    local rightBorder = Instance.new("Frame")
    rightBorder.Size = UDim2.new(0, 2, 1, 0)
    rightBorder.Position = UDim2.new(1, -2, 0, 0)
    rightBorder.BackgroundColor3 = Cosmic.Theme.Secondary
    rightBorder.BorderSizePixel = 0
    rightBorder.Parent = frame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, GetButtonSize())
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. Title .. " ✦"
    titleText.TextColor3 = Cosmic.Theme.Primary
    titleText.TextSize = GetFontSize() + 2
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, GetButtonSize(), 1, 0)
    closeBtn.Position = UDim2.new(1, -GetButtonSize() - 5, 0, 0)
    closeBtn.BackgroundColor3 = Cosmic.Theme.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = isMobile and "−" or "✕"
    closeBtn.TextColor3 = Cosmic.Theme.Text
    closeBtn.TextSize = isMobile and 24 or 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
    end)
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -GetButtonSize() - 10)
    container.Position = UDim2.new(0, 10, 0, GetButtonSize() + 5)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = isMobile and 6 or 4
    container.ScrollBarImageColor3 = Cosmic.Theme.Primary
    container.Parent = frame
    
    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Parent = container
    containerLayout.Padding = UDim.new(0, isMobile and 12 or 8)
    containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Arrastar janela (PC)
    if not isMobile then
        local dragging = false
        local dragStart = nil
        local frameStart = nil
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                frameStart = frame.Position
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, 
                                            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            end
        end)
    end
    
    local window = {
        Type = "Window",
        Gui = screenGui,
        Frame = frame,
        Container = container,
        Layout = containerLayout,
        Elements = {},
        Show = function()
            screenGui.Enabled = true
            Cosmic.IsOpen = true
            Cosmic.CurrentWindow = window
            if Config and Config.OnOpen then Config.OnOpen() end
        end,
        Hide = function()
            screenGui.Enabled = false
            Cosmic.IsOpen = false
            if Config and Config.OnClose then Config.OnClose() end
        end,
        Close = function()
            screenGui:Destroy()
            if Cosmic.CurrentWindow == window then
                Cosmic.CurrentWindow = nil
                Cosmic.IsOpen = false
            end
        end
    }
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Hide()
    end)
    
    table.insert(Cosmic.Windows, window)
    return window
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
function Cosmic:Init()
    -- Setup Discord Rich Presence
    SetupRichPresence()
    
    -- Criar janela principal
    local Window = self:Window("COSMIC UI", {
        OnOpen = function()
            self:UpdatePresence("Menu Aberto", "Navegando", "Cosmic UI v" .. self.Versao)
        end,
        OnClose = function()
            self:UpdatePresence("Menu Fechado", "Inativo", "Cosmic UI v" .. self.Versao)
        end
    })
    
    -- Seções
    local Movement = self:Section(Window, "MOVIMENTAÇÃO")
    local Combat = self:Section(Window, "COMBATE")
    local Visual = self:Section(Window, "VISUAL")
    local Configs = self:Section(Window, "CONFIGURAÇÕES")
    local Discord = self:Section(Window, "DISCORD")
    
    -- [MOVIMENTAÇÃO]
    self:Toggle(Movement, "Speed Hack", "SpeedHack", false, function(Value)
        if Value then
            if LocalPlayer.Character then
                LocalPlayer.Character.Humanoid.WalkSpeed = 50
            end
            self:Success("Speed Hack ativado!")
        else
            if LocalPlayer.Character then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
            self:Success("Speed Hack desativado!")
        end
    end)
    
    self:Toggle(Movement, "Fly Hack", "FlyHack", false, function(Value)
        -- SEU CÓDIGO DE FLY AQUI
        self:Notify({Title = "Fly Hack", Text = Value and "Ativado" or "Desativado", Duration = 1})
    end)
    
    self:Slider(Movement, "Velocidade Personalizada", 16, 100, 16, function(Value)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end)
    
    self:Keybind(Movement, "Tecla do Fly", "None", function(Key)
        self:Success("Tecla do Fly definida para: " .. Key)
    end)
    
    -- [COMBATE]
    self:Toggle(Combat, "God Mode", "GodMode", false, function(Value)
        if Value then
            if LocalPlayer.Character then
                LocalPlayer.Character.Humanoid.MaxHealth = math.huge
                LocalPlayer.Character.Humanoid.Health = math.huge
            end
            self:Success("God Mode ativado!")
        else
            if LocalPlayer.Character then
                LocalPlayer.Character.Humanoid.MaxHealth = 100
                LocalPlayer.Character.Humanoid.Health = 100
            end
        end
    end)
    
    self:Button(Combat, "Teleportar Centro", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            self:Success("Teleportado para o centro!")
        end
    end)
    
    self:Slider(Combat, "Dano Multiplicador", 1, 10, 1, function(Value)
        -- SEU CÓDIGO DE DANO AQUI
        self:Notify({Title = "Dano", Text = "Multiplicador: " .. Value .. "x", Duration = 1})
    end)
    
    -- [VISUAL]
    self:Toggle(Visual, "ESP Players", "ESP", false, function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Cosmic.Theme.Primary
                    highlight.OutlineColor = Cosmic.Theme.Secondary
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
            end
            self:Success("ESP ativado!")
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Highlight") then
                    player.Character.Highlight:Destroy()
                end
            end
        end
    end)
    
    self:ColorPicker(Visual, "Cor do ESP", Color3.fromRGB(0, 255, 255), function(Color)
        -- SEU CÓDIGO PARA ATUALIZAR COR DO ESP
        self:Success("Cor do ESP alterada!")
    end)
    
    -- [CONFIGURAÇÕES]
    self:Button(Configs, "Salvar Configurações", function()
        SaveConfig()
        self:Success("Configurações salvas!")
    end)
    
    self:Button(Configs, "Resetar Configurações", function()
        for key in pairs(Cosmic.Configs) do
            Cosmic.Configs[key] = nil
        end
        SaveConfig()
        self:Warning("Configurações resetadas! Reinicie o menu.")
    end)
    
    self:Button(Configs, "Reiniciar Menu", function()
        for _, window in pairs(Cosmic.Windows) do
            window:Close()
        end
        task.wait(0.5)
        Cosmic:Init()
    end)
    
    -- [DISCORD]
    self:Button(Discord, "Copiar Convite", function()
        self:CopyInvite("seu_invite_aqui")
    end)
    
    self:Label(Discord, "Cosmic UI v" .. self.Versao, self.Theme.Primary)
    self:Label(Discord, "Suporte a Rich Presence", self.Theme.TextDark)
    self:Label(Discord, "Plataforma: " .. self.Platform, self.Theme.Accent)
    
    -- Controles da janela
    if isMobile then
        -- Mobile: Botão flutuante
        local mobileButton = Instance.new("ImageButton")
        mobileButton.Size = UDim2.new(0, 55, 0, 55)
        mobileButton.Position = UDim2.new(1, -70, 1, -80)
        mobileButton.BackgroundColor3 = self.Theme.Primary
        mobileButton.BackgroundTransparency = 0.2
        mobileButton.Image = "rbxassetid://5028857084"
        mobileButton.ImageColor3 = self.Theme.Primary
        mobileButton.ImageTransparency = 0.3
        mobileButton.Parent = LocalPlayer.PlayerGui
        
        local buttonText = Instance.new("TextLabel")
        buttonText.Size = UDim2.new(1, 0, 1, 0)
        buttonText.BackgroundTransparency = 1
        buttonText.Text = "☰"
        buttonText.TextColor3 = self.Theme.Text
        buttonText.TextSize = 28
        buttonText.Font = Enum.Font.GothamBold
        buttonText.Parent = mobileButton
        
        mobileButton.MouseButton1Click:Connect(function()
            if Window.Gui.Enabled then
                Window:Hide()
            else
                Window:Show()
            end
        end)
        
        Window:Hide()
    else
        -- PC: Tecla L
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.L then
                if Window.Gui.Enabled then
                    Window:Hide()
                else
                    Window:Show()
                end
            end
        end)
        Window:Show()
    end
    
    self:Success("Cosmic UI v" .. self.Versao .. " carregada!")
    
    print("========================================")
    print("✦ COSMIC UI EVOLVED v" .. self.Versao .. " ✦")
    print("Plataforma: " .. self.Platform)
    print("Recursos: ColorPicker, Keybind, Dropdown, Slider")
    print("Sistema de Config: Ativo")
    print("Discord Rich Presence: " .. (self.RichPresence and "Ativo" or "Inativo"))
    print("========================================")
end

-- ============================================
-- EXPORTAR E INICIAR
-- ============================================
return Cosmic:Init()
