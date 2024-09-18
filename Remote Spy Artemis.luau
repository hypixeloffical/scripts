-- Instances

local ScreenGui = Instance.new("ScreenGui")
local RemoteSpy = Instance.new("Frame")
local RemoteHolder = Instance.new("ScrollingFrame")
local Template = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")
local Code = Instance.new("TextLabel")
local Copy = Instance.new("TextButton")
local UIStroke = Instance.new("UIStroke")
local Args = Instance.new("StringValue")
local Remote = Instance.new("ObjectValue")

-- Properties

ScreenGui.Parent = gethui()
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

RemoteSpy.Name = "RemoteSpy"
RemoteSpy.Parent = ScreenGui
RemoteSpy.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.141176)
RemoteSpy.BorderColor3 = Color3.new(0, 0, 0)
RemoteSpy.BorderSizePixel = 0
RemoteSpy.Position = UDim2.new(0.148628086, 0, 0.262697011, 0)
RemoteSpy.Size = UDim2.new(0, 353, 0, 225)

UIStroke.Name = "UIStroke"
UIStroke.Parent = RemoteSpy
UIStroke.Color = Color3.new(1, 1, 1)
UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
UIStroke.Thickness = 3

RemoteHolder.Name = "RemoteHolder"
RemoteHolder.Parent = RemoteSpy
RemoteHolder.Active = true
RemoteHolder.BackgroundColor3 = Color3.new(0.172549, 0.172549, 0.172549)
RemoteHolder.BorderColor3 = Color3.new(0, 0, 0)
RemoteHolder.BorderSizePixel = 0
RemoteHolder.Size = UDim2.new(0, 107, 0, 225)
RemoteHolder.BottomImage = ""
RemoteHolder.MidImage = ""
RemoteHolder.ScrollBarThickness = 0
RemoteHolder.TopImage = ""

Template.Name = "Template"
Template.Parent = RemoteHolder
Template.BackgroundColor3 = Color3.new(0.129412, 0.129412, 0.129412)
Template.BorderColor3 = Color3.new(0, 0, 0)
Template.BorderSizePixel = 0
Template.Size = UDim2.new(0, 107, 0, 17)
Template.Visible = false
Template.Font = Enum.Font.SourceSans
Template.TextColor3 = Color3.new(1, 1, 1)
Template.TextScaled = true
Template.TextSize = 14
Template.TextWrapped = true

Args.Name = "Args"
Args.Parent = Template

Remote.Name = "Remote"
Remote.Parent = Template

UIListLayout.Parent = RemoteHolder
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

Code.Name = "Code"
Code.Parent = RemoteSpy
Code.BackgroundColor3 = Color3.new(0.219608, 0.219608, 0.219608)
Code.BorderColor3 = Color3.new(0, 0, 0)
Code.BorderSizePixel = 0
Code.Position = UDim2.new(0.320113301, 0, 0.0315858275, 0)
Code.Size = UDim2.new(0, 233, 0, 133)
Code.Font = Enum.Font.SourceSans
Code.Text = "hi\\nhello"
Code.TextColor3 = Color3.new(1, 1, 1)
Code.TextSize = 14
Code.TextXAlignment = Enum.TextXAlignment.Left
Code.TextYAlignment = Enum.TextYAlignment.Top

Copy.Name = "Copy"
Copy.Parent = RemoteSpy
Copy.BackgroundColor3 = Color3.new(0.129412, 0.129412, 0.129412)
Copy.BorderColor3 = Color3.new(0, 0, 0)
Copy.BorderSizePixel = 0
Copy.Position = UDim2.new(0.365439087, 0, 0.675555527, 0)
Copy.Size = UDim2.new(0, 200, 0, 50)
Copy.Font = Enum.Font.SourceSans
Copy.Text = "Copy"
Copy.TextColor3 = Color3.new(1, 1, 1)
Copy.TextSize = 35

-- Scripts

local function QOPCGW_fake_script() -- RemoteSpy.LocalScript 
	local script = Instance.new('LocalScript', RemoteSpy)

	local template = Template
	
	Copy.MouseButton1Click:Connect(function()
		setclipboard(Code.Text)
	end)
	
	function readTable(t: {}): string
		local result = "{"
		for i, v in pairs(t) do
			if type(v) == "table" then
				result = result .. i .. " = " .. readTable(v) .. ","
			else
				result = result .. i .. " = " .. tostring(v) .. ","
			end
		end
		return result .. "}"
	end
	
	function instancetoPath(instance: Instance): string
		local path = instance.Name
		local parent = instance.Parent
		while parent do
			local name = parent.Name
			if parent == game then
				name = "game"
			end
			path = name .. "." .. path
			parent = parent.Parent
		end
		if path:sub(1,14) == "game.Workspace" then
			path = "workspace" .. path:sub(15,#path)
		end
		return path
	end
	
	function formatArgs(Args)
		local result = {}
		for i, v in pairs(Args) do
			if type(v) == "table" then
				table.insert(result, `{readTable(v)}`)
			elseif typeof(v) == "Color3" then
				table.insert(result, `Color3.new({tostring(v)})`)
			elseif typeof(v) == "NumberRange" then
				table.insert(result, `NumberRange.new({v.Min}, {v.Max})`)
			elseif typeof(v) == "NumberSequence" then
				local extra = {}
				for _,keypoint in pairs(v.Keypoints) do
					table.insert(extra, `NumberSequenceKeypoint.new({keypoint.Time}, {keypoint.Value}, {keypoint.Envelope})`)
				end
				table.insert(result, `NumberSequence.new({table.concat(extra, ", ")})`)
			elseif typeof(v) == "ColorSequence" then
				local extra = {}
				for _,keypoint in pairs(v.Keypoints) do
					table.insert(extra, `ColorSequenceKeypoint.new({keypoint.Time}, Color3.new({keypoint.Value}))`)
				end
				table.insert(result, `ColorSequence.new({table.concat(extra, ", ")})`)
			elseif typeof(v) == "NumberSequenceKeypoint" then
				table.insert(result, `NumberSequenceKeypoint.new({v.Time}, {v.Value}, {v.Envelope})`)
			elseif typeof(v) == "ColorSequenceKeypoint" then
				table.insert(result, `ColorSequenceKeypoint.new({v.Time}, Color3.new({(v.Value)}))`)
			elseif typeof(v) == "Instance" then
				table.insert(result, instancetoPath(v))
			else
				table.insert(result, `{tostring(v)}`)
			end
		end
		return table.concat(result, ", ")
	end
	
	function createRemote(Args: {any}, Remote: BaseRemoteEvent, Method: string)
		local cloned = template:Clone()
		cloned.Visible = true
		cloned.Args.Value = game:GetService("HttpService"):JSONEncode(formatArgs(Args))
		cloned.Remote.Value = Remote
		cloned.Text = Remote.Name
		
		cloned.MouseButton1Click:Connect(function()
			Code.Text = `{instancetoPath(cloned.Remote.Value)}:{Method}({cloned.Args.Value})`
		end)
	end
	
	local mt = getrawmetatable(game)
	local old = mt.__namecall 
	
	setreadonly(mt, false) 
	
	mt.__namecall = newcclosure(function(self, ...)
		local args = {...}
		local method = getnamecallmethod()
		if method == 'FireServer' or method == 'InvokeServer' or method == 'Fire' or method == 'Invoke' then
			createRemote(args, self, method)
		end 
		return old(self, ...)
	end)
end
coroutine.wrap(QOPCGW_fake_script)()
