-- ============================================
-- COSMIC UI LIBRARY v1.0
-- Sintaxe estilo espacial/futurista
-- ============================================

local Cosmic = {
    Versao = "1.0.0",
    Theme = {
        Background = Color3.fromRGB(8, 8, 18),
        Primary = Color3.fromRGB(0, 255, 255),     -- Ciano
        Secondary = Color3.fromRGB(255, 0, 255),   -- Magenta
        Accent = Color3.fromRGB(255, 255, 0),      -- Amarelo
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 170),
        Success = Color3.fromRGB(0, 255, 0),
        Error = Color3.fromRGB(255, 0, 0)
    },
    Windows = {},
    ActiveWindow = nil
}

-- ============================================
-- UTILIDADES
-- ============================================

local function ApplyTween(obj, prop, value, time)
    local tween = game:GetService("TweenService"):Create(obj, 
        TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), 
        {[prop] = value}
    )
    tween:Play()
    return tween
end

-- ============================================
-- CRIAR JANELA
-- ============================================

function Cosmic:NewWindow(title, width, height)
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CosmicWindow_" .. title:gsub(" ", "_")
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width or 500, 0, height or 400)
    frame.Position = UDim2.new(0.5, -(width or 500)/2, 0.5, -(height or 400)/2)
    frame.BackgroundColor3 = self.Theme.Background
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    -- Bordas neon
    local topBorder = Instance.new("Frame")
    topBorder.Size = UDim2.new(1, 0, 0, 2)
    topBorder.BackgroundColor3 = self.Theme.Primary
    topBorder.BorderSizePixel = 0
    topBorder.Parent = frame
    
    local bottomBorder = Instance.new("Frame")
    bottomBorder.Size = UDim2.new(1, 0, 0, 2)
    bottomBorder.Position = UDim2.new(0, 0, 1, -2)
    bottomBorder.BackgroundColor3 = self.Theme.Secondary
    bottomBorder.BorderSizePixel = 0
    bottomBorder.Parent = frame
    
    local leftBorder = Instance.new("Frame")
    leftBorder.Size = UDim2.new(0, 2, 1, 0)
    leftBorder.BackgroundColor3 = self.Theme.Primary
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = frame
    
    local rightBorder = Instance.new("Frame")
    rightBorder.Size = UDim2.new(0, 2, 1, 0)
    rightBorder.Position = UDim2.new(1, -2, 0, 0)
    rightBorder.BackgroundColor3 = self.Theme.Secondary
    rightBorder.BorderSizePixel = 0
    rightBorder.Parent = frame
    
    -- Barra de titulo
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ " .. title .. " ✦"
    titleText.TextColor3 = self.Theme.Primary
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Botao fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.BackgroundColor3 = self.Theme.Error
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = self.Theme.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    closeBtn.MouseEnter:Connect(function()
        ApplyTween(closeBtn, "BackgroundTransparency", 0.2, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        ApplyTween(closeBtn, "BackgroundTransparency", 0.5, 0.1)
    end)
    
    -- Container para elementos
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -50)
    container.Position = UDim2.new(0, 10, 0, 45)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = self.Theme.Primary
    container.Parent = frame
    
    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Parent = container
    containerLayout.Padding = UDim.new(0, 8)
    containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Arrastar janela
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, 
                                        frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    local window = {
        Type = "Window",
        Gui = screenGui,
        Frame = frame,
        Container = container,
        Layout = containerLayout,
        Elements = {},
        Close = function()
            screenGui:Destroy()
        end
    }
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Close()
    end)
    
    table.insert(self.Windows, window)
    return window
end

-- ============================================
-- CRIAR SECAO
-- ============================================

function Cosmic:NewSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 0)
    section.BackgroundTransparency = 1
    section.Parent = parent.Container
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = self.Theme.Primary
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0
    header.Text = "◈ " .. title .. " ◈"
    header.TextColor3 = self.Theme.Primary
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.Parent = section
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 5)
    
    local function updateHeight()
        local totalHeight = 35 + contentLayout.AbsoluteContentSize.Y
        section.Size = UDim2.new(1, -20, 0, totalHeight)
        parent.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    task.wait(0.1)
    updateHeight()
    
    return {
        Type = "Section",
        Container = content,
        Layout = contentLayout
    }
end

-- ============================================
-- CRIAR BOTAO
-- ============================================

