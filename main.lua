-- Single-source admin (place copy as Script in ServerScriptService AND as LocalScript in StarterPlayerScripts)
-- Server side will run the admin commands; client side will build the Rayfield UI.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Ensure RemoteEvent exists server-side (only runs when this file is a Script in ServerScriptService)
if RunService:IsServer() then
    local AdminCommand = ReplicatedStorage:FindFirstChild("AdminCommand")
    if not AdminCommand then
        AdminCommand = Instance.new("RemoteEvent")
        AdminCommand.Name = "AdminCommand"
        AdminCommand.Parent = ReplicatedStorage
    end

    -- Admin whitelist
    local admins = {
        ["YourUsernameHere"] = true
    }

    AdminCommand.OnServerEvent:Connect(function(player, command, arg)
        if not admins[player.Name] then
            warn(player.Name .. " tried to use admin command: " .. tostring(command))
            return
        end

        if command == "WalkSpeed" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = tonumber(arg) or arg
            end

        elseif command == "JumpPower" then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = tonumber(arg) or arg
            end

        elseif command == "Announce" then
            local msg = tostring(arg or "")
            for _, plr in ipairs(Players:GetPlayers()) do
                -- Chat system message for everyone
                game.StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "[ANNOUNCEMENT] " .. msg,
                    Color = Color3.fromRGB(255, 200, 0),
                    Font = Enum.Font.SourceSansBold,
                    FontSize = Enum.FontSize.Size24
                })
            end
        end
    end)

    return -- server done
end

-- ---------------------------
-- CLIENT SIDE (LocalScript)
-- ---------------------------
-- Wait for or fail if the RemoteEvent doesn't exist yet
local AdminCommand = ReplicatedStorage:WaitForChild("AdminCommand", 10)
if not AdminCommand then
    warn("AdminCommand RemoteEvent not found in ReplicatedStorage. Make sure the server script ran.")
    return
end

-- Load Rayfield safely
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not ok or not Rayfield then
    warn("Failed to load Rayfield. If you're in a published game, HttpGet may be blocked or URL changed.")
    return
end

-- Build Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Simple FE Admin",
    LoadingTitle = "Admin Panel",
    LoadingSubtitle = "Walk, Jump, Announce",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main")

-- Create variables for each control (so you can later reference them if needed)
local wsSlider = MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        AdminCommand:FireServer("WalkSpeed", value)
    end,
})

local jpSlider = MainTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        AdminCommand:FireServer("JumpPower", value)
    end,
})

local announceInput = MainTab:CreateInput({
    Name = "Announce",
    PlaceholderText = "Enter announcement...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text and text:match("%S") then
            AdminCommand:FireServer("Announce", text)
        end
    end,
})

-- Optional: small confirmation print
print("Simple FE Admin UI loaded (Rayfield).")
