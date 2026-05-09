-- Criar janela
local Window = Cosmic:Window("Meu Menu")

-- Seção
local Movement = Cosmic:Section(Window, "MOVIMENTAÇÃO")

-- Toggle com save automático
Cosmic:Toggle(Movement, "Speed Hack", "SpeedHack", false, function(Value)
    if Value then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
    end
end)

-- Slider
Cosmic:Slider(Movement, "Velocidade", 16, 100, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

-- Keybind
Cosmic:Keybind(Movement, "Tecla do Fly", "None", function(Key)
    print("Tecla definida:", Key)
end)

-- ColorPicker
Cosmic:ColorPicker(Visual, "Cor do ESP", Color3.fromRGB(0, 255, 255), function(Color)
    print("Cor selecionada:", Color)
end)

-- Dropdown multi-seleção
Cosmic:Dropdown(Movement, "Modos", {"Modo 1", "Modo 2", "Modo 3"}, true, function(Selected)
    print("Selecionado:", table.concat(Selected, ", "))
end)

-- Input Text
Cosmic:TextInput(Movement, "Nome do Jogador", "Digite aqui...", function(Text)
    print("Texto:", Text)
end)

-- Notificações
Cosmic:Success("Operação concluída!")
Cosmic:Error("Ocorreu um erro!")
Cosmic:Warning("Atenção!")
