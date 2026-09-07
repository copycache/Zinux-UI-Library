local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}

local Themes = {
	DarkTheme = {
		Background = Color3.fromRGB(24, 25, 32),
		Sidebar = Color3.fromRGB(20, 21, 27),
		Topbar = Color3.fromRGB(25, 26, 33),

		Card = Color3.fromRGB(29, 30, 38),
		CardHover = Color3.fromRGB(34, 35, 44),

		Border = Color3.fromRGB(42, 43, 52),

		Text = Color3.fromRGB(235, 235, 240),
		SubText = Color3.fromRGB(145, 146, 157),

		Accent = Color3.fromRGB(120, 137, 255),
		AccentDark = Color3.fromRGB(91, 105, 210),

		ToggleOff = Color3.fromRGB(48, 49, 58),
		ToggleKnob = Color3.fromRGB(18, 19, 24),

		Input = Color3.fromRGB(32, 33, 41),
	},

	LightTheme = {
		Background = Color3.fromRGB(242, 243, 247),
		Sidebar = Color3.fromRGB(235, 236, 241),
		Topbar = Color3.fromRGB(248, 248, 250),

		Card = Color3.fromRGB(255, 255, 255),
		CardHover = Color3.fromRGB(244, 245, 249),

		Border = Color3.fromRGB(220, 221, 228),

		Text = Color3.fromRGB(35, 36, 42),
		SubText = Color3.fromRGB(105, 106, 116),

		Accent = Color3.fromRGB(105, 122, 235),
		AccentDark = Color3.fromRGB(83, 99, 205),

		ToggleOff = Color3.fromRGB(205, 206, 214),
		ToggleKnob = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(240, 241, 245),
	}
}

--==================================================
-- UTILITIES
--==================================================

local function Create(className, properties)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	return object
end

local function Corner(parent, radius)
	local corner = Instance.new("UICorner")
    corner.Parent = parent
	corner.CornerRadius = UDim.new(0, radius or 8)
	return corner
end

local function Stroke(parent, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Thickness = 1
	stroke.Parent = parent
	return stroke
end

local function Padding(parent, left, right, top, bottom)
	local padding = Instance.new("UIPadding")

	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)

	padding.Parent = parent

	return padding
end

local function Tween(object, properties, duration)
	return TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.15,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		properties
	)
end

--==================================================
-- CREATE LIBRARY
--==================================================

