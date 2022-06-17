local gui

local f_utils = (function()
    local isfolder = isfolder
    local makefolder = makefolder
    local isfile = isfile
    local readfile = readfile
    local writefile = writefile

    local fileExtension = ".frick"

    local prefixes = {
        "apathy_",
        "varyex_",
        "apatvy_",
        "varyexx_",
        "appathy_",
        "busyCity_",
        "gungaging_",
        "doto_",
        "frick_"
    }

    local chars = {}

    for i = 65, 90 do
    table.insert(chars, string.char(i))
    end

    for i = 1, 10 do
        table.insert(chars, tostring(i - 1))
    end

    local function stringRemove(str, ...)
        for _, v in pairs({...}) do
            str = str:gsub(v, "")
        end

        return str
    end

    local function getFile(path)
        return (isfile(path) and readfile(path)) or nil
    end

    local utils = {}

    utils.__index = utils

    function utils:getFormattedTime()
        return ("%s:%s:%s %s %s. %s, %s"):format(os.date("%I"), os.date("%M"), os.date("%S"), string.upper(os.date("%p")), os.date("%b"), os.date("%d"), os.date("%Y"))
    end

    function utils:loadImage(imageLink)
        if not isfolder("_fricklib") then
            makefolder("_fricklib")
            makefolder("_fricklib/cache")
        elseif not isfolder("_fricklib/cache") then
            makefolder("_fricklib/cache")
        end
        
        local formattedUrl = stringRemove(imageLink, "/", ":", ".png", ".jpg")
        local dataFile = getFile(("_fricklib/cache/%s%s"):format(formattedUrl, fileExtension))

        if dataFile then
            return dataFile
        else
            local data = syn.request({
                Url = imageLink;
                Method = "GET";
            }).Body

            task.spawn(writefile, ("_fricklib/cache/%s%s"):format(formattedUrl, fileExtension), data)
            
            return data
        end
    end

    function utils:getEncryptedName(labelEncrypted)
        local str = prefixes[math.random(1, #prefixes)]

        for _ = 1, 10 do
            str..= chars[math.random(1, #chars)]
        end

        return str..((labelEncrypted and " (Encrypted)") or "")
    end

    function utils:formatHMS(seconds)
        return ("%02i:%02i:%02i"):format(seconds / 60 ^ 2, seconds / 60 % 60, seconds % 60)
    end

    function utils:dictionaryLen(dictionary)
        local dictionaryLen = 0

        for _, _ in pairs(dictionary) do
            dictionaryLen += 1
        end

        return dictionaryLen
    end

    function utils:tableToString(Data) -- Made by ComoEsteban on v3rm :troll:
        local Table = Data.Table or Data
        local Indent = Data.Indent or 4
        local ShowKeys = true
        local LastIndent = Data.LastBracketIndent or 0
        if Data.ShowKeys ~= nil then
            ShowKeys = Data.ShowKeys
        end
        local function ConvertValue(Value)
            if type(Value) == "table" then
                return self:tableToString({
                    ["Table"] = Value,
                    ["Indent"] = (Indent + (Data.LastBracketIndent or Indent)),
                    ["ShowKeys"] = Data.ShowKeys,
                    ["LastBracketIndent"] = Indent
                })
            end
            if type(Value) == "string" then
                return '"'..Value..'"'
            end
            if typeof(Value) == "Instance" then
                Origin = "game."
                if not Value:FindFirstAncestorOfClass("game") then
                    Origin = ""
                end
                return Origin..Value:GetFullName()
            end
            if typeof(Value) == "CFrame" then
                return "CFrame.new("..tostring(Value)..")"
            end  
            if typeof(Value) == "Vector3" then
                return "Vector3.new("..tostring(Value)..")"
            end    
            if typeof(Value) == "Vector2" then
                return "Vector2.new("..tostring(Value)..")"
            end 
            if typeof(Value) == "Color3" then
                return "Color3.new("..tostring(Value)..")"
            end
            if typeof(Value) == "BrickColor" then
                return "BrickColor.new("..tostring(Value)..")"
            end
            return tostring(Value)
        end
        local Indent = Data.Indent or 4
        local Result = "{\n"
        for Key,Value in pairs(Table) do
            KeyString = "[\""..tostring(Key).."\"] = "
            if type(Key) == "number" then
                KeyString = "["..tostring(Key).."] = "
            end
            if not ShowKeys then
                KeyString = ""
            end
            Result = Result..string.rep(" ",Indent)..KeyString..ConvertValue(Value)..",\n"
        end
        Result = Result..string.rep(" ",LastIndent).."}"
        return Result
    end

    function utils:drawing(type, properties)
        local self = Drawing.new(type)

        for prop, val in pairs(properties) do
            self[prop] = val
        end

        return self
    end

    return utils
end)()

local customKeyboard = (function()
    local contextActionService = game:service("ContextActionService")
    local userInputService = game:service("UserInputService")

    local customKeyboard = {Keypress = {}, OnStop = {}, OnBackspace = {}, OnPaste = {}}

    customKeyboard.__index = customKeyboard

    customKeyboard._shiftSymbols = {
        ["`"] = "~";
        ["1"] = "!";
        ["2"] = "@";
        ["3"] = "#";
        ["4"] = "$";
        ["5"] = "%";
        ["6"] = "^";
        ["7"] = "&";
        ["8"] = "*";
        ["9"] = "(";
        ["0"] = ")";
        ["-"] = "_";
        ["="] = "+";
        ["["] = "{";
        ["]"] = "}";
        ["\\"] = "|";
        [";"] = ":";
        ["\'"] = "\"";
        [","] = "<";
        ["."] = ">";
        ["/"] = "?";
    }

    function customKeyboard:Start()
        assert(not self._running)

        self._running = true

        contextActionService:BindCoreAction(
            self._bindID,
            function(actionName, inputState, inputObject)
                local keycodeValue = inputObject.KeyCode.Value
                local state = inputState.Value
                local success, keyboardInput = pcall(string.char, keycodeValue)

                if keycodeValue == 303 or keycodeValue == 304 then
                    if state == 0 then
                        self._shiftDown = true
                    else
                        self._shiftDown = false
                    end
                elseif keycodeValue == 305 or keycodeValue == 306 then
                    if state == 0 then
                        self._ctrlDown = true
                    else
                        self._ctrlDown = false
                    end
                elseif keycodeValue == 8 then
                    if self.OnBackspace._backspaceCallback and state == 0 then
                        self.OnBackspace._backspaceCallback()
                        local pressTime = os.clock()

                        while userInputService:IsKeyDown(Enum.KeyCode.Backspace) do
                            task.wait(0.04)

                            if os.clock() - pressTime < 0.4 then
                                continue
                            end

                            self.OnBackspace._backspaceCallback()
                        end
                    end
                elseif keycodeValue == 118 and self._ctrlDown then
                    if self.OnPaste._pasteCallback and state == 0 then
                        if self._dummyTextBox then
                            while
                                userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
                                userInputService:IsKeyDown(Enum.KeyCode.RightControl) or
                                userInputService:IsKeyDown(Enum.KeyCode.V)
                            do
                                task.wait() -- scuffed...
                            end

                            local oldText = self._dummyTextBox.Text

                            local changed; changed = self._dummyTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                                self.OnPaste._pasteCallback(self._dummyTextBox.Text)

                                self._dummyTextBox.Text = oldText
                                self._dummyTextBox:ReleaseFocus()

                                changed:Disconnect()
                            end)

                            self._dummyTextBox:CaptureFocus()

                            keypress(0x11)
                            keypress(0x56)

                            keyrelease(0x11)
                            keyrelease(0x56)
                        end
                    end
                elseif keycodeValue == 13 or keycodeValue == 271 then
                    self:Stop()
                elseif success and not self._ctrlDown and state == 0 then
                    if self.Keypress._keypressCallback then
                        self.Keypress._keypressCallback(self:_getChar(keyboardInput))
                    end
                end

                return Enum.ContextActionResult.Sink
            end,
            false,
            --self._priorityOverwrite or 9e9,
            table.unpack(Enum.KeyCode:GetEnumItems())
        )
    end

    function customKeyboard:Stop()
        assert(self._running)

        contextActionService:UnbindCoreAction(self._bindID)

        if self.Keypress._keypressCallback then
            self.Keypress:Disconnect()
        end

        if self.OnBackspace._backspaceCallback then
            self.OnBackspace:Disconnect()
        end

        if self.OnPaste._pasteCallback then
            self.OnPaste:Disconnect()
        end

        self._running = false

        if self.OnStop._stopCallback then
            self.OnStop._stopCallback()
        end
    end

    function customKeyboard.Keypress:Connect(func)
        assert(typeof(func) == "function") -- me when 3ds say that type() get gone or something XD!!!!!!!
        assert(not self._keypressCallback)

        self._keypressCallback = func
    end

    function customKeyboard.Keypress:Disconnect()
        assert(self._keypressCallback)

        self._keypressCallback = nil
    end

    function customKeyboard.OnStop:Connect(func)
        assert(typeof(func) == "function")
        assert(not self._stopCallback)

        self._stopCallback = func
    end

    function customKeyboard.OnStop:Disconnect()
        assert(self._stopCallback)

        self._stopCallback = nil
    end

    function customKeyboard.OnBackspace:Connect(func)
        assert(typeof(func) == "function")
        assert(not self._backspaceCallback)

        self._backspaceCallback = func
    end

    function customKeyboard.OnBackspace:Disconnect()
        assert(self._backspaceCallback)

        self._backspaceCallback = nil
    end

    function customKeyboard.OnPaste:Connect(func)
        assert(typeof(func) == "function")
        assert(not self._pasteCallback)

        self._pasteCallback = func
    end

    function customKeyboard.OnPaste:Disconnect()
        assert(self._pasteCallback)

        self._pasteCallback = nil
    end

    function customKeyboard:Destroy()
        contextActionService:UnbindCoreAction(self._bindID)

        if self._stopCallback then
            self._stopCallback()
        end

        setmetatable(self, nil)
    end

    function customKeyboard:_getChar(char)
        if self._shiftDown then
            local symbol = self._shiftSymbols[char]

            if symbol then
                char = symbol
            else
                char = string.upper(char)
            end
        end

        return char
    end

    function customKeyboard.new(bindID)
        local self = setmetatable({}, customKeyboard)

        self._bindID = bindID or "__customKeyboard"

        --assert(not contextActionService:GetBoundActionInfo(self._bindID))

        for _, v in ipairs(game:service("Players").LocalPlayer.PlayerGui:GetDescendants()) do
            local parent = v:FindFirstAncestorOfClass("ScreenGui")

            if not parent then
                continue
            end

            if not parent.Enabled then
                continue
            end

            if v:IsA("TextBox") then
                self._dummyTextBox = v

                break
            end
        end

        return self
    end

    return customKeyboard
end)().new("__frickLibKeyboard")

local players = game:service("Players")
local contextActionService = game:service("ContextActionService")
local UserInputService = game:service("UserInputService")
local runService = game:service("RunService")
local tweenService = game:service("TweenService")
local httpService = game:service("HttpService")

local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()

local screenSize = workspace.CurrentCamera.ViewportSize

local pickerGradient = "https://i.ibb.co/s2S44gK/rf.png" -- "https://i.ibb.co/Ht3MGSF/me.jpg" --"https://i.ibb.co/s2S44gK/rf.png"  "https://i.ibb.co/5L7qFg9/tt.png"
local huePicker = "https://i.ibb.co/m9LX1B8/hue.jpg"
local gradientImage = "https://i.ibb.co/R0XFXYc/gradient30.png"
local strongGradient = "https://i.ibb.co/Wnym9RS/x-gradient-200.png"
local bob = "https://i.ibb.co/9y9BZh1/bob.png"

local warn = warn
local Vector2 = Vector2
local Color3 = Color3
local Enum = Enum
local task = task
local math = math
local table = table

local shortenedInputNames = {["MouseButton1"] = "MB1", ["MouseButton2"] = "MB2", ["MouseButton3"] = "MB3", ["PageUp"] = "PUp", ["PageDown"] = "PDn", ["Home"] = "Hm", ["Delete"] = "Del", ["Insert"] = "Ins", ["LeftAlt"] = "LAlt", ["LeftControl"] = "LC", ["LeftShift"] = "LS", ["RightAlt"] = "RAlt", ["RightControl"] = "RC", ["RightShift"] = "RS", ["CapsLock"] = "Caps"}

local function vec2(x, y) -- me when hack
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)

    return Vector2.new(x, y)
end

local function toHex(str)
    local s, r = pcall(Color3.fromHex, str)

    if not s then
        gui:Notify("Invalid hex input!")

        return Color3.new(1, 1, 1)
    else
        return r
    end
end

local function toRGB(str)
    local tbl = string.split(str, ",")
    local r, g, b

    if #tbl == 3 then
        for i, v in ipairs(tbl) do
            tbl[i] = v:gsub("%s+", "")
        end

        r, g, b = math.clamp((tbl[1] or 255), 0, 255), math.clamp((tbl[2] or 255), 0, 255), math.clamp((tbl[3] or 255), 0, 255)
    else
        gui:Notify("Invalid RGB input!")

        r, g, b = 255, 255, 255
    end

    return Color3.fromRGB(r, g, b)
end

local isfile = isfile
local isfolder = isfolder
local makefolder = makefolder
local writefile = writefile
local readfile = readfile

local MAX_ZINDEX = 2147483647
local TEXT_ZINDEX = 2147483645

local cachedImageData = {}

local textBoxYielding = false

local function dictionaryLen(dictionary)
    local count = 0

    for _, _ in pairs(dictionary) do
        count = count + 1
    end

    return count
end

local dwBase = {}
local templates = {}

local notificationCache = {}
local lib = {
    _tabsContainer = {};
    _boundActionNames = {};
    _pointerStorage = {};
}

local dwContainer = {}
local accentContainer = {}
local activeDropdown
local activeColorPicker
local dropdownClickCount = 0

templates.ClassName = "templates"
templates.__index = templates

dwBase.ClassName = "dwBase"
dwBase.__index = dwBase

lib.ClassName = "lib"
lib.__index = lib

function dwBase:Set(property, value)
    assert(type(property) == "string")
    assert(value ~= nil)

    self._obj[property] = value

    if property == "Position" or property == "Size" then
        self:_calculateCorners()
    end
end

function dwBase:Move(pos)
    local offset = pos - self._obj.Position
    local welds = self:GetWelds()

    for _, v in pairs(welds) do
        v._obj.Position = v._obj.Position + offset
        v:_calculateCorners()
    end
end

function dwBase:Outline(color, thickness)
    color = color or Color3.new()
    thickness = thickness or 2

    thickness = thickness * 2

    self._outline = dwBase.new("Square")

    self._outline:Set("Color", color)
    self._outline:Set("Size", self._obj.Size + vec2(thickness, thickness))
    self._outline:Set("Filled", true)
    self._outline:Set("Position", self._obj.Position - (vec2(thickness, thickness)/2))
    self._outline:Set("Thickness", thickness * 2)
    self._outline:Set("ZIndex", self._obj.ZIndex - 1)
    self._outline:Set("Visible", true)

    self._outline:WeldTo(self)
end

function dwBase:Fade(percent, strong)
    percent = percent or 1
    assert(type(percent) == "number" and percent > 0 and percent <= 1, "Number > 0 and <= 1 expected")

    if self.Class == "Square" then
        if strong then
            self._gradient = templates.image(strongGradient)
        else
            self._gradient = templates.image(gradientImage)
        end

        --self._gradient:Set("Transparency", 0.8)
        self._gradient:Set("ZIndex", self._obj.ZIndex + 1)
        self._gradient:Set("Position", self._obj.Position)
        self._gradient:Set("Size", vec2(self._obj.Size.X, self._obj.Size.Y * percent))
        self._gradient:WeldTo(self)
    end
end

function dwBase:_updateWelds()
    self._weldConnections = self:GetWelds()
end

function dwBase:_accentElement()
    table.insert(accentContainer, self)
end

function dwBase:_removeAccentElement()
    local element = table.find(accentContainer, self)

    if element then
        table.remove(accentContainer, element)
    end
end

function dwBase:WeldTo(obj)
    if obj == self then
        warn("Objects cannot match")
    end

    -- if table.find(obj._welds, self) --[[or table.find(self._welds, obj)]] then
    --     warn(obj.Class, "is already welded \n"..debug.traceback())
    --     return
    -- end

    table.insert(obj._welds, self)
end

function dwBase:IsFocused(bypassOverlay)
    local mP = UserInputService:GetMouseLocation()

    self:_calculateCorners()

    local mX, mY = mP.X, mP.Y
    local x1, y1 = self._leftCorner.X, self._leftCorner.Y
    local x2, y2 = self._rightCorner.X, self._rightCorner.Y

    local focused = ((mX >= x1) and (mY >= y1)) and ((mX <= x2) and (mY <= y2))

    if focused and not bypassOverlay then
        for _, obj in pairs(dwContainer) do
            if (obj._selectable or obj._draggable) and obj._obj.Visible and obj._obj.Transparency ~= 0 then
                if  obj._obj.ZIndex > self._obj.ZIndex then
                    if obj:IsFocused() then
                        return false
                    end
                end
            end
        end
    end

    return focused
end

function dwBase:GetWelds()
    local objects = {}

    local f; f = function(tb)
        for ind, v in pairs(tb) do
            if ind ~= "_obj" then
                if ind == "_welds" then
                    if not table.find(objects, tb) then
                        table.insert(objects, tb)
                    end
                    f(v)
            elseif type(v) == "table" then
                    f(v)
                end
            end
        end
    end

    f(self)

    return objects
end

function dwBase:GetPosition()
    if self.Class == "Square" then
        local center = self._obj.Position + (self._obj.Size/vec2(2, 2))
        return vec2(math.round(center.X), math.round(center.Y))
    end
end

function dwBase:ConstrainText(text, area)
    if self.Class ~= "Text" then
        gui:Notify(("ConstrainText attempted on %s\n%s"):format(self.Class, debug.traceback()))
        return
    end

    self:Set("Text", text)
    local bX = self._obj.TextBounds.X

    local overflow = 1

    if bX > area then
        while true do
            if (self._obj.TextBounds.X < area) or overflow >= 100 then
                break
            end

            self:Set("Text", text:sub(1, -overflow).."... ")
            overflow += 1
        end
    end

    return self
end

function dwBase:OverflowText(text, allowedWidth)
    if self.Class ~= "Text" then
        gui:Notify(("OverflowText attempted on %s\n%s"):format(self.Class, debug.traceback()))
        return
    end

    text = text:gsub("\n", "")
    local words = string.split(text, " ")

    self:Set("Text", words[1])

    if self._obj.TextBounds.X > allowedWidth then
        self:Set("Text", "...")

        return
    end

    self:Set("Text", "")

    for _, v in ipairs(words) do
        local wordLen = #v
        local oldText = self._obj.Text

        self:Set("Text", oldText..v.." ")

        if self._obj.TextBounds.X > allowedWidth then
            self:Set("Text", oldText.."\n"..v.." ")
        end
    end
end

function dwBase:Callback()
    if self._callback then
        self._callback(self, table.unpack(self._callbackExtras))
    end
end

function dwBase:_calculateCorners()
    if self.Class == "Square" then
        self._leftCorner = self._obj.Position
        self._rightCorner = self._obj.Position + self._obj.Size
    end
end

function dwBase:Invis(bool, useTransparency)
    local function set(prop, val)
        for _, v in pairs(self:GetWelds()) do
            v:Set(prop, val)
        end
    end

    if useTransparency then
        set("Transparency", (bool and 0) or 1)
    else
        set("Visible", not bool)
    end
end

function dwBase:Destroy()
    for _, v in pairs(self:GetWelds()) do
        v._obj:Remove()
        v:_removeAccentElement()

        setmetatable(v, nil)
    end
end

function dwBase.new(type)
    local self = setmetatable({}, dwBase)

    self._obj = Drawing.new(type)
    self.Class = type
    self._welds = {}
    self._weldConnections = {}
    self._callbackExtras = {}

    table.insert(dwContainer, self)

    return self
end

function lib:ResetSubframes()
    for _, v in ipairs(self._tabsContainer) do
        for _, z in pairs(v._subframeContainer) do
            z:Invis(v ~= self._selectedTab)
            z._active = (v == self._selectedTab)
        end
    end
end

function lib:Destroy()
    for _, v in pairs(dwContainer) do
        if v._obj.__OBJECT_EXISTS then
            v._obj:Remove()
        end

        setmetatable(v, nil)
    end

    --self._inputConnection:Disconnect()
    --self._cursorConnection:Disconnect()
    --self._miscHeartbeatConnection:Disconnect()

    for i, _ in pairs(self._boundActionNames) do
        contextActionService:UnbindCoreAction(i)
    end

    setmetatable(self, nil)
end

local function GetXY(obj)
    local mousePos = UserInputService:GetMouseLocation()
    local sX, xY = obj._obj.Size.X, obj._obj.Size.Y
    local pX, pY = math.clamp(mousePos.X - obj._obj.Position.X, 0, sX), math.clamp(mousePos.Y - obj._obj.Position.Y, 0, xY)

    return pX/sX, pY/xY
end

function lib:Tab(data)
    assert(type(data.Title) == "string")

    local tabSize = self._insetSize.X/(self._tabs + 1)

    local tab = templates.button(
        {Size = vec2(tabSize, 30), Color = Color3.new(0.11, 0.11, 0.11), ZIndex = 7},
        {ZIndex = 9, Size = 20, Center = true},
        function(button)
            if self._selectedTab == button then
                return
            end

            self._selectedTab = button
            self:ResetSubframes()
            self._tabSelectionCover:Set("Position", button._obj.Position)
            self._tabSelectionCover._gradient:Set("Position", button._obj.Position)
            self._tabSelectionCover:Set("Size", button._obj.Size + vec2(0, 2))
            self._tabSelectionCover._gradient:Set("Size", button._obj.Size + vec2(0, 2))
        end
    )

    tab._subframeContainer = {}
    self._tabSize = tab._obj.Size.X

    table.insert(self._tabsContainer, tab)
    self._tabs += 1

    if self._tabs == 1 then
        tab:Set("Position", self._insetFrame._obj.Position + vec2(0, 4))

        self._selectedTab = tab
        self._tabSelectionCover:Set("Position", tab._obj.Position)
        self._tabSelectionCover._gradient:Set("Position", tab._obj.Position)
    else
        local lastPos = self._insetFrame._obj.Position + vec2(0, 4)

        for i, v in ipairs(self._tabsContainer) do
            local offset = (i == #self._tabsContainer and 0) or 2

            v:Set("Position", lastPos)
            v:Set("Size", vec2(tabSize - offset, 30))
            v._text:Set("Position", lastPos + vec2((tabSize - offset)/2, 5))

            lastPos = lastPos + vec2(tabSize, 0)
        end
    end

    tab._text:ConstrainText(data.Title, tabSize)

    self._tabSelectionCover:Set("Size", vec2(tabSize - 2, 32))
    self._tabSelectionCover._gradient:Set("Size", self._tabSelectionCover._obj.Size)

    tab:Outline()
    tab:WeldTo(self._tabsBar)
    --tab._text:Set("Position", tab:GetPosition() + vec2(0, -tab._text._obj.Size/2))

    function tab:Subframe(data)
        if #self._subframeContainer >= 8 then
            warn("Max of 8 subframes allowed \n"..debug.traceback())
            return
        end

        assert(type(data.Title) == "string", "String expected, got"..type(data.Title))

        local subframe = templates.frame({Size = vec2(gui._subFrameTemplateSize.X, 24), Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 6}) -- Account for outline

        subframe._accentBar = templates.frame({Size = vec2(gui._subFrameTemplateSize.X, 2), Color = gui._uiColor, ZIndex = 8}) -- Account for outline
        subframe._titleText = templates.textLabel({Text = data.Title, Size = 20, ZIndex = 9})

        subframe._accentBar:_accentElement()

        local subframeCount = #self._subframeContainer

        subframe._elements = {}

        if subframeCount == 0 then
            subframe:Set("Position", gui._insetFrame._obj.Position + vec2(6, 41))
        elseif subframeCount == 1 then
            subframe:Set("Position", gui._insetFrame._obj.Position + vec2(14 + gui._subFrameTemplateSize.X, 41))
        elseif subframeCount == 2 then
            subframe:Set("Position", gui._insetFrame._obj.Position + vec2(6, 50 + gui._subFrameTemplateSize.Y))
        else
            subframe:Set("Position", gui._insetFrame._obj.Position + vec2(14 + gui._subFrameTemplateSize.X, 50 + gui._subFrameTemplateSize.Y))
        end

        table.insert(self._subframeContainer, subframe)

        subframe._accentBar:Set("Position", subframe._obj.Position)
        subframe._titleText:Set("Position", subframe._obj.Position + vec2(4, 3))

        subframe:Fade()

        subframe:WeldTo(gui._insetFrame)
        subframe._accentBar:WeldTo(subframe)
        subframe._titleText:WeldTo(subframe._accentBar)
        subframe:Outline()
        subframe._accentBar:Outline()

        gui:ResetSubframes()

        function subframe:_resizeForElement(element)
            local diff = (element._obj.Position.Y + element._obj.Size.Y + 2) - self._obj.Position.Y

            self:Set("Size", vec2(self._obj.Size.X, diff + 8))
            self._outline:Set("Size", self._obj.Size + vec2(4, 4))

            task.delay(0.1, function()
                for i, v in pairs(tab._subframeContainer) do
                    if i ~= 1 and i ~= 2 then
                        if v._obj.Position.X == self._obj.Position.X then
                            local above = tab._subframeContainer[i - 2]._obj
                            v:Move(above.Position + vec2(0, above.Size.Y + 8))
                        end
                    end
                end
            end)
        end

        function subframe:Toggle(data)
            local button = templates.button(
                {Size = vec2(10, 10), Color = Color3.new(0.05, 0.05, 0.05), ZIndex = 10},
                {Text = data.Title, Size = 18, ZIndex = 10, Center = false},
                function(button)
                    if button._state then
                        button:Set("Color", Color3.new(0.05, 0.05, 0.05))
                        button:_removeAccentElement()
                        button._state = false
                    else
                        button:Set("Color", gui._uiColor)
                        button:_accentElement()
                        button._state = true
                    end

                    if data.Callback then
                        data.Callback(button._state)
                    end
                end
            )

            if data.Pointer then
                gui._pointerReg[data.Pointer] = button
            end

            button._elementCount = 0
            button._subframeWeight = button._obj.Size.Y + 10
            button._state = data.Enabled or false

            if data.Enabled then
                button:_accentElement()
                button:Set("Color", gui._uiColor)
            end

            if #self._elements == 0 then
                button:Set("Position", self._titleText._obj.Position + (vec2(6, 15 + (self._titleText._obj.TextBounds.Y/2))))
            else
                local lastElement = self._elements[#self._elements]
                button:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight))
            end

            table.insert(self._elements, button)

            button:Outline()
            button:Fade()

            button._text:Set("Position", button._obj.Position + vec2(16, -button._text._obj.Size/3))

            button:WeldTo(self)

            gui:ResetSubframes()
            self:_resizeForElement(button)

            function button:_getValue()
                return self._state
            end

            function button:_setValue(state)
                if not state then
                    button:Set("Color", Color3.new(0.05, 0.05, 0.05))
                    button:_removeAccentElement()
                    button._state = false
                else
                    button:Set("Color", gui._uiColor)
                    button:_accentElement()
                    button._state = true
                end

                if data.Callback then
                    data.Callback(state)
                end
            end

            function button:ColorPicker(data)
                local defaultColor = data.DefaultColor or Color3.new(1, 1, 1)
                self._elementCount += 1

                local colorDisplay = templates.frame({Size = vec2(28, 6), Position = vec2((subframe._obj.Position.X + subframe._obj.Size.X) - (42 * (self._elementCount)), button._obj.Position.Y + 2), ZIndex = 12, Color = defaultColor})
    
                local colorButton = templates.button(
                    {Size = vec2(32, 10), Position = colorDisplay._obj.Position + vec2(-2, -2), Color = defaultColor:Lerp(Color3.new(0, 0, 0), 0.5), ZIndex = 11},
                    nil,
                    function(button)
                        if activeColorPicker == button then
                            gui._colorPicker:Invis(true)

                            activeColorPicker = nil
                        else
                            local picker; picker = gui:GetColorPicker(
                                {Title = data.Title or "Color Picker", Position = button:GetPosition(), DefaultColor = colorDisplay._obj.Color, Callback = function(_, color)
                                    button:Set("Color", color:Lerp(Color3.new(0, 0, 0), 0.5))
                                    colorDisplay:Set("Color", color)
    
                                    picker:Invis(true)
    
                                    if data.Callback then
                                        data.Callback(color)
                                    end

                                    activeColorPicker = nil
                                end
                            })
    
                            picker:Invis(false)

                            activeColorPicker = button
                        end
                    end
                )
    
                if data.Pointer then
                    gui._pointerReg[data.Pointer] = colorButton
                end
                
                colorButton:WeldTo(self)
                colorDisplay:WeldTo(colorButton)
    
                colorButton:Outline()

                function colorButton:_getValue()
                    return colorDisplay._obj.Color -- jank but dn
                end

                function colorButton:_setValue(color)
                    colorButton:Set("Color", color:Lerp(Color3.new(0, 0, 0), 0.5))
                    colorDisplay:Set("Color", color)

                    if data.Callback then
                        data.Callback(color)
                    end
                end

                return colorButton
            end

            function button:Keybind(data)
                assert((typeof(data.DefaultKeybind) == "EnumItem") or (data.DefaultKeybind == nil))

                self._elementCount += 1

                local buttonPos = vec2((subframe._obj.Position.X + subframe._obj.Size.X) - (42 * (self._elementCount)) - 2, button._obj.Position.Y)
                local buttonSize = vec2(32, 10)
                local keybindName = "None"
    
                local casBindName = ("Keybind%s%s"):format(data.Title, gui._GUID)
                local setBindName = ("__keybindSet%s"):format(gui._GUID)

                local currentBind
    
                if data.DefaultKeybind then
                    local name = data.DefaultKeybind.Name

                    keybindName = shortenedInputNames[name] or name
                end
    
                local function keyCall(_, state)
                    if state ~= Enum.UserInputState.Begin then
                        return
                    end
    
                    if data.Callback then
                        data.Callback()
                    end
                end
    
                local function bind(newInput)
                    if newInput ~= "None" then
                        contextActionService:BindCoreActionAtPriority(
                            casBindName,
                            keyCall,
                            false,
                            2,
                            newInput
                        )
        
                        if data.KeybindChangedCallback then
                            data.KeybindChangedCallback(newInput)
                        end

                        currentBind = newInput
                        gui._boundActionNames[casBindName] = true

                        local buttonName = newInput.Name
                        buttonName = shortenedInputNames[buttonName] or buttonName

                        button._keybindButton._text:Set("Text", buttonName)
                    else
                        contextActionService:UnbindCoreAction(casBindName)
                        button._keybindButton._text:Set("Text", "None")

                        if data.KeybindChangedCallback then
                            data.KeybindChangedCallback(nil)
                        end

                        currentBind = nil
                        gui._boundActionNames[setBindName] = nil
                    end
                end
                
                if data.DefaultKeybind then
                    bind(data.DefaultKeybind)
                end
    
                button._keybindButton = templates.button(
                    {Size = buttonSize, Position = buttonPos, Color = Color3.new(0.05, 0.05, 0.05), ZIndex = 10},
                    {Text = keybindName, Size = 18, Center = true, Position = buttonPos + vec2(buttonSize.X/2, -5), ZIndex = 11},
                    function(button)
                        button._text:Set("Color", gui._uiColor)
                        button._text:Set("Text", ". . .")
                        button._text:_accentElement()
                        button._keybind = data.DefaultKeybind
    
                        contextActionService:BindCoreAction(
                            setBindName,
                            function(_, inputState, inputObject)
                                if (inputObject.KeyCode.Name == "Unknown" or inputObject.KeyCode.Name == 'Backspace')--[[ or inputState ~= Enum.UserInputState.Begin]] then
                                    -- made by topit 🤑🤑🤑🤑🤑🤑🤑
                                    button._text:Set("Color", Color3.new(1, 1, 1))
                                    button._text:Set("Text", "None")
                                    
                                    contextActionService:UnbindCoreAction(casBindName)
                                    contextActionService:UnbindCoreAction(setBindName)
                                    gui._boundActionNames[casBindName] = nil
                                    gui._boundActionNames[setBindName] = nil

                                    currentBind = nil
                                    
                                    if data.KeybindChangedCallback then
                                        data.KeybindChangedCallback(nil)
                                    end
                                    return
                                end

                                contextActionService:UnbindCoreAction(setBindName)
                                gui._boundActionNames[setBindName] = nil
    
                                button._text:Set("Color", Color3.new(1, 1, 1))
                                button._text:_removeAccentElement()
    
                                local newInput = inputObject.KeyCode
    
                                if newInput.Name == "Unknown" then
                                    newInput = inputObject.UserInputType
                                end
    
                                bind(newInput or "None")
    
                                gui._boundActionNames[casBindName] = true
                            end,
                            false,
                            table.unpack(Enum.KeyCode:GetEnumItems())--[[,
                            table.unpack(Enum.UserInputType:GetEnumItems())]]
                        )
    
                        gui._boundActionNames[setBindName] = true
                    end
                )

                local holder = {}

                if data.Pointer then
                    gui._pointerReg[data.Pointer] = holder
                end

                table.insert(subframe._elements, button)

                button._keybindButton:Outline()
    
                button._keybindButton:WeldTo(subframe)
                button._keybindButton._text:WeldTo(subframe)
    
                gui:ResetSubframes()
                subframe:_resizeForElement(button)

                function holder:_getValue()
                    return currentBind or "None"
                end

                function holder:_setValue(keybind)
                    bind(keybind)
                end

                return holder
            end

            return button
        end

        function subframe:ColorPickerToggle(data)
            gui:Notify(":ColorPickerToggle has been removed!\nPlease use <toggle>:ColorPicker instead.", 10)
            
            return
        end

        function subframe:Slider(data)
            local sliderSize = vec2(subframe._obj.Size.X - 22, 10)
            local defaultText = data.Default..(data.Measurement or "")
            local increment = data.Increment or 1

            local button = templates.button(
                {Size = sliderSize, Color = Color3.new(0.12, 0.12, 0.12), ZIndex = 10},
                {Text = defaultText, Center = true, ZIndex = 13, Size = 18},
                function(button)
                    local lastPercent = math.huge

                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and task.wait() do
                        local step = increment / data.Max
                        --local percent = math.clamp((UserInputService:GetMouseLocation() - button._obj.Position).X / button._obj.Size.X, 0, 1)
                        local percent = GetXY(button)

                        if percent ~= lastPercent then
                            local d = math.floor(percent / step + 0.5) * step
                            local floor = (math.floor((d * data.Max)*(1/increment)))/(1/increment)

                            button._frame:Set("Size", vec2(button._obj.Size.X * d, button._obj.Size.Y))
                            button._text:Set("Text", floor..(data.Measurement or ""))
                            button._value = floor
                            lastPercent = percent

                            if data.Callback then
                                data.Callback(floor)
                            end
                        end
                    end
                end
            )

            if data.Pointer then
                gui._pointerReg[data.Pointer] = button
            end

            button._frame = templates.frame({Size = sliderSize, Color = gui._uiColor, ZIndex = 11})
            button._titleText = templates.textLabel({Text = data.Title, Size = 18, ZIndex = 10, Center = false})
            button._value = data.Default

            button._subframeWeight = sliderSize.Y + 8

            button._frame:_accentElement()

            if #self._elements == 0 then
                button._titleText:Set("Position", self._titleText._obj.Position + (vec2(6, 12 + (self._titleText._obj.TextBounds.Y/2))))
                button:Set("Position", button._titleText._obj.Position + vec2(0, 20))
            else
                local lastElement = self._elements[#self._elements]

                button._titleText:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight - 8))
                button:Set("Position", button._titleText._obj.Position + vec2(0, 20))
            end

            table.insert(self._elements, button)

            button._frame:Set("Position", button._obj.Position)
            button._frame:Set("Size", vec2(button._frame._obj.Size.X * (data.Default/data.Max), button._frame._obj.Size.Y))

            button._text:Set("Position", button._obj.Position + vec2(button._obj.Size.X/2, -button._obj.Size.Y/2))

            button:Fade()
            button._gradient:Set("ZIndex", 12)

            button:Outline()
            button:WeldTo(self)
            button._titleText:WeldTo(self)
            button._frame:WeldTo(self)

            gui:ResetSubframes()
            self:_resizeForElement(button)

            function button:_getValue()
                return self._value
            end

            function button:_setValue(val)
                self._value = val

                self._frame:Set("Size", vec2(self._obj.Size.X * (val / data.Max), self._obj.Size.Y))
                self._text:Set("Text", val..(data.Measurement or ""))

                if data.Callback then
                    data.Callback(val)
                end
            end

            return button
        end

        function subframe:KeybindToggle(data)
            gui:Notify(":KeybindToggle has been removed!\nPlease use <toggle>:Keybind instead.", 10)
            
            return
        end

        function subframe:Button(data)
            assert(not (data.ClickedText and data.ConfirmationText))
            local cc = -1

            local button = templates.button(
                {Size = vec2(self._obj.Size.X - 22, 14), Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 9},
                {Text = data.Title, Center = true, Size = 20, ZIndex = 11},
                function(button)
                    cc = cc + 1

                    if data.ClickedText then
                        button._text:Set("Text", data.ClickedText)
                        button._text:Set("Color", gui._uiColor)
                        button._text:_accentElement()

                        task.delay(0.5, function()
                            button._text:Set("Text", data.Title)
                            button._text:Set("Color", Color3.new(1, 1, 1))
                            button._text:_removeAccentElement()
                        end)
                    end

                    if data.ConfirmationText then
                        if cc % 2 ~= 1 then
                            local ccc = cc
                            
                            button._text:Set("Text", data.ConfirmationText)
                            button._text:Set("Color", gui._uiColor)
                            button._text:_accentElement()

                            task.delay(2, function()
                                if ccc == cc then
                                    cc -= 1 

                                    button._text:Set("Text", data.Title)
                                    button._text:Set("Color", Color3.new(1, 1, 1))
                                    button._text:_removeAccentElement()
                                end
                            end)

                            return
                        else
                            button._text:Set("Text", data.Title)
                            button._text:Set("Color", Color3.new(1, 1, 1))
                            button._text:_removeAccentElement()
                        end
                    end

                    if data.ButtonCallback then
                        data.ButtonCallback()
                    end
                end
            )

            button._subframeWeight = button._obj.Size.Y + 10

            if #self._elements == 0 then
                button:Set("Position", self._titleText._obj.Position + (vec2(6, 14 + (self._titleText._obj.TextBounds.Y/2))))
            else
                local lastElement = self._elements[#self._elements]

                button:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight))
            end

            button._text:Set("Position", button:GetPosition() + vec2(0, -11))

            table.insert(self._elements, button)

            button:WeldTo(self)
            button._text:WeldTo(self)
            button:Outline()
            button:Fade()

            gui:ResetSubframes()
            self:_resizeForElement(button)
        end

        function subframe:TextBox(data)
            local button = templates.textBox(
                {Size = vec2(self._obj.Size.X - 22, 18), Color = Color3.new(0.07, 0.07, 0.07), ZIndex = 9},
                {Size = 20, ZIndex = 11},
                data.Callback
            )

            button._subframeWeight = button._obj.Size.Y + 10

            button._text:ConstrainText(data.DefaultText or "", button._obj.Size.X - 4)
            button._titleText = templates.textLabel({Text = data.Title, Size = 18, ZIndex = 10, Center = false})

            if #self._elements == 0 then
                button._titleText:Set("Position", self._titleText._obj.Position + (vec2(6, (self._titleText._obj.TextBounds.Y) - 4)))
            else
                local lastElement = self._elements[#self._elements]

                button._titleText:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight - 8))
            end

            if data.Pointer then
                gui._pointerReg[data.Pointer] = button
            end

            button:Set("Position", button._titleText._obj.Position + vec2(0, 20))
            button._text:Set("Position", button._obj.Position + vec2(4, -2))

            table.insert(self._elements, button)

            button:WeldTo(self)
            button._text:WeldTo(self)
            button:Outline()

            gui:ResetSubframes()
            self:_resizeForElement(button)

            function button:_getValue()
                return self._rawText or ""
            end

            function button:_setValue(text)
                self._rawText = text

                self._text:ConstrainText(text, self._obj.Size.X - 4)

                if data.Callback then
                    data.Callback(text)
                end
            end

            return button
        end

        function subframe:Dropdown(data)
            assert(type((data.Options) == "table") and dictionaryLen(data.Options) > 0, "Dictionary with atleast 1 value expected")

            local button = templates.button(
                {Size = vec2(self._obj.Size.X - 22, 18), Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 9},
                {Text = data.Title, Size = 20, ZIndex = 11},
                function(self)
                    self:ShowList(not self._listShown)
                end
            )

            if data.Pointer then
                gui._pointerReg[data.Pointer] = button
            end

            button._listShown = false
            button._subframeWeight = button._obj.Size.Y + 10
            button._selected = data.Options

            function button:_resetText()
                local str = ""

                for i, v in pairs(button._selected) do
                    if v then
                        str = str..i..", "
                    end
                end

                if str == "" then
                    button._text:ConstrainText("~ ~ ~", button._obj.Size.X - 4)
                else
                    button._text:ConstrainText(string.sub(str, 1, #str - 2), button._obj.Size.X - 4)
                end
            end

            button._titleText = templates.textLabel({Text = data.Title, Size = 18, ZIndex = 10, Center = false})

            if #self._elements == 0 then
                button._titleText:Set("Position", self._titleText._obj.Position + (vec2(6, (self._titleText._obj.TextBounds.Y) - 4)))
            else
                local lastElement = self._elements[#self._elements]

                button._titleText:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight - 8))
            end

            button:Set("Position", button._titleText._obj.Position + vec2(0, 20))

            button._text:Set("Position", button._obj.Position + vec2(4, -2))

            button._list = {}

            local lastPos = button._obj.Position + vec2(0, button._obj.Size.Y + 2)

            function button:_showList(state)
                self._listShown = state

                for _, v in pairs(self._list) do
                    v:Invis(not state, true)
                end
            end

            function button:ShowList(state)
                if activeDropdown == self then
                    self:_showList(state)
                else
                    if activeDropdown then
                        activeDropdown:_showList(false)
                    end

                    self:_showList(state)
                end

                activeDropdown = (state and self) or nil
            end

            for i, v in pairs(data.Options) do
                local listButton = templates.button(
                    {Size = button._obj.Size + vec2(0, 6), Color = button._obj.Color, Position = lastPos, ZIndex = 14},
                    {Text = i, Size = 20, ZIndex = 15},
                    function(self)
                        self:Enable(not self._state)

                        if data.Callback then
                            data.Callback(button._selected)
                        end
                    end
                )

                listButton._defaultText = i
                listButton._text:Set("Position", listButton._obj.Position + vec2(4, -2))
                listButton._text:ConstrainText(i, button._obj.Size.X - 4)
                lastPos = listButton._obj.Position + vec2(0, listButton._obj.Size.Y)

                listButton:Outline()

                button._list[i] = listButton

                function listButton:_enable(state)
                    button._selected[self._defaultText] = state
                    self._state = state

                    if state then
                        self._text:Set("Color", gui._uiColor)
                        self._text:_accentElement()
                    else
                        self._text:Set("Color", Color3.new(1, 1, 1))
                        self._text:_removeAccentElement()
                    end
                end

                function listButton:Enable(state)
                    if not data.MultiSelect and state then
                        for _, v in pairs(button._list) do
                            v:_enable(false)
                        end
                    end

                    self:_enable(state)
                    button:_resetText()
                end

                listButton:Enable(v)
                listButton:WeldTo(button)
            end

            function button:_getValue()
                return self._selected
            end

            function button:_setValue(list)
                self._selected = list

                for i, v in pairs(list) do
                    self._list[i]:Enable(v)
                end

                if data.Callback then
                    data.Callback(button._selected)
                end
            end

            button:_resetText()

            table.insert(self._elements, button)

            button:WeldTo(self)
            button._text:WeldTo(self)
            button:Outline()
            button:Fade()

            gui:ResetSubframes()
            self:_resizeForElement(button)
            button:_showList(false)
            
            return button
        end

        function subframe:ConfigWindow()
            if not isfolder("_fricklib") then
                makefolder("_fricklib")
                makefolder("_fricklib/configs")
            elseif not isfolder("_fricklib/configs") then
                makefolder("_fricklib/configs")
            end

            local window = templates.frame({Size = vec2(self._obj.Size.X - 22, 204), Color = Color3.new(0.1, 0.1, 0.1), ZIndex = 9})
            local textBoxText = ""

            if #self._elements == 0 then
                window:Set("Position", self._titleText._obj.Position + (vec2(6, 14 + (self._titleText._obj.TextBounds.Y/2))))
            else
                local lastElement = self._elements[#self._elements]

                window:Set("Position", lastElement._obj.Position + vec2(0, lastElement._subframeWeight))
            end

            local buttonFrame = templates.frame({Size = vec2(window._obj.Size.X - 12, 94), Position = window._obj.Position + vec2(6, 6), Color = Color3.new(0.095, 0.095, 0.095), ZIndex = 11})

            local buttonLength = (buttonFrame._obj.Size.X/2) - 3

            local configTable = {}
            local buttonObjects = {}

            local scrollBar
            local configButtons = 0
            local selectedConfig = nil
            local scrolls = 0
            local scrollStep = 0

            local function addConfig(name)
                table.insert(configTable, name)
                local configIndex = #configTable

                if configButtons == 4 then
                    scrollStep = 1
                    scrollBar = templates.frame({Size = vec2(4, buttonFrame._obj.Size.Y * (4 / (configButtons + 1))), Position = buttonFrame._obj.Position + vec2(buttonFrame._obj.Size.X - 4, 0), Color = gui._uiColor, ZIndex = 15})

                    scrollBar:_accentElement()
                    scrollBar:Outline()

                    scrollBar:WeldTo(buttonFrame)

                    configButtons += 1

                    contextActionService:BindCoreAction(
                        "__configFrameScroll",
                        function(_, _, inputObject)
                            if not buttonFrame:IsFocused(true) then
                                return Enum.ContextActionResult.Pass
                            end

                            local percent = (4 / (configButtons + 1))

                            if inputObject.Position.Z == 1 then
                                if scrolls == 0 then
                                    return Enum.ContextActionResult.Sink
                                end

                                scrollBar:Set("Position", scrollBar._obj.Position + vec2(0, -scrollStep))
                                scrollBar._outline:Set("Position", scrollBar._obj.Position - vec2(2, 2))

                                local tableStart = scrolls
                                scrolls -= 1

                                for i = tableStart, tableStart + 3 do
                                    local button = buttonObjects[i - (tableStart - 1)]
                                    local config = configTable[i]
                                    
                                    button._text:Set("Text", config)
                                end
                            else
                                if scrolls == (configButtons - 4) then
                                    return Enum.ContextActionResult.Sink
                                end

                                scrolls += 1

                                scrollBar:Set("Position", scrollBar._obj.Position + vec2(0, scrollStep))
                                scrollBar._outline:Set("Position", scrollBar._obj.Position - vec2(2, 2))

                                local tableStart = scrolls + 1

                                for i = tableStart, tableStart + 3 do
                                    local button = buttonObjects[i - (tableStart - 1)]
                                    local configName = configTable[i]
                                    
                                    button._text:Set("Text", configName)
                                end
                            end
            
                            return Enum.ContextActionResult.Sink
                        end,
                        false,
                        Enum.UserInputType.MouseWheel
                    )

                    return
                elseif configButtons > 4 then
                    scrollBar:Set("Size", vec2(4, buttonFrame._obj.Size.Y * (4 / (configButtons + 1))))
                    scrollBar._outline:Set("Size", scrollBar._obj.Size + vec2(4, 4))

                    configButtons += 1
                    scrollStep = ((buttonFrame._obj.Position.Y + buttonFrame._obj.Size.Y) - (scrollBar._obj.Position.Y + scrollBar._obj.Size.Y)) / (configButtons - 4)

                    return
                end

                local configButton = templates.button(
                    {Size = vec2(buttonFrame._obj.Size.X, 22), Color = Color3.new(0.12, 0.12, 0.12), Position = buttonFrame._obj.Position + vec2(0, 24 * configButtons), ZIndex = 13},
                    {Text = name, Size = 20, ZIndex = 14, Center = true},
                    function(self)
                        if selectedConfig == configIndex then
                            selectedConfig = nil

                            self._text:Set("Color", Color3.new(1, 1, 1))
                            self._text:_removeAccentElement()

                            return
                        elseif selectedConfig then
                            buttonObjects[selectedConfig]._text:Set("Color", Color3.new(1, 1, 1))
                            buttonObjects[selectedConfig]._text:_removeAccentElement()
                        end

                        selectedConfig = configIndex

                        self._text:Set("Color", gui._uiColor)
                        self._text:_accentElement()
                    end
                )

                configButton._text:Set("Position", configButton:GetPosition() - vec2(0, 11))

                configButtons += 1
                table.insert(buttonObjects, configButton)

                configButton:Outline()
                configButton:Fade()
                configButton:WeldTo(buttonFrame)
            end

            local function delConfig(name)
                local filePath = ("_fricklib/configs/%s.fcfg"):format(config)

                if not isfile(filePath) then
                    gui:Notify("Internal Error: Invalid file path!")

                    return
                end

                --[[temp]]
                gui:Notify("um... too hard...")
                return

                --delfile(filePath)

                -- ASAAAAASA WTF HELP TOO HARD :(((

                -- local configIndex for i, v in ipairs(configTable) do
                --     if v == name then
                --         configIndex = v

                --         break
                --     end
                -- end

                -- table.remove(configTable, configIndex)

                -- if configs =< 4 then
                --     buttonObjects[#buttonObjects]:Destroy()
                -- end
            end

            local nameBox = templates.textBox(
                {Size = vec2(buttonFrame._obj.Size.X, 18), Color = Color3.new(0.07, 0.07, 0.07), Position = buttonFrame._obj.Position + vec2(0, buttonFrame._obj.Size.Y + 6), ZIndex = 13},
                {Size = 20, ZIndex = 14},
                function(text)
                    textBoxText = text
                end
            )

            local newConfigButton = templates.button(
                {Size = vec2(buttonFrame._obj.Size.X, 18), Color = Color3.new(0.12, 0.12, 0.12), Position = nameBox._obj.Position + vec2(0, 24), ZIndex = 13},
                {Text = "New Configuration", Size = 20, ZIndex = 15, Center = true},
                function()
                    if textBoxText == "" then
                        gui:Notify("Please input a configuration name.")

                        return
                    end

                    local filePath = ("_fricklib/configs/%s.fcfg"):format(textBoxText)

                    if isfile(filePath) then
                        gui:Notify("This configuration already exists!")
                        
                        return
                    end

                    writefile(filePath, "")

                    addConfig(textBoxText)

                    gui:Notify(("%s.fcfg successfully created, don't forget to save your current configuration to this file!"):format(textBoxText))
                end
            )

            local saveButton = templates.button(
                {Size = vec2(buttonLength, 18), Color = Color3.new(0.12, 0.12, 0.12), Position = newConfigButton._obj.Position + vec2(0, 24), ZIndex = 13},
                {Text = "Save", Size = 20, ZIndex = 15, Center = true},
                function()
                    if not selectedConfig then
                        gui:Notify("Please select a configuration file!")

                        return
                    end

                    local config = configTable[selectedConfig]

                    writefile(("_fricklib/configs/%s.fcfg"):format(config), ("return %s"):format(gui:_serializePointers()))

                    gui:Notify("Configuration saved successfully!")
                end
            )

            local loadButton = templates.button(
                {Size = vec2(buttonLength, 18), Color = Color3.new(0.12, 0.12, 0.12), Position = saveButton._obj.Position + vec2(buttonLength + 6, 0), ZIndex = 13},
                {Text = "Load", Size = 20, ZIndex = 15, Center = true},
                function()
                    if not selectedConfig then
                        gui:Notify("Please select a configuration file!")

                        return
                    end

                    local config = configTable[selectedConfig]
                    local filePath = ("_fricklib/configs/%s.fcfg"):format(config)
                    local configuration = loadfile(filePath)()
                    gui:Notify(config)
                    gui:Notify(isfile(filePath))
                    gui:Notify(configuration)

                    gui:_loadConfig(configuration)

                    gui:Notify(("%s loaded successfully!"):format(config))
                end
            )

            local deleteButton = templates.button(
                {Size = vec2(buttonLength, 18), Color = Color3.new(0.12, 0.12, 0.12), Position = saveButton._obj.Position + vec2(0, 24), ZIndex = 13},
                {Text = "Delete", Size = 20, ZIndex = 15, Center = true},
                function()
                    if not selectedConfig then
                        gui:Notify("Please select a configuration file!")

                        return
                    end

                    local config = configTable[selectedConfig]

                    delfile(("_fricklib/configs/%s.fcfg"):format(config))
                end
            )

            local renameButton = templates.button(
                {Size = vec2(buttonLength, 18), Color = Color3.new(0.12, 0.12, 0.12), Position = deleteButton._obj.Position + vec2(buttonLength + 6, 0), ZIndex = 13},
                {Text = "Rename", Size = 20, ZIndex = 15, Center = true},
                function()
                    if not selectedConfig then
                        gui:Notify("Please select a configuration file!")

                        return
                    end

                    local config = configTable[selectedConfig]
                    local configButton = buttonObjects[selectedConfig]

                    if textBoxText == "" then
                        gui:Notify("Please type a valid file name!")

                        return
                    elseif textBoxText == config then
                        gui:Notify("File names cannot match!")

                        return
                    end

                    local newFilePath = ("_fricklib/configs/%s.fcfg"):format(textBoxText)
                    local oldFilePath = ("_fricklib/configs/%s.fcfg"):format(config)

                    local fileData = readfile(oldFilePath)

                    delfile(oldFilePath)
                    writefile(newFilePath, fileData)

                    configButton._text:Set("Text", textBoxText)
                    configTable[selectedConfig] = textBoxText
                end
            )

            nameBox._text:Set("Position", nameBox._obj.Position + vec2(4, -2))

            newConfigButton._text:Set("Position", newConfigButton:GetPosition() - vec2(0, 11))
            saveButton._text:Set("Position", saveButton:GetPosition() - vec2(0, 11))
            loadButton._text:Set("Position", loadButton:GetPosition() - vec2(0, 11))
            deleteButton._text:Set("Position", deleteButton:GetPosition() - vec2(0, 11))
            renameButton._text:Set("Position", renameButton:GetPosition() - vec2(0, 11))

            window:Outline()
            buttonFrame:Outline()

            nameBox:Outline()
            newConfigButton:Outline()
            saveButton:Outline()
            loadButton:Outline()
            deleteButton:Outline()
            renameButton:Outline()

            newConfigButton:Fade()
            saveButton:Fade()
            loadButton:Fade()
            deleteButton:Fade()
            renameButton:Fade()

            window:WeldTo(self)
            buttonFrame:WeldTo(window)
            
            newConfigButton:WeldTo(window)
            nameBox:WeldTo(window)
            saveButton:WeldTo(window)
            loadButton:WeldTo(window)
            deleteButton:WeldTo(window)
            renameButton:WeldTo(window)

            for _, v in ipairs(listfiles("_fricklib/configs")) do
                addConfig(string.gsub(string.gsub(v, "_fricklib/configs\\", ""), ".fcfg", ""))
            end

            gui:ResetSubframes()
            self:_resizeForElement(window)
        end

        return subframe
    end

    return tab
end

function lib:SetTitle(title)
    self._titleText:ConstrainText(title, self._mainFrame._obj.Size.X - 34)
end

function lib:SetKeybind(key)
    self._keybind = key
end

function lib:Hide()
    self._mainFrame:Invis(true)
    self._cursor:Set("Visible", false)
    self._cursor._outline:Set("Visible", false)

    self._enabled = false
end

function lib:Show()
    self._mainFrame:Invis(false)
    self._cursor:Set("Visible", true)
    self._cursor._outline:Set("Visible", true)
    self:ResetSubframes()

    self._enabled = true
end

function lib:Open()
    if self._enabled then
        self:Hide()
    else
        self:Show()
    end
end

function lib:SetIcon(imageData)
    self._image:Set("Data", imageData)
end

function lib:_serializePointers()
    local tbl = {}

    for i, v in pairs(self._pointerReg) do
        if tbl[i] then
            self:Notify("Repeat pointer found, ignoring.")

            continue
        end

        tbl[i] = v:_getValue()
    end

    return f_utils:tableToString(tbl)
end

function lib:_loadConfig(tbl)
    for i, v in pairs(tbl) do
        local element = self._pointerReg[i]

        if element then
            element:_setValue(v)
        end
    end
end

function templates.textLabel(properties)
    local self = dwBase.new("Text")

    self:Set("Color", Color3.new(1, 1, 1))
    self:Set("Outline", true)
    self:Set("Font", 1)

    for property, value in pairs(properties) do
        self:Set(property, value)
    end

    self:Set("Size", self._obj.Size)

    self:Set("Visible", true)

    return self
end

function templates.button(buttonProperties, textProperties, callback)
    local self = templates.frame(buttonProperties)

    if textProperties then
        self._text = templates.textLabel(textProperties)
        self._text:WeldTo(self)
    end

    self._selectable = true
    self._callback = callback

    return self
end

function templates.frame(properties)
    local self = dwBase.new("Square")

    self:Set("Filled", true)

    for property, value in pairs(properties) do
        self:Set(property, value)
    end

    self:Set("Visible", true)

    return self
end

function templates.image(data)
    local self = dwBase.new("Image")

    task.spawn(function()
        self:Set("Data", f_utils:loadImage(data))
    end)

    self:Set("ZIndex", 9)
    self:Set("Visible", true)
    self:Set("Size", vec2(22, 22))

    return self
end

function templates.textBox(buttonProps, textProps, callback)
    return templates.button(
        buttonProps,
        textProps, 
        function(self)
            if textBoxYielding then
                return
            end

            self._text:Set("Text", "")
            self._text:Set("Color", gui._uiColor)
            self._text:_accentElement()
            self._rawText = ""
            self._endChar = "|"

            textBoxYielding = true

            customKeyboard.Keypress:Connect(function(char)
                self._rawText ..= char
                self._text:ConstrainText(self._rawText..self._endChar, self._obj.Size.X - 4)
            end)

            customKeyboard.OnStop:Connect(function()
                textBoxYielding = false

                if callback then
                    callback(self._rawText)
                end

                self._text:ConstrainText(self._rawText, self._obj.Size.X - 4)

                self._text:Set("Color", Color3.new(1, 1, 1))
                self._text:_removeAccentElement()

                customKeyboard.OnStop:Disconnect()
            end)

            customKeyboard.OnBackspace:Connect(function()
                if #self._rawText ~= 0 then
                    self._rawText = self._rawText:sub(1, #self._rawText - 1)
                    self._text:ConstrainText(self._rawText..self._endChar, self._obj.Size.X - 4)
                end
            end)

            customKeyboard.OnPaste:Connect(function(clipboard)
                self._rawText..= clipboard
            end)

            task.spawn(function()
                while textBoxYielding do
                    self._endChar = "|"
                    self._text:ConstrainText(self._rawText..self._endChar, self._obj.Size.X - 4)
                    task.wait(0.4)
                    self._endChar = ""
                    self._text:ConstrainText(self._rawText, self._obj.Size.X - 4)
                    task.wait(0.4)
                end
            end)

            customKeyboard:Start()
        end
    )
end

function lib:colorPicker(data)
    local self = templates.frame({Size = vec2(290, 209), Position = data.Position, Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 50})

    function self:setColor(color)
        self._h, self._s, self._v = color:ToHSV()

        self._hueBar:Set("Position", (self._obj.Position + vec2(8, 26 + (150 * self._h) - 2)))
        self._colorBall:Set("Position", self._picker._obj.Position + vec2(150 * self._s, 150 * self._v))
        self._picker:Set("Color", Color3.fromHSV(self._h, 1, 1))
        self._colorDisplay:Set("Color", color)

        self._hexBox._text:Set("Text", "#"..color:ToHex())
        self._rgbBox._text:Set("Text", ("%i, %i, %i"):format(color.R * 255, color.G * 255, color.B * 255))

        self._applyButton._callbackExtras[1] = color
        self._defaultColor = color
    end

    self._defaultColor = data.DefaultColor or Color3.new(0.5, 0.5, 0.5)
    self._h, self._s, self._v = self._defaultColor:ToHSV()
    --warn(self._h, self._s, self._v)
    self._accentBar = templates.frame({Size = vec2(self._obj.Size.X, 2), Position = data.Position + vec2(0, -3), Color = gui._uiColor, ZIndex = 52})
    self._titleText = templates.textLabel({Text = data.Title, ZIndex = 52, Size = 20, Center = false, Position = data.Position + vec2(3, -2)})
    self._oldColorDisplay = templates.frame({Size = vec2(74, 34), Position = data.Position + vec2(204, 38), Color = data.DefaultColor, ZIndex = 52})
    self._colorDisplay = templates.frame({Size = vec2(74, 34), Position = self._oldColorDisplay._obj.Position + vec2(0, 60), Color = data.DefaultColor, ZIndex = 52})
    self._oldDisplayText = templates.textLabel({Text = "Old Color:", Size = 20, ZIndex = 52, Center = true})
    self._displayText = templates.textLabel({Text = "New Color:", Size = 20, ZIndex = 52, Center = true})
    self._hueBar = templates.frame({Size = vec2(19, 4), Position = (data.Position + vec2(8, 26 + (150 * self._h) - 2)), ZIndex = 56, Color = Color3.new(1, 1, 1), })
    self._colorBall = dwBase.new("Circle")

    self._applyButton = templates.button(
        {Size = vec2(74, 35), Position = data.Position + vec2(204, 168), ZIndex = 52},
        {Text = "Apply", Size = 20, ZIndex = 55, Center = true},
        data.Callback
    )

    self._applyButton._callbackExtras[1] = self._defaultColor

    self._picker = templates.button(
        {Size = vec2(150, 150), Position = data.Position + vec2(38, 26), Color = Color3.fromHSV(self._h, 1, 1), ZIndex = 52},
        nil,
        function()
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and task.wait() do
                local step = 1 / 150
                local percentX, percentY = GetXY(self._picker)
                local fX = math.floor(percentX / step + 0.5) * step
                local fY = math.floor(percentY / step + 0.5) * step

                self._colorBall:Set("Position", self._picker._obj.Position + vec2(150 * fX, 150 * fY))
                self._s = fX
                self._v = fY

                local color = Color3.fromHSV(self._h, self._s, self._v)

                self._colorDisplay:Set("Color", color)
                self._applyButton._callbackExtras[1] = color

                self._hexBox._text:Set("Text", "#"..color:ToHex())
                self._rgbBox._text:Set("Text", ("%i, %i, %i"):format(color.R * 255, color.G * 255, color.B * 255))
            end
        end
    )

    self._hueFrame = templates.button(
        {Size = vec2(15, 150), Position = data.Position + vec2(10, 26), ZIndex = 52},
        nil,
        function()
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and task.wait() do
                local step = 1 / 150
                local _, percentY = GetXY(self._picker)
                local fY = math.floor(percentY / step + 0.5) * step

                self._hueBar:Set("Position", self._huePicker._obj.Position + vec2(-2, (150 * fY) - 2))
                self._picker:Set("Color", Color3.fromHSV(self._h, 1, 1))
                self._h = fY

                local color = Color3.fromHSV(self._h, self._s, self._v)

                self._colorDisplay:Set("Color", color)
                self._applyButton._callbackExtras[1] = color

                self._hexBox._text:Set("Text", "#"..color:ToHex())
                self._rgbBox._text:Set("Text", ("%i, %i, %i"):format(color.R * 255, color.G * 255, color.B * 255))
            end
        end
    )

    self._hexBox = templates.textBox(
        {Size = vec2(70, 18), Color = Color3.new(0.07, 0.07, 0.07), Position = self._hueFrame._obj.Position + vec2(0, self._hueFrame._obj.Size.Y + 9), ZIndex = 52},
        {Size = 20, ZIndex = 54},
        function(text)
            self:setColor(toHex(text))
        end
    )

    self._rgbBox = templates.textBox(
        {Size = vec2(100, 18), Color = Color3.new(0.07, 0.07, 0.07), Position = self._hexBox._obj.Position + vec2(self._hexBox._obj.Size.X + 8, 0), ZIndex = 52},
        {Size = 20, ZIndex = 54},
        function(text)
            local newColor = toRGB(text)

            self:setColor(newColor)
            self._rgbBox._text:Set("Text", tostring(newColor))
        end
    )

    self._hexBox._text:Set("Position", self._hexBox._obj.Position + vec2(4, -2))
    self._rgbBox._text:Set("Position", self._rgbBox._obj.Position + vec2(4, -2))

    self._hexBox._text:ConstrainText("#"..self._defaultColor:ToHex(), self._hexBox._obj.Size.X - 4)
    self._rgbBox._text:ConstrainText(("%i, %i, %i"):format(self._defaultColor.R * 255, self._defaultColor.G * 255, self._defaultColor.B * 255), self._rgbBox._obj.Size.X - 4)

    self._accentBar:_accentElement()

    self._huePicker = templates.image(huePicker)
    self._pickerGradient = templates.image(pickerGradient)

    self._pickerGradient:Set("Size", vec2(150, 150))
    self._huePicker:Set("Size", self._hueFrame._obj.Size)
    self._colorBall:Set("Radius", 6)
    self._pickerGradient:Set("ZIndex", 53)
    self._huePicker:Set("ZIndex", 52)
    self._colorBall:Set("ZIndex", 54)
    self._colorBall:Set("Thickness", 3)
    self._colorBall:Set("NumSides", 14)
    self._colorBall:Set("Visible", true)

    self._colorBall:Set("Color", Color3.new(1, 1, 1))

    self._pickerGradient:Set("Position", data.Position + vec2(38, 26))
    self._huePicker:Set("Position", self._hueFrame._obj.Position)
    self._oldDisplayText:Set("Position", self._oldColorDisplay._obj.Position + vec2(self._oldColorDisplay._obj.Size.X/2, -self._oldDisplayText._obj.TextBounds.Y))
    self._displayText:Set("Position", self._colorDisplay._obj.Position + vec2(self._colorDisplay._obj.Size.X/2, -self._displayText._obj.TextBounds.Y))
    self._applyButton._text:Set("Position", self._applyButton:GetPosition() + vec2(0, -self._applyButton._text._obj.TextBounds.Y/2))

    self._colorBall:Set("Position", self._picker._obj.Position + vec2(150 * self._s, 150 * self._v))

    self:Outline()
    self._accentBar:Outline()
    self._picker:Outline()
    self._hueFrame:Outline()
    self._applyButton:Outline()
    self._colorDisplay:Outline()
    self._oldColorDisplay:Outline()
    self._applyButton:Fade()
    self._hexBox:Outline()
    self._rgbBox:Outline()

    self._accentBar:WeldTo(self)
    self._titleText:WeldTo(self)
    self._picker:WeldTo(self)
    self._pickerGradient:WeldTo(self._picker)
    self._hueFrame:WeldTo(self)
    self._huePicker:WeldTo(self._hueFrame)
    self._applyButton:WeldTo(self)
    self._displayText:WeldTo(self)
    self._oldDisplayText:WeldTo(self)
    self._colorDisplay:WeldTo(self)
    self._oldColorDisplay:WeldTo(self)
    self._applyButton._text:WeldTo(self._applyButton)
    self._hueBar:WeldTo(self._hueFrame)
    self._colorBall:WeldTo(self._picker)

    return self
end

function lib:GetColorPicker(data)
    if self._colorPicker then
        self._colorPicker:setColor(data.DefaultColor)
        self._colorPicker._oldColorDisplay:Set("Color", data.DefaultColor)
        self._colorPicker._hexBox._text:Set("Text", "#"..data.DefaultColor:ToHex())
        self._colorPicker._rgbBox._text:Set("Text", ("%i, %i, %i"):format(data.DefaultColor.R * 255, data.DefaultColor.G * 255, data.DefaultColor.B * 255))

        self._colorPicker._titleText:Set("Text", data.Title)
        self._colorPicker:Move(data.Position)

        self._colorPicker._applyButton._callback = data.Callback
    else
        self._colorPicker = self:colorPicker(data)
    end

    return self._colorPicker
end

function lib:Notify(text, lifetime, overflow)
    text = ((typeof(text) == "string") and text) or tostring(text)

    task.spawn(function()
        local frame = templates.frame(
            {Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 100}
        )

        frame._accentBar = templates.frame(
            {Color = self._uiColor, ZIndex = 102}
        )

        frame._text = templates.textLabel(
            {Text = text, Size = 20, ZIndex = 102}
        )

        if overflow then
            frame._text:OverflowText(text, overflow)
        end

        local lastNotif = notificationCache[#notificationCache]

        local notifPos = (lastNotif and vec2(self._defaultNotificationPosition.X, lastNotif._realPosition.Y + lastNotif._obj.Size.Y + 8)) or self._defaultNotificationPosition
        local textBounds = frame._text._obj.TextBounds

        frame:Set("Size", vec2(textBounds.X + 8, textBounds.Y))
        frame:Set("Position", notifPos - vec2(frame._obj.Size.X + textBounds.Y, 0))
        frame._realPosition = notifPos

        frame._accentBar:Set("Size", vec2(2, textBounds.Y))
        frame._accentBar:Set("Position", frame._obj.Position + vec2(-4, 0))

        frame._text:Set("Position", frame._obj.Position + vec2(4, -3))

        local notifIndex = #notificationCache + 1

        notificationCache[notifIndex] = frame

        frame:Fade() 
        frame:Outline()
        frame._accentBar:Outline()

        frame._accentBar:_accentElement()

        frame._accentBar:WeldTo(frame)
        frame._text:WeldTo(frame)

        local framePos = frame._obj.Position

        for i = 1, 30 do
            local x = vec2(framePos.X, frame._obj.Position.Y):Lerp(vec2(notifPos.X, frame._obj.Position.Y), tweenService:GetValue(i/30, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out))

            frame:Move(x)

            task.wait()
        end

        task.wait(lifetime or 2)

        notifIndex = table.find(notificationCache, frame)
        table.remove(notificationCache, notifIndex)

        for i = notifIndex, #notificationCache, 1 do
            local v = notificationCache[i]
            local currentPos = v._obj.Position
            local endPos = vec2(self._defaultNotificationPosition.X, currentPos.Y - (frame._obj.Size.Y + 8))
            local moveSteps = 12
            local moveCount = 0

            if v._moveConn then
                v._moveConn:Disconnect()
                v:Move(v._realPosition)
            end

            v._realPosition = endPos

            v._moveConn = runService.RenderStepped:Connect(function()
                moveCount += 1

                v:Move(vec2(v._obj.Position.X, currentPos.Y):Lerp(vec2(v._obj.Position.X, endPos.Y), moveCount/moveSteps))

                if moveCount == moveSteps then
                    v._moveConn:Disconnect()
                    v._moveConn = nil
                end
            end)
        end

        local framePos = frame._realPosition
        local endPos = vec2(-frame._obj.Size.X, framePos.Y)

        for i = 1, 16 do
            local x = vec2(framePos.X, frame._obj.Position.Y):Lerp(vec2(endPos.X, frame._obj.Position.Y), tweenService:GetValue(i/16, Enum.EasingStyle.Exponential, Enum.EasingDirection.In))

            frame:Move(x)

            task.wait()
        end

        if frame._moveConn then
            frame._moveConn:Disconnect()
        end

        frame:Destroy()
    end)
end

function lib.new(data)
    local self = setmetatable({}, lib)
    self._GUID = httpService:GenerateGUID()
    self._pointerReg = {}
    gui = self

    local size = data.Size or vec2(450, 600)
    local title = data.Title or ""
    local leftCorner = (screenSize/2) - (vec2(size.X, size.Y)/2)

    self._defaultUIColor = data.Color or Color3.fromRGB(255, 200, 61)
    self._uiColor = data.Color or Color3.fromRGB(255, 200, 61)

    self._mainFrame = templates.frame({Size = size, Position = leftCorner, Color = Color3.new(0.135, 0.135, 0.135), ZIndex = 1})
    self._mainAccentBar = templates.frame({Size = vec2(size.X, 3), Position = leftCorner + vec2(0, -5), Color = self._uiColor, ZIndex = 1})
    self._insetFrame = templates.frame({Color = Color3.new(0.145, 0.145, 0.145), ZIndex = 4})
    self._insetAccentBar = templates.frame({Size = vec2(size.X - 20, 3), Color = self._uiColor, ZIndex = 5})
    self._tabsBar = templates.frame({Size = vec2(size.X - 20, 30), Color = Color3.new(0.085, 0.085, 0.085), ZIndex = 5})
    self._titleText = templates.textLabel({Size = 20, ZIndex = 2, Center = false, Position = leftCorner + vec2(34, 2)})
    self._draggerSquare = templates.frame({Size = size, Position = leftCorner, Filled = false, Thickness = 2, Transparency = 0, Color = self._uiColor, ZIndex = 47})
    --self._draggerOutline = templates.frame({Size = size, Position = leftCorner, Filled = false, Thickness = 6, Transparency = 0, ZIndex = 46})

    self._mainAccentBar:_accentElement()
    self._insetAccentBar:_accentElement()
    self._draggerSquare:_accentElement()

    self._titleText:ConstrainText(data.Title, size.X - 34)

    self._enabled = true
    self._tabs = 0

    self._insetSize = vec2(size.X - 20, (size.Y - 20) - (self._titleText._obj.TextBounds.Y))
    self._insetPos = (screenSize/2) - (vec2(self._insetSize.X, self._insetSize.Y - self._titleText._obj.TextBounds.Y))/2

    self._tabSelectionCover = templates.frame({Size = vec2(self._insetSize.X, 32), Color = Color3.new(0.145, 0.145, 0.145), ZIndex = 8})
    self._tabSize = self._insetSize

    self._mainFrame:Outline()
    self._mainFrame:Fade(0.04)

    self._subFrameTemplateSize = self._insetSize/2 - vec2(10, 28) --- vec2(0, 36)
    self._defaultNotificationPosition = vec2(16, 74)
    self._tabSubframeContainer = {}
    self._flags = {}

    self._mainFrame._draggable = true
    self._mainFrame._callback = function()
        local lastMousePos = UserInputService:GetMouseLocation()
        local lastDiff = self._draggerSquare._obj.Position

        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and task.wait() do
            local mousePos = UserInputService:GetMouseLocation()

            if lastMousePos ~= mousePos then
                local diff = lastMousePos - mousePos
                self._draggerSquare:Set("Transparency", 1)
                --self._draggerOutline:Set("Transparency", 1)

                lastMousePos = mousePos

                lastDiff = self._draggerSquare._obj.Position - diff
                self._draggerSquare:Set("Position", lastDiff)
                --self._draggerOutline:Set("Position", lastDiff)
            end
        end

        self._mainFrame:Move(lastDiff)
        self._draggerSquare:Set("Transparency", 0)
        --self._draggerOutline:Set("Transparency", 0)
    end

    self._mainAccentBar:Outline()

    self._insetFrame:Set("Size", self._insetSize)
    self._insetFrame:Set("Position", self._insetPos)
    self._insetFrame:Outline()

    self._insetAccentBar:Set("Position", self._insetPos - vec2(0, 1))
    self._insetAccentBar:Outline()

    self._tabsBar:Set("Position", self._insetPos + vec2(0, 4))
    self._tabsBar:Outline()

    self._tabSelectionCover:Fade()
    self._tabSelectionCover:WeldTo(self._mainFrame)

    self._image = templates.image(data.Icon or "https://uc-emoji.azureedge.net/orig/04/b73264054f821b22f7353afe068719.png") --("https://i.ibb.co/0Q1z7xz/warlockis.png")  --bob
    self._image:Set("Position", leftCorner + vec2(6, 2))

    self._mainAccentBar:WeldTo(self._mainFrame)
    self._insetFrame:WeldTo(self._mainFrame)
    self._insetAccentBar:WeldTo(self._mainFrame)
    self._tabsBar:WeldTo(self._mainFrame)
    self._titleText:WeldTo(self._mainFrame)
    self._image:WeldTo(self._mainFrame)

    self._cursor = dwBase.new("Quad")
    self._cursor._outline = dwBase.new("Quad")

    self._cursor:Set("Color", self._uiColor)
    self._cursor:Set("Filled", true)
    self._cursor:Set("ZIndex", MAX_ZINDEX)

    self._cursor._outline:Set("Color", Color3.new())
    self._cursor._outline:Set("Filled", true)
    self._cursor._outline:Set("ZIndex", MAX_ZINDEX - 1)

    self._cursorSizeMultiplier = 0.5
    self._cursorOutlineThickness = 2

    -- self._inputConnection = UserInputService.InputBegan:Connect(function(input, gpe)


    --     if not gpe and input.UserInputType.Value == 0 then -- removed 2 indexes and if statement 🍇🍇👵🍇👨‍🎓👩‍🎓👩‍🎓
    --         if not self._enabled then
    --             return
    --         end

    --         local mP = UserInputService:GetMouseLocation()

    --         for _, obj in ipairs(dwContainer) do
    --             if obj._selectable or obj._draggable then
    --                 if obj._obj.Visible and obj._obj.Transparency ~= 0 then
    --                     if obj:IsFocused() then
    --                         obj:Callback()
    --                         break
    --                     end
    --                 end
    --             end
    --         end
    --     -- elseif input.KeyCode == self._keybind then
    --     --     if self._enabled then
    --     --         self:Hide()
    --     --     else
    --     --         self:Show()
    --     --     end
    --     end
    -- end)

    self._inputConnection = {Disconnect = function() end} -- me when hack
    local clickBindName = ("__fricklibClick%s"):format(self._GUID)

    contextActionService:BindCoreActionAtPriority(
        clickBindName,
        function(_, inputState)
            if inputState ~= Enum.UserInputState.Begin then
                return
            end

            for _, obj in ipairs(dwContainer) do
                if obj._selectable or obj._draggable then
                    if obj._obj.Visible and obj._obj.Transparency ~= 0 then
                        if obj:IsFocused() then
                            obj:Callback()

                            return Enum.ContextActionResult.Sink
                        end
                    end
                end
            end

            return Enum.ContextActionResult.Pass
        end,
        false,
        0,
        Enum.UserInputType.MouseButton1
    )

    self._boundActionNames[clickBindName] = true

    -- self._cursorConnection = mouse.Move:Connect(function()
    --     if not self._enabled then
    --         return
    --     end

    --     local mousePos = UserInputService:GetMouseLocation()

    --     self._cursor:Set("PointA", mousePos)
    --     self._cursor:Set("PointB", mousePos + (vec2(23, 23)) * self._cursorSizeMultiplier)
    --     self._cursor:Set("PointC", mousePos + (vec2(10, 23)) * self._cursorSizeMultiplier)
    --     self._cursor:Set("PointD", mousePos + (vec2(0, 32)) * self._cursorSizeMultiplier)

    --     self._cursor._outline:Set("PointA" ,mousePos + (vec2(-self._cursorOutlineThickness, -self._cursorOutlineThickness * 2.66666667))  * self._cursorSizeMultiplier)
    --     self._cursor._outline:Set("PointB", mousePos + (vec2(23 + (self._cursorOutlineThickness * 2.33333333), 23 + self._cursorOutlineThickness))  * self._cursorSizeMultiplier)
    --     self._cursor._outline:Set("PointC", mousePos + (vec2(10 + self._cursorOutlineThickness, 23 + self._cursorOutlineThickness))  * self._cursorSizeMultiplier)
    --     self._cursor._outline:Set("PointD", mousePos + (vec2(-self._cursorOutlineThickness, 32 + (self._cursorOutlineThickness * 2.33333333)))  * self._cursorSizeMultiplier)
    -- end)

    -- self._miscHeartbeatConnection = runService.Heartbeat:Connect(function()
    --     local formattedTime = os.date("%I")..":"..os.date("%M")..":"..os.date("%S").." "..string.upper(os.date("%p")).." "..os.date("%b")..". "..os.date("%d")..", "..os.date("%Y")

    --     self._titleText:ConstrainText("Apathy | Build: dev | "..formattedTime.." | 2.0.0 [ALPHA]", self._mainFrame._obj.Size.X - 34)
    -- end)

    function self:SetAccentColor(color)
        for _, v in pairs(accentContainer) do
            v:Set("Color", color)
        end

        self._cursor._obj.Color = color
        self._uiColor = color
    end

    self._cursor:Set("Visible", true)
    self._cursor._outline:Set("Visible", true)

    self._enabled = true

    return self
end

return lib
