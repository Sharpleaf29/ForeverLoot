local AddonName, ForeverLoot = ...;

local FRAME_WIDTH = 820;
local FRAME_HEIGHT = 560;
local NAME_WIDTH = 168;
local ICON_SIZE = 28;
local ICON_GAP = 4;
local CONTENT_WIDTH = FRAME_WIDTH - 48;

local GOLD_R, GOLD_G, GOLD_B = 1, 0.82, 0;

local BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
};

local CONTROL_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
};

local INSET_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 14,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
};

local TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil;
local db;
local frame;
local rows = {};
local openMenu;
local suppressSlider = false;

local function Paint(texture, r, g, b, a)
	if (texture.SetColorTexture) then
		texture:SetColorTexture(r, g, b, a or 1);
	else
		texture:SetTexture("Interface\\Buttons\\WHITE8X8");
		texture:SetVertexColor(r, g, b, a or 1);
	end
end

local function ApplyBackdrop(target, backdrop)
	if (target.SetBackdrop) then
		target:SetBackdrop(backdrop);
	end
end

local function StyleDark(target, backdrop)
	ApplyBackdrop(target, backdrop or CONTROL_BACKDROP);
	if (target.SetBackdropColor) then
		target:SetBackdropColor(0.08, 0.07, 0.05, 0.95);
		target:SetBackdropBorderColor(1, 1, 1, 1);
	end
end

local dropdownCount = 0;

local function DropdownFontString(dropdown)
	return dropdown.Text or _G[dropdown:GetName() .. "Text"];
end

local function SetDropdownText(dropdown, text)
	if (UIDropDownMenu_SetText) then
		pcall(UIDropDownMenu_SetText, dropdown, text);
	end

	local fontString = DropdownFontString(dropdown);
	if (fontString) then
		fontString:SetText(text);
	end
end

local function SetDropdownWidth(dropdown, width)
	local middle = dropdown.Middle or _G[dropdown:GetName() .. "Middle"];
	if (middle) then
		middle:SetWidth(width);
	end

	dropdown:SetWidth((width or 80) + 25);
end

local function CloseMenu()
	if (CloseDropDownMenus) then
		CloseDropDownMenus();
	end
end

local function CreateDropdown(parent, width)
	dropdownCount = dropdownCount + 1;

	local dropdown = CreateFrame("Frame", "ForeverLootDropDown" .. dropdownCount, parent, "UIDropDownMenuTemplate");
	SetDropdownWidth(dropdown, width);
	dropdown.choices = {};

	local fontString = DropdownFontString(dropdown);
	if (fontString) then
		fontString:ClearAllPoints();
		fontString:SetPoint("LEFT", dropdown, "LEFT", 30, 2);
		fontString:SetPoint("RIGHT", dropdown, "RIGHT", -28, 2);
		fontString:SetJustifyH("LEFT");
		fontString:SetWordWrap(false);
	end

	UIDropDownMenu_Initialize(dropdown, function(self)
		for _, choice in ipairs(self.choices or {}) do
			local choiceId = choice.id;
			local choiceLabel = choice.label;
			local info = UIDropDownMenu_CreateInfo();
			info.text = choiceLabel;
			info.checked = (self.selected == choiceId);
			info.arg1 = choiceId;
			info.arg2 = choiceLabel;
			info.func = function(_, id, label)
				self.selected = id;
				SetDropdownText(self, label);
				CloseMenu();
				if (self.onChanged) then
					self.onChanged(id);
				end
			end;
			UIDropDownMenu_AddButton(info);
		end
	end);

	function dropdown:SetChoices(choices, selected)
		self.choices = choices;
		self.selected = selected;

		local text = "";
		for _, choice in ipairs(choices) do
			if (choice.id == selected) then
				text = choice.label;
				break;
			end
		end

		SetDropdownText(self, text);
	end

	return dropdown;
end