function Library.CreateLib(title, themeName)

	local Theme = Themes[themeName] or Themes.DarkTheme

	local Window = {}

	Window.Title = title
	Window.Theme = Theme
	Window.Tabs = {}

	--==================================================
	-- GUI
	--==================================================

	local ScreenGui = Create("ScreenGui", {
		Name = "Zinux",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	-- Prevent duplicates
	local old = game:GetService("CoreGui"):FindFirstChild("Zinux")

	if old then
		old:Destroy()
	end

	ScreenGui.Parent = game:GetService("CoreGui")

	--==================================================
	-- MAIN WINDOW
	--==================================================

	local Main = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,

		Size = UDim2.fromOffset(730, 500),
		Position = UDim2.new(
			0.5,
			-365,
			0.5,
			-250
		),

		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,

		ClipsDescendants = true
	})

	Corner(Main, 16)
	Stroke(Main, Theme.Border)

	Window.Main = Main

	--==================================================
	-- TOP BAR
	--==================================================

	local Topbar = Create("Frame", {
		Name = "Topbar",
		Parent = Main,

		Size = UDim2.new(1, 0, 0, 45),

		BackgroundColor3 = Theme.Topbar,
		BorderSizePixel = 0
	})

	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Topbar,

		Position = UDim2.fromOffset(1, 0),
		Size = UDim2.fromOffset(400, 23),

		BackgroundTransparency = 1,

		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left
	})
    
	-- Close
	local Close = Create("TextButton", {
		Parent = Topbar,

		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),

		Size = UDim2.fromOffset(28, 28),

		BackgroundTransparency = 1,

		Text = "×",
		TextColor3 = Theme.SubText,
		TextSize = 20,
		Font = Enum.Font.GothamMedium
	})

	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- Minimize

	local Minimize = Create("TextButton", {
		Parent = Topbar,

		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -48, 0.5, 0),

		Size = UDim2.fromOffset(28, 28),

		BackgroundTransparency = 1,

		Text = "−",
		TextColor3 = Theme.SubText,
		TextSize = 18,
		Font = Enum.Font.GothamMedium
	})

	local minimized = false

	Minimize.MouseButton1Click:Connect(function()
		minimized = not minimized

		if minimized then
			Main.Size = UDim2.fromOffset(730, 45)
		else
			Main.Size = UDim2.fromOffset(730, 500)
		end
	end)

	--==================================================
	-- DRAGGING
	--==================================================

	local dragging = false
	local dragStart
	local startPosition

	Topbar.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = Main.Position

			input.Changed:Connect(function()

				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end

			end)

		end

	end)

	UserInputService.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

	end)

	--==================================================
	-- SIDEBAR
	--==================================================

	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = Main,

		Position = UDim2.fromOffset(0, 45),
		Size = UDim2.new(0, 140, 1, -45),

		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0
	})

	Window.Sidebar = Sidebar

	local TabList = Create("ScrollingFrame", {
		Name = "TabList",
		Parent = Sidebar,

		Position = UDim2.fromOffset(8, 10),
		Size = UDim2.new(1, -16, 1, -20),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 0,

		CanvasSize = UDim2.new()
	})

	local TabLayout = Create("UIListLayout", {
		Parent = TabList,

		SortOrder = Enum.SortOrder.LayoutOrder,

		Padding = UDim.new(0, 4)
	})

	--==================================================
	-- CONTENT
	--==================================================

	local Content = Create("Frame", {
		Name = "Content",
		Parent = Main,

		Position = UDim2.fromOffset(140, 45),
		Size = UDim2.new(1, -140, 1, -45),

		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0
	})

	Window.Content = Content

	--==================================================
	-- TAB
	--==================================================

	function Window:CreateTab(tabName, icon)

		local Tab = {}

		Tab.Name = tabName
		Tab.Sections = {}

		-- Sidebar button

		local TabButton = Create("TextButton", {
			Name = tabName,
			Parent = TabList,

			Size = UDim2.new(1, 0, 0, 28),

			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			Text = ""
		})

		Corner(TabButton, 8)
        Stroke(TabButton, Theme.Border)

		local Icon = Create("TextLabel", {
			Parent = TabButton,

			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.fromOffset(22, 28),

			BackgroundTransparency = 1,

			Text = icon or "•",
			TextColor3 = Theme.SubText,
			TextSize = 15,
			Font = Enum.Font.GothamBold
		})

		local TabText = Create("TextLabel", {
			Parent = TabButton,

			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -40, 1, 0),

			BackgroundTransparency = 1,

			Text = tabName,
			TextColor3 = Theme.SubText,
			TextSize = 11,
			Font = Enum.Font.GothamMedium,

			TextXAlignment = Enum.TextXAlignment.Left
		})

		-- Tab page

		local Page = Create("ScrollingFrame", {
			Name = tabName .. "Page",
			Parent = Content,

			Size = UDim2.new(1, 0, 1, 0),

			BackgroundTransparency = 1,

			BorderSizePixel = 0,

			ScrollBarThickness = 3,

			ScrollBarImageColor3 = Theme.Accent,

			Visible = false,

			CanvasSize = UDim2.new()
		})

		Padding(Page, 16, 16, 16, 16)

		local PageLayout = Create("UIListLayout", {
			Parent = Page,

			SortOrder = Enum.SortOrder.LayoutOrder,

			Padding = UDim.new(0, 12)
		})

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

			Page.CanvasSize = UDim2.new(
				0,
				0,
				0,
				PageLayout.AbsoluteContentSize.Y + 25
			)

		end)

		Tab.Page = Page
		Tab.Button = TabButton

		-- Select

		function Tab:Select()

			for _, otherTab in pairs(Window.Tabs) do

				otherTab.Page.Visible = false

				Tween(otherTab.Button, {
					BackgroundTransparency = 1
				}):Play()

				for _, child in pairs(otherTab.Button:GetChildren()) do
					if child:IsA("TextLabel") then
						child.TextColor3 = Theme.SubText
					end
				end

			end

			Page.Visible = true

			Tween(TabButton, {
				BackgroundTransparency = 0
			}):Play()

			Icon.TextColor3 = Theme.Text
			TabText.TextColor3 = Theme.Text

		end

		TabButton.MouseButton1Click:Connect(function()
			Tab:Select()
		end)

		--==================================================
		-- SECTION
		--==================================================

		function Tab:CreateSection(sectionName)

			local Section = {}

			local Frame = Create("Frame", {
				Name = sectionName,
				Parent = Page,

				Size = UDim2.new(1, 0, 0, 50),

				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,

				AutomaticSize = Enum.AutomaticSize.Y
			})

			Corner(Frame, 10)
			Stroke(Frame, Theme.Border)

			Padding(Frame, 12, 12, 10, 12)

			local SectionTitle = Create("TextLabel", {
				Parent = Frame,

				Size = UDim2.new(1, 0, 0, 22),

				BackgroundTransparency = 1,

				Text = sectionName,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamBold,

				TextXAlignment = Enum.TextXAlignment.Left
			})

			local Elements = Create("Frame", {
				Parent = Frame,

				Position = UDim2.fromOffset(0, 28),
				Size = UDim2.new(1, 0, 0, 0),

				BackgroundTransparency = 1,

				AutomaticSize = Enum.AutomaticSize.Y
			})

			local ElementLayout = Create("UIListLayout", {
				Parent = Elements,

				Padding = UDim.new(0, 8),

				SortOrder = Enum.SortOrder.LayoutOrder
			})

			--==================================================
			-- LABEL
			--==================================================

			function Section:CreateLabel(text)

				local Label = Create("TextLabel", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 22),

					BackgroundTransparency = 1,

					Text = text,
					TextColor3 = Theme.SubText,
					TextSize = 11,
					Font = Enum.Font.Gotham,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				return Label

			end

			--==================================================
			-- BUTTON
			--==================================================

			function Section:CreateButton(text, callback)

				local Button = Create("TextButton", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 36),

					BackgroundColor3 = Theme.Input,

					BorderSizePixel = 0,

					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamMedium
				})

				Corner(Button, 7)

				Button.MouseEnter:Connect(function()

					Tween(Button, {
						BackgroundColor3 = Theme.CardHover
					}):Play()

				end)

				Button.MouseLeave:Connect(function()

					Tween(Button, {
						BackgroundColor3 = Theme.Input
					}):Play()

				end)

				Button.MouseButton1Click:Connect(function()

					if callback then
						task.spawn(callback)
					end

				end)

				return Button

			end

			--==================================================
			-- TOGGLE
			--==================================================

			function Section:CreateToggle(text, default, callback)

				local enabled = default or false

				local Holder = Create("Frame", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 42),

					BackgroundTransparency = 1
				})

				local Label = Create("TextLabel", {
					Parent = Holder,

					Position = UDim2.fromOffset(0, 2),
					Size = UDim2.new(1, -65, 0, 20),

					BackgroundTransparency = 1,

					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamMedium,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Toggle = Create("TextButton", {
					Parent = Holder,

					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),

					Size = UDim2.fromOffset(34, 18),

					BackgroundColor3 = enabled
						and Theme.Accent
						or Theme.ToggleOff,

					BorderSizePixel = 0,

					Text = ""
				})

				Corner(Toggle, 20)

				local Knob = Create("Frame", {
					Parent = Toggle,

					AnchorPoint = Vector2.new(0, 0.5),

					Position = enabled
						and UDim2.new(1, -16, 0.5, 0)
						or UDim2.new(0, 2, 0.5, 0),

					Size = UDim2.fromOffset(14, 14),

					BackgroundColor3 = Theme.ToggleKnob,
					BorderSizePixel = 0
				})

				Corner(Knob, 20)

				local function Update()

					Tween(Toggle, {
						BackgroundColor3 = enabled
							and Theme.Accent
							or Theme.ToggleOff
					}):Play()

					Tween(Knob, {
						Position = enabled
							and UDim2.new(1, -16, 0.5, 0)
							or UDim2.new(0, 2, 0.5, 0)
					}):Play()

					if callback then
						task.spawn(callback, enabled)
					end

				end

				Toggle.MouseButton1Click:Connect(function()

					enabled = not enabled

					Update()

				end)

				return {

					SetValue = function(_, value)

						enabled = value
						Update()

					end,

					GetValue = function()
						return enabled
					end

				}

			end

			--==================================================
			-- SLIDER
			--==================================================

			function Section:CreateSlider(text, min, max, default, callback)

				min = min or 0
				max = max or 100
				default = default or min

				local value = default

				local Holder = Create("Frame", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 58),

					BackgroundTransparency = 1
				})

				local Label = Create("TextLabel", {
					Parent = Holder,

					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.new(1, -50, 0, 20),

					BackgroundTransparency = 1,

					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamMedium,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				local ValueLabel = Create("TextLabel", {
					Parent = Holder,

					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),

					Size = UDim2.fromOffset(45, 20),

					BackgroundColor3 = Theme.Input,

					Text = tostring(value),
					TextColor3 = Theme.SubText,
					TextSize = 10,
					Font = Enum.Font.GothamMedium
				})

				Corner(ValueLabel, 5)

				local Bar = Create("Frame", {
					Parent = Holder,

					Position = UDim2.fromOffset(0, 34),
					Size = UDim2.new(1, 0, 0, 4),

					BackgroundColor3 = Theme.ToggleOff,
					BorderSizePixel = 0
				})

				Corner(Bar, 5)

				local Fill = Create("Frame", {
					Parent = Bar,

					Size = UDim2.new(
						(value - min) / (max - min),
						0,
						1,
						0
					),

					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0
				})

				Corner(Fill, 5)

				local Knob = Create("Frame", {
					Parent = Bar,

					AnchorPoint = Vector2.new(0.5, 0.5),

					Position = UDim2.new(
						(value - min) / (max - min),
						0,
						0.5,
						0
					),

					Size = UDim2.fromOffset(10, 10),

					BackgroundColor3 = Theme.Text,
					BorderSizePixel = 0
				})

				Corner(Knob, 10)

				local draggingSlider = false

				local function SetValue(newValue)

					value = math.clamp(newValue, min, max)

					local percent = (value - min) / (max - min)

					Fill.Size = UDim2.new(percent, 0, 1, 0)

					Knob.Position = UDim2.new(
						percent,
						0,
						0.5,
						0
					)

					ValueLabel.Text = tostring(
						math.floor(value * 100) / 100
					)

					if callback then
						task.spawn(callback, value)
					end

				end

				local function UpdateFromMouse(mouseX)

					local startX = Bar.AbsolutePosition.X
					local width = Bar.AbsoluteSize.X

					local percent = math.clamp(
						(mouseX - startX) / width,
						0,
						1
					)

					SetValue(
						min + ((max - min) * percent)
					)

				end

				Bar.InputBegan:Connect(function(input)

					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then

						draggingSlider = true

						UpdateFromMouse(input.Position.X)

					end

				end)

				UserInputService.InputChanged:Connect(function(input)

					if not draggingSlider then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch then

						UpdateFromMouse(input.Position.X)

					end

				end)

				UserInputService.InputEnded:Connect(function(input)

					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then

						draggingSlider = false

					end

				end)

				return {

					SetValue = function(_, newValue)
						SetValue(newValue)
					end,

					GetValue = function()
						return value
					end

				}

			end

			--==================================================
			-- TEXTBOX
			--==================================================

			function Section:CreateTextbox(text, placeholder, callback)

				local Holder = Create("Frame", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 62),

					BackgroundTransparency = 1
				})

				local Label = Create("TextLabel", {
					Parent = Holder,

					Size = UDim2.new(1, 0, 0, 20),

					BackgroundTransparency = 1,

					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamMedium,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Box = Create("TextBox", {
					Parent = Holder,

					Position = UDim2.fromOffset(0, 26),
					Size = UDim2.new(1, 0, 0, 34),

					BackgroundColor3 = Theme.Input,

					BorderSizePixel = 0,

					Text = "",
					PlaceholderText = placeholder or "",
					PlaceholderColor3 = Theme.SubText,

					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.Gotham,

					ClearTextOnFocus = false,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				Corner(Box, 7)
				Padding(Box, 10, 10, 0, 0)

				Box.FocusLost:Connect(function()

					if callback then
						task.spawn(callback, Box.Text)
					end

				end)

				return Box

			end

			--==================================================
			-- DROPDOWN
			--==================================================

			function Section:CreateDropdown(text, options, callback)

				options = options or {}

				local selected = options[1]

				local Holder = Create("Frame", {
					Parent = Elements,

					Size = UDim2.new(1, 0, 0, 48),

					BackgroundTransparency = 1
				})

				local Label = Create("TextLabel", {
					Parent = Holder,

					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.new(0.45, 0, 1, 0),

					BackgroundTransparency = 1,

					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamMedium,

					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Drop = Create("TextButton", {
					Parent = Holder,

					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),

					Size = UDim2.fromOffset(150, 34),

					BackgroundColor3 = Theme.Input,

					Text = selected or "Select",
					TextColor3 = Theme.Text,
					TextSize = 10,
					Font = Enum.Font.GothamMedium,

					BorderSizePixel = 0
				})

				Corner(Drop, 7)

				local Open = false

				local Menu = Create("Frame", {
					Parent = Drop,

					Position = UDim2.new(0, 0, 1, 5),

					Size = UDim2.new(1, 0, 0, 0),

					BackgroundColor3 = Theme.Card,

					BorderSizePixel = 0,

					Visible = false,

					ZIndex = 20
				})

				Corner(Menu, 7)
				Stroke(Menu, Theme.Border)

				local Layout = Create("UIListLayout", {
					Parent = Menu,

					Padding = UDim.new(0, 2)
				})

				for _, option in ipairs(options) do

					local Option = Create("TextButton", {
						Parent = Menu,

						Size = UDim2.new(1, 0, 0, 30),

						BackgroundTransparency = 1,

						Text = tostring(option),
						TextColor3 = Theme.Text,
						TextSize = 10,
						Font = Enum.Font.Gotham,

						ZIndex = 21
					})

					Option.MouseButton1Click:Connect(function()

						selected = option

						Drop.Text = tostring(option)

						Open = false
						Menu.Visible = false

						if callback then
							task.spawn(callback, option)
						end

					end)

				end

				Drop.MouseButton1Click:Connect(function()

					Open = not Open

					Menu.Visible = Open

					Menu.Size = UDim2.new(
						1,
						0,
						0,
						#options * 30 + 4
					)

				end)

				return {

					SetValue = function(_, value)

						selected = value
						Drop.Text = tostring(value)

					end,

					GetValue = function()
						return selected
					end

				}

			end

			table.insert(Tab.Sections, Section)

			return Section

		end

		table.insert(Window.Tabs, Tab)

		-- First tab automatically selected

		if #Window.Tabs == 1 then
			Tab:Select()
		end

		return Tab

	end

	--==================================================
	-- DESTROY
	--==================================================

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	return Window
end

return Library