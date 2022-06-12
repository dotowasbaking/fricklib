local start = os.clock()

local lib = loadstring(syn.request({
    Url = "https://raw.githubusercontent.com/dotowasbaking/fricklib/main/main.lua";
    Method = "GET";
}).Body)().new({Icon = "https://i.ibb.co/6D46dZ0/eeeeeeeeeadfasfd.png", Title = "bruh gaming", Size = Vector2.new(480, 600), Color = Color3.fromRGB(233, 10, 21)})

local tab1 = lib:Tab({Title = "Tab 1"})
local tab2 = lib:Tab({Title = "Tab 2"})
local tab3 = lib:Tab({Title = "Tab 3"})
local tab4 = lib:Tab({Title = "Settings"})

local subframe1 = tab1:Subframe({Title = "Subframe 1"})
local subframe2 = tab3:Subframe({Title = "Subframe 2"})
local subframe3 = tab1:Subframe({Title = "UI Settings"})
local subframe4 = tab1:Subframe({Title = "Subframe 4"})
local subframe5 = tab1:Subframe({Title = "Subframe 5"})
local subframe6 = tab1:Subframe({Title = "Subframe 6"})

subframe1:Toggle({Title = "Toggle 1"})
subframe1:Slider({Title = "Slider 1", Min = 0, Max = 512, Default = 128})
subframe1:Toggle({Title = "Toggle 2", Enabled = true})
subframe1:Slider({Title = "Slider 2", Min = 0, Max = 360, Default = 90, Measurement = "°"})

subframe2:Toggle({Title = "lol", Enabled = true})
subframe2:Button({Title = "bruh"})

local toggle1 = subframe3:Toggle({Title = "lol", Enabled = true})

toggle1:ColorPicker({Title = "me when"})
toggle1:ColorPicker({Title = "me whe2"})
toggle1:Keybind({Title = "shitter"})

local toggle2 = subframe3:Toggle({Title = "lol", Enabled = true})

toggle2:ColorPicker({toggle2itoggle2le = "me when"})
toggle2:ColorPicker({Title = "me toggle2he2"})
toggle2:ColorPicker({Title = "me togg"})

subframe3:Button({Title = "bruh"})

subframe4:Toggle({Title = "Toggle 1"})
subframe4:Toggle({Title = "Toggle 2"})
subframe4:Toggle({Title = "Toggle 3"})

subframe6:ConfigWindow()

local UIColor = Color3.new(1, 0, 0)

local accentColor
local accentEnabled = false

subframe5:Toggle({
    Title = "UI Color",
    Enabled = false,
    Pointer = "uiColorToggle",
    Callback = function(state)
        accentEnabled = state

        if state then
            lib:SetAccentColor(accentColor)
        else
            lib:SetAccentColor(UIColor)
        end
    end
}):ColorPicker({
    Title = "UI Color",
    DefaultColor = Color3.fromRGB(233, 10, 21),
    Pointer = "uiColorPicker",
    Callback = function(color)
        accentColor = color

        if accentEnabled then
            lib:SetAccentColor(color)
        end
    end
})

subframe5:Button({
    Title = "get bitches",
    ClickedText = "failure",
    ButtonCallback = function()
        print("impossible")
    end
})

subframe5:Button({
    Title = "destroy ui ",
    ConfirmationText = "r u sure?",
    ButtonCallback = function()
        lib:Destroy()
    end
})

subframe5:Button({
    Title = "notification",
    ButtonCallback = function()
        lib:Notify(("notification test"))
    end
})

subframe5:Dropdown({
    Title = "Body Part",
    MultiSelect = true,
    Pointer = "bodyPartDropdown",
    Options = {
        ["Head"] = false,
        ["Torso"] = false,
        ["Right Arm"] = false,
        ["Left Arm"] = false,
        ["Right Leg"] = false,
        ["Left Leg"] = false
    },
    Callback = function(list)
        print(list)
    end
})

subframe5:TextBox({
    Title = "black fart matter",
})

subframe5:TextBox({
    Title = "fart",
})

lib:Notify(("(%f)"):format(os.clock() - start))
lib:Notify(("cathode ray tube manufacturing "):rep(math.random(10, 50)), 5, 600)
