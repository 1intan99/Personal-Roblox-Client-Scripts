-- Refactored by ChatGPT + RIP#6666 base

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local LocalPlayer = Players.LocalPlayer
local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function BoostPerformance()
    local Settings = {
        Ignore = {},
        WaitPerAmount = 500,
        ConsoleLogs = false,
        Config = {
            Players = {
                ["Ignore Me"] = true,
                ["Ignore Others"] = true,
                ["Ignore Tools"] = true
            },
            Meshes = {
                NoMesh = false,
                NoTexture = false,
                Destroy = false
            },
            Images = {
                Invisible = true,
                Destroy = false
            },
            Explosions = {
                Smaller = true,
                Invisible = false,
                Destroy = false
            },
            Particles = {
                Invisible = true,
                Destroy = false
            },
            TextLabels = {
                LowerQuality = false,
                Invisible = false,
                Destroy = false
            },
            MeshParts = {
                LowerQuality = true,
                Invisible = false,
                NoTexture = false,
                NoMesh = false,
                Destroy = false
            },
            Other = {
                ["FPS Cap"] = 15,
                ["No Camera Effects"] = true,
                ["No Clothes"] = true,
                ["Low Water Graphics"] = true,
                ["No Shadows"] = true,
                ["Low Rendering"] = true,
                ["Low Quality Parts"] = true,
                ["Low Quality Models"] = true,
                ["Reset Materials"] = true,
                ["Lower Quality MeshParts"] = true
            }
        }
    }

    local cfg = Settings.Config
    local function IsDescendantOfIgnore(instance)
        for _, ignore in pairs(Settings.Ignore) do
            if instance:IsDescendantOf(ignore) then
                return true
            end
        end
        return false
    end
    
    local function IsPartOfOtherCharacter(instance)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and instance:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end
    
    local function CheckIfBad(instance)
        if not instance:IsDescendantOf(Players) and
            (cfg.Players["Ignore Others"] and not IsPartOfOtherCharacter(instance) or not cfg.Players["Ignore Others"]) and
            (cfg.Players["Ignore Me"] and LocalPlayer.Character and not instance:IsDescendantOf(LocalPlayer.Character) or not cfg.Players["Ignore Me"]) and
            (cfg.Players["Ignore Tools"] and not instance:IsA("BackpackItem") and not instance:FindFirstAncestorWhichIsA("BackpackItem") or not cfg.Players["Ignore Tools"]) and
            (not IsDescendantOfIgnore(instance)) then
    
            if instance:IsA("DataModelMesh") then
                if cfg.Meshes.NoMesh and instance:IsA("SpecialMesh") then
                    instance.MeshId = ""
                end
                if cfg.Meshes.NoTexture and instance:IsA("SpecialMesh") then
                    instance.TextureId = ""
                end
                if cfg.Meshes.Destroy then
                    instance:Destroy()
                end
            elseif instance:IsA("FaceInstance") then
                if cfg.Images.Invisible then
                    instance.Transparency = 1
                    instance.Shiny = 1
                end
                if cfg.Images.Destroy then
                    instance:Destroy()
                end
            elseif instance:IsA("ShirtGraphic") then
                if cfg.Images.Invisible then
                    instance.Graphic = ""
                end
                if cfg.Images.Destroy then
                    instance:Destroy()
                end
            elseif table.find(CanBeEnabled, instance.ClassName) then
                if cfg.Particles.Invisible then
                    instance.Enabled = false
                end
                if cfg.Particles.Destroy then
                    instance:Destroy()
                end
            elseif instance:IsA("PostEffect") and cfg.Other["No Camera Effects"] then
                instance.Enabled = false
            elseif instance:IsA("Explosion") then
                if cfg.Explosions.Smaller then
                    instance.BlastPressure = 1
                    instance.BlastRadius = 1
                end
                if cfg.Explosions.Invisible then
                    instance.Visible = false
                end
                if cfg.Explosions.Destroy then
                    instance:Destroy()
                end
            elseif instance:IsA("Clothing") or instance:IsA("SurfaceAppearance") or instance:IsA("BaseWrap") then
                if cfg.Other["No Clothes"] then
                    instance:Destroy()
                end
            elseif instance:IsA("BasePart") and not instance:IsA("MeshPart") then
                if cfg.Other["Low Quality Parts"] then
                    instance.Material = Enum.Material.Plastic
                    instance.Reflectance = 0
                end
            elseif instance:IsA("TextLabel") and instance:IsDescendantOf(workspace) then
                if cfg.TextLabels.LowerQuality then
                    instance.Font = Enum.Font.SourceSans
                    instance.TextScaled = false
                    instance.RichText = false
                    instance.TextSize = 14
                end
                if cfg.TextLabels.Invisible then
                    instance.Visible = false
                end
                if cfg.TextLabels.Destroy then
                    instance:Destroy()
                end
            elseif instance:IsA("Model") then
                if cfg.Other["Low Quality Models"] then
                    instance.LevelOfDetail = 1
                end
            elseif instance:IsA("MeshPart") then
                if cfg.MeshParts.LowerQuality then
                    instance.RenderFidelity = 2
                    instance.Reflectance = 0
                    instance.Material = Enum.Material.Plastic
                end
                if cfg.MeshParts.Invisible then
                    instance.Transparency = 1
                end
                if cfg.MeshParts.NoTexture then
                    instance.TextureID = ""
                end
                if cfg.MeshParts.NoMesh then
                    instance.MeshId = ""
                end
                if cfg.MeshParts.Destroy then
                    instance:Destroy()
                end
            end
        end
    end
    
    if cfg.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            if sethiddenproperty then
                sethiddenproperty(terrain, "Decoration", false)
            end
        end
    end
    
    if cfg.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
        end
    end
    
    if cfg.Other["Low Rendering"] then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
    end
    
    if cfg.Other["Reset Materials"] then
        for _, v in pairs(MaterialService:GetChildren()) do
            v:Destroy()
        end
        MaterialService.Use2022Materials = false
    end
    
    if cfg.Other["FPS Cap"] and setfpscap then
        coroutine.wrap(function()
            while task.wait(300) do
                setfpscap(cfg.Other["FPS Cap"])
            end
        end)()
        setfpscap(cfg.Other["FPS Cap"])
    end
    
    game.DescendantAdded:Connect(function(child)
        task.wait(0.1)
        CheckIfBad(child)
    end)
    
    for _, instance in pairs(game:GetDescendants()) do
        CheckIfBad(instance)
    end
end

BoostPerformance()
