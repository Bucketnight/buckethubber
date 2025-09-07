local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "FE Admin Hub",
   Icon = 0,
   LoadingTitle = "Admin Hub",
   LoadingSubtitle = "Rayfield UI",
   Theme = "Default",
})

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local FunTab = Window:CreateTab("Fun", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)

------------------------------------------------
-- Core: WalkSpeed / JumpPower
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
      if hum then hum.WalkSpeed = Value end
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
      if hum then hum.JumpPower = Value end
   end,
})

------------------------------------------------
-- Fly
local flying = false
MainTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)
      flying = Value
      local player = game.Players.LocalPlayer
      local char = player.Character or player.CharacterAdded:Wait()
      local hrp = char:WaitForChild("HumanoidRootPart")

      if flying then
         local bv = Instance.new("BodyVelocity")
         bv.Velocity = Vector3.zero
         bv.MaxForce = Vector3.new(4000,4000,4000)
         bv.Parent = hrp

         game:GetService("RunService").Heartbeat:Connect(function()
            if flying and bv.Parent then
               local camCF = workspace.CurrentCamera.CFrame
               local moveDir = Vector3.zero
               local uis = game.UserInputService
               if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
               if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
               if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
               if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
               bv.Velocity = moveDir * 60
            elseif bv then
               bv:Destroy()
            end
         end)
      else
         if hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
         end
      end
   end,
})

------------------------------------------------
-- GodMode
local godmode = false
MainTab:CreateToggle({
   Name = "GodMode",
   CurrentValue = false,
   Callback = function(Value)
      godmode = Value
      local player = game.Players.LocalPlayer
      task.spawn(function()
         while godmode do
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
            task.wait(0.2)
         end
      end)
   end,
})

------------------------------------------------
-- Player Utilities
local function getPlayers()
   local names = {}
   for _,plr in pairs(game.Players:GetPlayers()) do
      if plr ~= game.Players.LocalPlayer then
         table.insert(names, plr.Name)
      end
   end
   return names
end

MainTab:CreateDropdown({
   Name = "Teleport to Player",
   Options = getPlayers(),
   CurrentOption = "",
   Callback = function(Option)
      local lp = game.Players.LocalPlayer
      if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
         local target = game.Players:FindFirstChild(Option)
         if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
         end
      end
   end,
})

------------------------------------------------
-- Fun: Jail
FunTab:CreateDropdown({
   Name = "Jail Player",
   Options = getPlayers(),
   CurrentOption = "",
   Callback = function(Option)
      local target = game.Players:FindFirstChild(Option)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         local cage = Instance.new("Part")
         cage.Size = Vector3.new(6, 10, 6)
         cage.Anchored = true
         cage.Position = target.Character.HumanoidRootPart.Position
         cage.Transparency = 0.5
         cage.Parent = workspace
      end
   end,
})

------------------------------------------------
-- Fun: Freeze Player
FunTab:CreateDropdown({
   Name = "Freeze Player",
   Options = getPlayers(),
   CurrentOption = "",
   Callback = function(Option)
      local target = game.Players:FindFirstChild(Option)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         target.Character.HumanoidRootPart.Anchored = true
      end
   end,
})

-- Fun: Bring Player
FunTab:CreateDropdown({
   Name = "Bring Player",
   Options = getPlayers(),
   CurrentOption = "",
   Callback = function(Option)
      local target = game.Players:FindFirstChild(Option)
      local lp = game.Players.LocalPlayer
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + Vector3.new(3,0,0)
         end
      end
   end,
})

------------------------------------------------
-- Fun: Sit All
FunTab:CreateButton({
   Name = "Sit Everyone",
   Callback = function()
      for _,plr in pairs(game.Players:GetPlayers()) do
         local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
         if hum then hum.Sit = true end
      end
   end,
})

------------------------------------------------
-- Fun: ESP (Highlight)
FunTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Callback = function(Value)
      for _,plr in pairs(game.Players:GetPlayers()) do
         if plr ~= game.Players.LocalPlayer and plr.Character then
            if Value then
               local h = Instance.new("Highlight")
               h.FillTransparency = 1
               h.OutlineColor = Color3.fromRGB(0,255,0)
               h.Parent = plr.Character
            else
               if plr.Character:FindFirstChildOfClass("Highlight") then
                  plr.Character:FindFirstChildOfClass("Highlight"):Destroy()
               end
            end
         end
      end
   end,
})

------------------------------------------------
-- Fun: Clone Yourself
FunTab:CreateButton({
   Name = "Clone Yourself",
   Callback = function()
      local lp = game.Players.LocalPlayer
      if lp.Character then
         local clone = lp.Character:Clone()
         clone.Parent = workspace
         clone:MoveTo(lp.Character:GetPivot().p + Vector3.new(5,0,0))
      end
   end,
})

------------------------------------------------
-- World: Gravity
WorldTab:CreateSlider({
   Name = "Gravity",
   Range = {0, 500},
   Increment = 5,
   CurrentValue = workspace.Gravity,
   Callback = function(Value)
      workspace.Gravity = Value
   end,
})

------------------------------------------------
-- World: Disco Lighting
local disco = false
WorldTab:CreateToggle({
   Name = "Disco Lighting",
   CurrentValue = false,
   Callback = function(Value)
      disco = Value
      task.spawn(function()
         while disco do
            game.Lighting.Ambient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            task.wait(0.3)
         end
      end)
   end,
})

------------------------------------------------
-- World: Music Player
WorldTab:CreateInput({
   Name = "Play Music (SoundId)",
   PlaceholderText = "Enter SoundId...",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
      local sound = Instance.new("Sound", workspace)
      sound.SoundId = "rbxassetid://"..Text
      sound.Volume = 5
      sound.Looped = true
      sound:Play()
   end,
})

------------------------------------------------
-- Announce
MainTab:CreateInput({
   Name = "Announce",
   PlaceholderText = "Type a message...",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
      game.StarterGui:SetCore("ChatMakeSystemMessage", {
         Text = "[ANNOUNCEMENT] " .. Text,
         Color = Color3.fromRGB(255, 200, 0),
         Font = Enum.Font.SourceSansBold,
         FontSize = Enum.FontSize.Size24
      })
   end,
})