local function AcquireIcon(row, index)
	local button = row.icons[index];
	if (button) then
		return button;
	end

	button = CreateFrame("Button", nil, row);
	button:SetSize(ICON_SIZE, ICON_SIZE);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	button.border = button:CreateTexture(nil, "BACKGROUND");
	button.border:SetAllPoints();
	Paint(button.border, 0.4, 0.4, 0.4, 1);

	button.icon = button:CreateTexture(nil, "ARTWORK");
	button.icon:SetPoint("TOPLEFT", 1, -1);
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1);

	button.star = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	button.star:SetPoint("TOPRIGHT", 4, 4);
	button.star:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE");
	button.star:SetText("*");
	button.star:SetTextColor(1, 0.86, 0);

	button.equipped = button:CreateTexture(nil, "OVERLAY");
	button.equipped:SetSize(16, 16);
	button.equipped:SetPoint("BOTTOMRIGHT", 4, -4);
	button.equipped:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");

	button:SetScript("OnClick", function(self, mouseButton)
		if (mouseButton == "RightButton") then
			ForeverLoot:ToggleFavorite(self.itemId);
			ForeverLoot:Refresh();
			return;
		end

		local _, link = ForeverLoot:GetItemName(self.itemId);
		link = link or ("item:" .. self.itemId);
		if (IsModifiedClick("CHATLINK") and ChatEdit_InsertLink) then
			ChatEdit_InsertLink(link);
		elseif (IsModifiedClick("DRESSUP") and DressUpItemLink) then
			DressUpItemLink(link);
		end
	end);

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local shown = false;
		if (GameTooltip.SetItemByID) then
			shown = pcall(GameTooltip.SetItemByID, GameTooltip, self.itemId);
		end
		if (not shown) then
			GameTooltip:SetHyperlink("item:" .. self.itemId);
		end
		if (ForeverLoot:IsEquipped(self.itemId)) then
			GameTooltip:AddLine("Equipped", 0.1, 1, 0.1);
		end
		if (ForeverLoot:IsFavorite(self.itemId)) then
			GameTooltip:AddLine("Favorited", 1, 0.82, 0);
		end
		GameTooltip:AddLine("Right-click to favorite", 0.75, 0.75, 0.75);
		GameTooltip:Show();
	end);

	button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	row.icons[index] = button;
	return button;
end

local function AcquireRow(index)
	local row = rows[index];
	if (row) then
		return row;
	end

	row = CreateFrame("Frame", nil, frame.scrollChild);
	row:SetWidth(CONTENT_WIDTH);
	row.bg = row:CreateTexture(nil, "BACKGROUND");
	row.bg:SetAllPoints();
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	row.name:SetPoint("TOPLEFT", 8, -6);
	row.name:SetWidth(NAME_WIDTH - 16);
	row.name:SetJustifyH("LEFT");
	row.name:SetWordWrap(false);
	row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
	row.sub:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2);
	row.sub:SetWidth(NAME_WIDTH - 16);
	row.sub:SetJustifyH("LEFT");
	row.icons = {};
	rows[index] = row;
	return row;
end

local flatCache = {};

local function FlattenItems(bosses)
	local cached = flatCache[bosses];
	if (cached) then
		return cached;
	end

	local items = {};
	local seen = {};
	for _, boss in ipairs(bosses) do
		for _, itemId in ipairs(boss.items) do
			if (not seen[itemId]) then
				seen[itemId] = true;
				table.insert(items, itemId);
			end
		end
	end
	flatCache[bosses] = items;
	return items;
end