function Cosmic:NewButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 1
    button.BorderColor3 = self.Theme.Primary
    button.Text = text
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = parent.Container
    
    button.MouseEnter:Connect(function()
        ApplyTween(button, "BackgroundTransparency", 0.2, 0.1)
        ApplyTween(button, "BorderColor3", self.Theme.Accent, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        ApplyTween(button, "BackgroundTransparency", 0.5, 0.1)
        ApplyTween(button, "BorderColor3", self.Theme.Primary, 0.1)
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- ============================================
-- CRIAR TOGGLE
-- ============================================

function Cosmic:NewToggle(parent, text, color, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.7, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(60, 60, 80)
    button.Text = text
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextPadding = UDim.new(0, 15)
    button.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 50, 0, 25)
    indicator.Position = UDim2.new(1, -60, 0.5, -12.5)
    indicator.BackgroundColor3 = self.Theme.Error
    indicator.BorderSizePixel = 0
    indicator.Parent = frame
    
    local indicatorText = Instance.new("TextLabel")
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.Text = "OFF"
    indicatorText.TextColor3 = self.Theme.Text
    indicatorText.TextSize = 11
    indicatorText.Font = Enum.Font.GothamBold
    indicatorText.Parent = indicator
    
    local state = false
    
    local function update()
        local newColor = state and (color or self.Theme.Success) or self.Theme.Error
        local newText = state and "ON" or "OFF"
        ApplyTween(indicator, "BackgroundColor3", newColor, 0.2)
        indicatorText.Text = newText
    end
    
    button.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then callback(state) end
    end)
    
    button.MouseEnter:Connect(function()
        ApplyTween(button, "BackgroundTransparency", 0.2, 0.1)
        ApplyTween(button, "BorderColor3", color or self.Theme.Success, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        ApplyTween(button, "BackgroundTransparency", 0.5, 0.1)
        ApplyTween(button, "BorderColor3", Color3.fromRGB(60, 60, 80), 0.1)
    end)
    
    return {
        SetState = function(newState)
            state = newState
            update()
        end,
        GetState = function() return state end
    }
end

-- ============================================
-- CRIAR SLIDER
-- ============================================

function Cosmic:NewSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    handle.BackgroundColor3 = self.Theme.Accent
    handle.BorderSizePixel = 0
    handle.Parent = slider
    
    local value = default
    local dragging = false
    
    local function update(posX)
        local relative = math.clamp((posX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relative
        value = math.floor(value * 10) / 10
        
        fill.Size = UDim2.new(relative, 0, 1, 0)
        handle.Position = UDim2.new(relative, -6, 0.5, -6)
        label.Text = text .. ": " .. tostring(value)
        
        if callback then callback(value) end
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(input.Position.X)
        end
    end)
    
    return {
        SetValue = function(val)
            value = math.clamp(val, min, max)
            local relative = (value - min) / (max - min)
            fill.Size = UDim2.new(relative, 0, 1, 0)
            handle.Position = UDim2.new(relative, -6, 0.5, -6)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end,
        GetValue = function() return value end
    }
end

-- ============================================
-- CRIAR TEXTBOX
-- ============================================

function Cosmic:NewTextbox(parent, placeholder, callback)
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, 0, 0, 35)
    textbox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    textbox.BackgroundTransparency = 0.5
    textbox.BorderSizePixel = 1
    textbox.BorderColor3 = self.Theme.Primary
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = self.Theme.TextDark
    textbox.Text = ""
    textbox.TextColor3 = self.Theme.Text
    textbox.TextSize = 14
    textbox.Font = Enum.Font.Gotham
    textbox.Parent = parent.Container
    
    textbox.FocusLost:Connect(function()
        if callback then callback(textbox.Text) end
    end)
    
    return textbox
end

-- ============================================
-- CRIAR LABEL
-- ============================================

function Cosmic:NewLabel(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or self.Theme.TextDark
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent.Container
    
    return label
end

-- ============================================
-- CRIAR SEPARADOR
-- ============================================

function Cosmic:NewSeparator(parent)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = self.Theme.Primary
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = parent.Container
    
    return line
end

-- ============================================
-- NOTIFICACAO COSMIC
-- ============================================

function Cosmic:Notify(title, message, duration)
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -320, 0, 10)
    notification.BackgroundColor3 = self.Theme.Background
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 1
    notification.BorderColor3 = self.Theme.Primary
    notification.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "✦ " .. title .. " ✦"
    titleLabel.TextColor3 = self.Theme.Primary
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextPadding = UDim.new(0, 10)
    titleLabel.Parent = notification
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 1, -25)
    msgLabel.Position = UDim2.new(0, 0, 0, 25)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = self.Theme.Text
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextPadding = UDim.new(0, 10)
    msgLabel.Parent = notification
    
    ApplyTween(notification, "Position", UDim2.new(1, -320, 0, 10), 0.3)
    
    task.wait(duration or 3)
    
    ApplyTween(notification, "Position", UDim2.new(1, 10, 0, 10), 0.3)
    task.wait(0.3)
    notification:Destroy()
end

-- ============================================
-- NOTIFICACAO DE SUCESSO
-- ============================================

function Cosmic:Success(message)
    self:Notify("SUCESSO", message, 2)
end

-- ============================================
-- NOTIFICACAO DE ERRO
-- ============================================

function Cosmic:Error(message)
    self:Notify("ERRO", message, 2)
end

-- ============================================
-- TEMA PERSONALIZADO
-- ============================================

function Cosmic:SetTheme(theme)
    for k, v in pairs(theme) do
        if self.Theme[k] then
            self.Theme[k] = v
        end
    end
end

-- ============================================
-- MENSAGEM DE INICIO
-- ============================================

print("========================================")
print("✦ COSMIC UI LIBRARY v" .. self.Versao .. " ✦")
print("Sintaxe espacial carregada com sucesso!")
print("========================================")

-- ============================================
-- EXPORTAR
-- ============================================

return Cosmic