local function PlaceItems(row, itemIds)
	local perLine = math.max(1, math.floor((CONTENT_WIDTH - NAME_WIDTH) / (ICON_SIZE + ICON_GAP)));
	local shown = 0;

	for _, itemId in ipairs(itemIds) do
		if (ForeverLoot:ItemPasses(itemId)) then
			shown = shown + 1;
			local button = AcquireIcon(row, shown);
			button.itemId = itemId;
			ForeverLoot:RequestItem(itemId);

			local info = ForeverLoot:GetItemInstant(itemId);
			button.icon:SetTexture((info and info.icon) or 134400);

			local _, _, quality = ForeverLoot:GetItemName(itemId);
			local r, g, b = ForeverLoot:QualityColor(quality);
			Paint(button.border, r, g, b, 1);
			button.star:SetShown(ForeverLoot:IsFavorite(itemId));
			button.equipped:SetShown(ForeverLoot:IsEquipped(itemId));

			local column = (shown - 1) % perLine;
			local line = math.floor((shown - 1) / perLine);
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", NAME_WIDTH + (column * (ICON_SIZE + ICON_GAP)), -8 - (line * (ICON_SIZE + ICON_GAP)));
			button:Show();
		end
	end

	for index = shown + 1, #row.icons do
		row.icons[index]:Hide();
	end

	local lines = math.max(1, math.ceil(shown / perLine));
	local height = math.max(40, 8 + (lines * (ICON_SIZE + ICON_GAP)) + 6);
	return height, shown;
end

local function ClassChoices()
	local choices = {};
	for _, classFile in ipairs(ForeverLoot.CLASSES) do
		table.insert(choices, { id = classFile, label = ForeverLoot:ClassName(classFile) });
	end
	return choices;
end

local function SpecChoices(classFile)
	local choices = { { id = 0, label = "All" } };
	local specs = ForeverLoot.SPECS[classFile] or {};
	for index, spec in ipairs(specs) do
		table.insert(choices, { id = index, label = spec.name });
	end
	return choices;
end

local function SlotChoices()
	local choices = {};
	for _, slot in ipairs(ForeverLoot.SLOTS) do
		table.insert(choices, { id = slot.id, label = slot.label });
	end
	return choices;
end

local function RaidChoices()
	local choices = {};
	for _, raid in ipairs(ForeverLoot.Raids or {}) do
		table.insert(choices, { id = raid.id, label = raid.name });
	end
	return choices;
end

local function FindRaid(raidId)
	for _, raid in ipairs(ForeverLoot.Raids or {}) do
		if (raid.id == raidId) then
			return raid;
		end
	end
	return (ForeverLoot.Raids or {})[1];
end

local function ColorClassLabel()
	local fontString = DropdownFontString(frame.classDropdown);
	if (not fontString) then
		return;
	end

	local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[db.class];
	if (color) then
		fontString:SetTextColor(color.r, color.g, color.b);
	else
		fontString:SetTextColor(1, 1, 1);
	end
end

local function UpdateScrollRange(contentHeight)
	local viewHeight = frame.scroll:GetHeight();
	if (viewHeight < 1) then
		viewHeight = 380;
	end

	local maxScroll = math.max(0, contentHeight - viewHeight);
	suppressSlider = true;
	frame.slider:SetMinMaxValues(0, maxScroll);
	if (frame.slider:GetValue() > maxScroll) then
		frame.slider:SetValue(maxScroll);
	end
	frame.scroll:SetVerticalScroll(frame.slider:GetValue());
	suppressSlider = false;
	frame.slider:SetShown(maxScroll > 1);
end

function ForeverLoot:Refresh()
	if (not frame) then
		return;
	end

	self:RebuildEquipped();

	if (frame.UpdateArmorDropdown) then
		frame:UpdateArmorDropdown();
	end

	db = self:GetDB();
	local entries = {};

	if (db.tab == "raids") then
		local raid = FindRaid(db.raid);
		if (raid) then
			db.raid = raid.id;
			for _, boss in ipairs(raid.bosses) do
				table.insert(entries, {
					name = boss.name,
					sub = nil,
					items = boss.items,
				});
			end
		end
	else
		local bracket = self:BracketById(db.bracket);
		for _, dungeon in ipairs(self.Dungeons or {}) do
			if (self:DungeonInBracket(dungeon, bracket)) then
				local minLevel, maxLevel = self:DungeonLevels(dungeon);
				local sub = "Level ?";
				if (minLevel and maxLevel) then
					sub = string.format("Level %d-%d", minLevel, maxLevel);
				end
				table.insert(entries, {
					name = dungeon.name,
					sub = sub,
					items = FlattenItems(dungeon.bosses),
				});
			end
		end
	end

	local y = 0;
	for index, entry in ipairs(entries) do
		local row = AcquireRow(index);
		row:ClearAllPoints();
		row:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 0, -y);
		row.name:SetText(entry.name);
		Paint(row.bg, 1, 0.82, 0, index % 2 == 0 and 0.03 or 0.07);

		local height, shown = PlaceItems(row, entry.items);
		if (shown == 0) then
			row.name:SetTextColor(0.55, 0.55, 0.55);
			local emptyText = (#entry.items == 0) and "no loot listed" or "nothing for this filter";
			row.sub:SetText(entry.sub and (entry.sub .. "  ·  " .. emptyText) or emptyText);
		else
			row.name:SetTextColor(GOLD_R, GOLD_G, GOLD_B);
			if (entry.sub) then
				row.sub:SetText(string.format("%s  ·  %d", entry.sub, shown));
			else
				row.sub:SetText(shown .. (shown == 1 and " item" or " items"));
			end
		end

		row:SetHeight(height);
		row:Show();
		y = y + height;
	end

	for index = #entries + 1, #rows do
		rows[index]:Hide();
	end

	if (#entries == 0) then
		frame.empty:SetText("Nothing to show for this filter.");
		frame.empty:Show();
		y = 40;
	else
		frame.empty:Hide();
	end

	frame.scrollChild:SetSize(CONTENT_WIDTH, math.max(y, 1));
	UpdateScrollRange(y);

	frame.favoritesButton:SetText(db.favoritesOnly and "|cffffd100Favorites|r" or "Favorites");
	frame.showAllCheck:SetChecked(db.showAll);
	ColorClassLabel();
end

local function SetTab(tab)
	db.tab = tab;
	CloseMenu();
	local dungeonsOn = tab == "dungeons";
	local function TintTab(tab, selected)
		local fontString = tab:GetFontString();
		if (fontString) then
			fontString:SetTextColor(selected and GOLD_R or 0.7, selected and GOLD_G or 0.7, selected and GOLD_B or 0.7);
		end
	end
	TintTab(frame.tabDungeons, dungeonsOn);
	TintTab(frame.tabRaids, not dungeonsOn);
	frame.levelDropdown:SetShown(dungeonsOn);
	frame.raidDropdown:SetShown(not dungeonsOn);
	frame.slider:SetValue(0);
	ForeverLoot:Refresh();
end

local function BuildFrame()
	db = ForeverLoot:GetDB();

	frame = CreateFrame("Frame", "ForeverLootFrame", UIParent, TEMPLATE);
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT);
	frame:SetFrameStrata("HIGH");
	frame:SetToplevel(true);
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:SetClampedToScreen(true);
	frame:Hide();
	StyleDark(frame, BACKDROP);

	if (type(db.point) == "table") then
		frame:ClearAllPoints();
		frame:SetPoint(db.point[1], UIParent, db.point[2], db.point[3], db.point[4]);
	else
		frame:SetPoint("CENTER");
	end

	tinsert(UISpecialFrames, "ForeverLootFrame");

	local drag = CreateFrame("Frame", nil, frame);
	drag:SetPoint("TOPLEFT", 12, -8);
	drag:SetPoint("TOPRIGHT", -58, -8);
	drag:SetHeight(24);
	drag:EnableMouse(true);
	drag:RegisterForDrag("LeftButton");
	drag:SetScript("OnDragStart", function()
		CloseMenu();
		frame:StartMoving();
	end);
	drag:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing();
		local point, _, relativePoint, x, y = frame:GetPoint(1);
		db.point = { point, relativePoint, x, y };
	end);

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	title:SetPoint("TOP", 0, -14);
	title:SetText("ForeverLoot");

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
	close:SetPoint("TOPRIGHT", 4, 4);
	close:SetScript("OnClick", function()
		frame:Hide();
	end);

	local minimapButton = CreateFrame("Button", "ForeverLootMinimapButton", Minimap);
	minimapButton:SetSize(31, 31);
	minimapButton:SetFrameStrata("MEDIUM");
	minimapButton:SetFrameLevel(8);
	minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	minimapButton:RegisterForDrag("LeftButton");
	minimapButton:SetHighlightTexture(136477);

	local border = minimapButton:CreateTexture(nil, "OVERLAY");
	border:SetSize(53, 53);
	border:SetTexture(136430);
	border:SetPoint("TOPLEFT");

	local icon = minimapButton:CreateTexture(nil, "ARTWORK");
	icon:SetSize(22, 22);
	icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_10");
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
	icon:SetPoint("CENTER", 0, 1);
	if (minimapButton.CreateMaskTexture) then
		local mask = minimapButton:CreateMaskTexture();
		mask:SetAllPoints(icon);
		mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		icon:AddMaskTexture(mask);
	end

	local function UpdateMinimapButton()
		local angle = math.rad(db.minimapAngle or 225);
		local radius = (Minimap:GetWidth() / 2) + 5;
		minimapButton:ClearAllPoints();
		minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius);
		minimapButton:SetShown(db.minimap ~= false);
	end

	minimapButton:SetScript("OnClick", function()
		frame:SetShown(not frame:IsShown());
	end);
	minimapButton:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", function()
			local mx, my = Minimap:GetCenter();
			local scale = Minimap:GetEffectiveScale();
			local cx, cy = GetCursorPosition();
			cx, cy = cx / scale, cy / scale;
			db.minimapAngle = math.deg(math.atan2(cy - my, cx - mx)) % 360;
			UpdateMinimapButton();
		end);
	end);
	minimapButton:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil);
	end);
	minimapButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:AddLine("ForeverLoot", 1, 0.82, 0);
		GameTooltip:AddLine("Left-click to toggle. Drag to move.", 1, 1, 1);
		GameTooltip:Show();
	end);
	minimapButton:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
	UpdateMinimapButton();

	local settingsMenu = CreateFrame("Frame", "ForeverLootSettingsMenu", frame, "UIDropDownMenuTemplate");
	settingsMenu:Hide();
	UIDropDownMenu_Initialize(settingsMenu, function()
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Minimap button";
		info.isNotRadio = true;
		info.checked = db.minimap ~= false;
		info.func = function()
			db.minimap = db.minimap == false;
			UpdateMinimapButton();
		end;
		UIDropDownMenu_AddButton(info);
	end, "MENU");

	local cog = CreateFrame("Button", nil, frame);
	cog:SetSize(24, 24);
	cog:SetPoint("TOPRIGHT", -28, -28);
	cog:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton");
	cog:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD");
	cog:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, settingsMenu, self, 0, 0);
	end);
	cog:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine("Settings", 1, 0.82, 0);
		GameTooltip:Show();
	end);
	cog:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	local function MakeTab(text, x)
		local tab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate");
		tab:SetSize(100, 22);
		tab:SetPoint("TOPLEFT", x, -38);
		tab:SetText(text);
		return tab;
	end

	frame.tabDungeons = MakeTab("Dungeons", 16);
	frame.tabRaids = MakeTab("Raids", 124);
	frame.tabDungeons:SetScript("OnClick", function()
		SetTab("dungeons");
	end);
	frame.tabRaids:SetScript("OnClick", function()
		SetTab("raids");
	end);

	frame.classDropdown = CreateDropdown(frame, 100);
	frame.classDropdown:SetPoint("TOPLEFT", 4, -64);
	frame.classDropdown:SetChoices(ClassChoices(), db.class);
	frame.classDropdown.onChanged = function(classFile)
		db.class = classFile;
		db.spec = 0;
		db.armorType = "all";
		frame.specDropdown:SetChoices(SpecChoices(classFile), 0);
		ColorClassLabel();
		frame:UpdateArmorDropdown();
		ForeverLoot:Refresh();
	end

	frame.specDropdown = CreateDropdown(frame, 110);
	frame.specDropdown:SetPoint("LEFT", frame.classDropdown, "RIGHT", -8, 0);
	frame.specDropdown:SetChoices(SpecChoices(db.class), db.spec or 0);
	frame.specDropdown.onChanged = function(specIndex)
		db.spec = specIndex;
		db.armorType = "all";
		frame:UpdateArmorDropdown();
		ForeverLoot:Refresh();
	end

	frame.armorDropdown = CreateDropdown(frame, 80);
	frame.armorDropdown:SetPoint("LEFT", frame.specDropdown, "RIGHT", -8, 0);
	frame.armorDropdown.onChanged = function(armorType)
		db.armorType = armorType;
		ForeverLoot:Refresh();
	end

	frame.slotDropdown = CreateDropdown(frame, 90);
	frame.slotDropdown:SetPoint("LEFT", frame.specDropdown, "RIGHT", -8, 0);
	frame.slotDropdown:SetChoices(SlotChoices(), db.slot);
	frame.slotDropdown.onChanged = function(slotId)
		db.slot = slotId;
		ForeverLoot:Refresh();
	end

	frame.levelDropdown = CreateDropdown(frame, 110);
	frame.levelDropdown:SetPoint("LEFT", frame.slotDropdown, "RIGHT", -8, 0);
	frame.levelDropdown:SetChoices(ForeverLoot.BRACKETS, db.bracket);
	frame.levelDropdown.onChanged = function(bracketId)
		db.bracket = bracketId;
		ForeverLoot:Refresh();
	end

	frame.raidDropdown = CreateDropdown(frame, 140);
	frame.raidDropdown:SetPoint("LEFT", frame.slotDropdown, "RIGHT", -8, 0);
	frame.raidDropdown:SetChoices(RaidChoices(), db.raid);
	frame.raidDropdown.onChanged = function(raidId)
		db.raid = raidId;
		ForeverLoot:Refresh();
	end

	function frame:UpdateArmorDropdown()
		local choices = ForeverLoot:GetArmorChoices(db.class, db.spec or 0);
		local selectedOk = false;
		for _, choice in ipairs(choices) do
			if (choice.id == db.armorType) then
				selectedOk = true;
				break;
			end
		end
		if (not selectedOk) then
			db.armorType = "all";
		end

		if (#choices == 0) then
			self.armorDropdown:Hide();
			self.slotDropdown:SetPoint("LEFT", self.specDropdown, "RIGHT", -8, 0);
			return;
		end

		self.armorDropdown:Show();
		self.armorDropdown:SetChoices(choices, db.armorType or "all");
		self.armorDropdown:SetPoint("LEFT", self.specDropdown, "RIGHT", -8, 0);
		self.slotDropdown:SetPoint("LEFT", self.armorDropdown, "RIGHT", -8, 0);
	end

	frame:UpdateArmorDropdown();

	frame.favoritesButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate");
	frame.favoritesButton:SetSize(90, 22);
	frame.favoritesButton:SetPoint("TOPRIGHT", -18, -68);
	frame.favoritesButton:SetText("Favorites");
	frame.favoritesButton:SetScript("OnClick", function()
		db.favoritesOnly = not db.favoritesOnly;
		ForeverLoot:Refresh();
	end);

	frame.showAllLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	frame.showAllLabel:SetPoint("RIGHT", frame.favoritesButton, "LEFT", -10, 0);
	frame.showAllLabel:SetText("All items");

	frame.showAllCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate");
	frame.showAllCheck:SetSize(24, 24);
	frame.showAllCheck:SetPoint("RIGHT", frame.showAllLabel, "LEFT", -2, 0);
	frame.showAllCheck:SetChecked(db.showAll);
	frame.showAllCheck:SetScript("OnClick", function(self)
		db.showAll = self:GetChecked() and true or false;
		ForeverLoot:Refresh();
	end);
	frame.showAllCheck:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine("All items", 1, 0.82, 0);
		GameTooltip:AddLine("Show everything your class can equip,", 1, 1, 1);
		GameTooltip:AddLine("ignoring the spec, weapon and stat filters.", 1, 1, 1);
		GameTooltip:Show();
	end);
	frame.showAllCheck:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	local divider = frame:CreateTexture(nil, "ARTWORK");
	divider:SetPoint("TOPLEFT", 24, -96);
	divider:SetPoint("TOPRIGHT", -24, -96);
	divider:SetHeight(1);
	Paint(divider, GOLD_R, GOLD_G, GOLD_B, 0.4);

	local inset = CreateFrame("Frame", nil, frame, TEMPLATE);
	inset:SetPoint("TOPLEFT", 14, -104);
	inset:SetPoint("BOTTOMRIGHT", -12, 28);
	StyleDark(inset, INSET_BACKDROP);
	if (inset.SetBackdropColor) then
		inset:SetBackdropColor(0, 0, 0, 0.45);
		inset:SetBackdropBorderColor(0.75, 0.6, 0.25, 0.95);
	end

	frame.scroll = CreateFrame("ScrollFrame", nil, inset);
	frame.scroll:SetPoint("TOPLEFT", 6, -6);
	frame.scroll:SetPoint("BOTTOMRIGHT", -20, 6);
	frame.scroll:EnableMouseWheel(true);
	frame.scroll:SetScript("OnMouseWheel", function(_, delta)
		local _, maxScroll = frame.slider:GetMinMaxValues();
		local value = frame.slider:GetValue() - (delta * 48);
		if (value < 0) then
			value = 0;
		elseif (value > maxScroll) then
			value = maxScroll;
		end
		frame.slider:SetValue(value);
	end);

	frame.scrollChild = CreateFrame("Frame", nil, frame.scroll);
	frame.scrollChild:SetSize(CONTENT_WIDTH, 1);
	frame.scroll:SetScrollChild(frame.scrollChild);

	frame.empty = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontDisable");
	frame.empty:SetPoint("TOP", 0, -16);
	frame.empty:Hide();

	frame.slider = CreateFrame("Slider", nil, inset);
	frame.slider:SetOrientation("VERTICAL");
	frame.slider:SetPoint("TOPRIGHT", -4, -8);
	frame.slider:SetPoint("BOTTOMRIGHT", -4, 8);
	frame.slider:SetWidth(12);
	frame.slider:SetMinMaxValues(0, 0);
	frame.slider:SetValue(0);
	if (not pcall(frame.slider.SetThumbTexture, frame.slider, "Interface\\Buttons\\UI-ScrollBar-Knob")) then
		local thumb = frame.slider:CreateTexture(nil, "OVERLAY");
		Paint(thumb, 0.85, 0.7, 0.3, 1);
		thumb:SetSize(12, 28);
		frame.slider:SetThumbTexture(thumb);
	end
	frame.slider:SetScript("OnValueChanged", function(self, value)
		if (suppressSlider) then
			return;
		end
		frame.scroll:SetVerticalScroll(value);
	end);

	local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
	footer:SetPoint("BOTTOM", 0, 12);
	footer:SetText("Right-click an item to favorite.");

	frame:SetScript("OnHide", CloseMenu);
	frame:SetScript("OnShow", function()
		ForeverLoot:Refresh();
	end);

	SetTab(db.tab or "dungeons");
end

local RegisterOptions;

local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:RegisterEvent("PLAYER_ENTERING_WORLD");
loader:RegisterEvent("PLAYER_LEVEL_UP");
pcall(loader.RegisterEvent, loader, "PLAYER_EQUIPMENT_CHANGED");
pcall(loader.RegisterEvent, loader, "GET_ITEM_INFO_RECEIVED");
pcall(loader.RegisterEvent, loader, "ITEM_DATA_LOAD_RESULT");

local announced = false;
local classApplied = false;
local refreshPending = false;

local function SyncClassControls()
	if (not frame) then
		return;
	end

	frame.classDropdown:SetChoices(ClassChoices(), db.class);
	frame.specDropdown:SetChoices(SpecChoices(db.class), db.spec or 0);
	if (frame.UpdateArmorDropdown) then
		frame:UpdateArmorDropdown();
	end
	ColorClassLabel();
end

loader:SetScript("OnEvent", function(_, event, arg1)
	if (event == "ADDON_LOADED" and arg1 == AddonName) then
		ForeverLoot:NormalizeDB();
		ForeverLoot:EnsureClass();
		BuildFrame();
		if (ForeverLoot:ApplyPlayerClass()) then
			classApplied = true;
			SyncClassControls();
		end
		pcall(RegisterOptions);
		return;
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		if (not classApplied and ForeverLoot:ApplyPlayerClass()) then
			classApplied = true;
			SyncClassControls();
		end
		if (not announced) then
			announced = true;
			DEFAULT_CHAT_FRAME:AddMessage("|cff9d5db8ForeverLoot|r loaded. Type /fl to toggle the window.");
		end
		return;
	end

	if (not frame or not frame:IsShown() or refreshPending) then
		return;
	end

	refreshPending = true;
	if (C_Timer and C_Timer.After) then
		C_Timer.After(0.2, function()
			refreshPending = false;
			if (frame:IsShown()) then
				ForeverLoot:Refresh();
			end
		end);
	else
		refreshPending = false;
		ForeverLoot:Refresh();
	end
end);

local function ToggleFrame()
	if (not frame) then
		return;
	end

	frame:SetShown(not frame:IsShown());
end

SLASH_FOREVERLOOT1 = "/fl";
SLASH_FOREVERLOOT2 = "/foreverloot";

SlashCmdList.FOREVERLOOT = ToggleFrame;

RegisterOptions = function()
	local panel = CreateFrame("Frame");
	panel.name = "ForeverLoot";

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 16, -16);
	title:SetText("ForeverLoot");

	local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate");
	check:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16);
	check:SetChecked(ForeverLootDB and ForeverLootDB.minimap ~= false);

	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	label:SetPoint("LEFT", check, "RIGHT", 4, 0);
	label:SetText("Minimap button");

	local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	hint:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 4, -12);
	hint:SetJustifyH("LEFT");
	hint:SetText("Open with /fl or /foreverloot");

	local function ApplyMinimap()
		if (ForeverLootDB) then
			ForeverLootDB.minimap = check:GetChecked() and true or false;
		end
		if (ForeverLootMinimapButton) then
			ForeverLootMinimapButton:SetShown(ForeverLootDB and ForeverLootDB.minimap ~= false);
		end
	end

	check:SetScript("OnClick", ApplyMinimap);
	panel:SetScript("OnShow", function()
		check:SetChecked(ForeverLootDB and ForeverLootDB.minimap ~= false);
	end);

	if (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then
		local category = Settings.RegisterCanvasLayoutCategory(panel, "ForeverLoot");
		Settings.RegisterAddOnCategory(category);
	elseif (InterfaceOptions_AddCategory) then
		InterfaceOptions_AddCategory(panel);
	end
end
