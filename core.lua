local _, ForeverLoot = ...;

ForeverLoot.SPECS = {
	WARRIOR = {
		{ name = "Arms", roles = { physical = true } },
		{ name = "Fury", roles = { physical = true } },
		{ name = "Protection", roles = { physical = true, tank = true } },
	},
	PALADIN = {
		{ name = "Holy", roles = { heal = true } },
		{ name = "Protection", roles = { physical = true, tank = true } },
		{ name = "Retribution", roles = { physical = true } },
	},
	HUNTER = {
		{ name = "Beast Mastery", roles = { physical = true } },
		{ name = "Marksmanship", roles = { physical = true } },
		{ name = "Survival", roles = { physical = true } },
	},
	ROGUE = {
		{ name = "Assassination", roles = { physical = true } },
		{ name = "Combat", roles = { physical = true } },
		{ name = "Subtlety", roles = { physical = true } },
	},
	PRIEST = {
		{ name = "Discipline", roles = { heal = true } },
		{ name = "Holy", roles = { heal = true } },
		{ name = "Shadow", roles = { caster = true } },
	},
	SHAMAN = {
		{ name = "Elemental", roles = { caster = true } },
		{ name = "Enhancement", roles = { physical = true } },
		{ name = "Restoration", roles = { heal = true } },
	},
	MAGE = {
		{ name = "Arcane", roles = { caster = true } },
		{ name = "Fire", roles = { caster = true } },
		{ name = "Frost", roles = { caster = true } },
	},
	WARLOCK = {
		{ name = "Affliction", roles = { caster = true } },
		{ name = "Demonology", roles = { caster = true } },
		{ name = "Destruction", roles = { caster = true } },
	},
	DRUID = {
		{ name = "Balance", roles = { caster = true } },
		{ name = "Feral", roles = { physical = true, tank = true } },
		{ name = "Restoration", roles = { heal = true } },
	},
};

ForeverLoot.CLASSES = {
	"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID",
};

-- Armor subclass -> classes. Cloaks, jewelry and trinkets are handled separately.
-- Spec lists are what is worth browsing, not every armor type the class can equip.
-- 1 Holy, 2 Protection, 3 Retribution for paladins. Warrior tanks match that.
-- Missing specs fall back to the class default.
local ARMOR_TYPE_INFO = {
	{ id = "cloth", subclass = 1, label = "Cloth" },
	{ id = "leather", subclass = 2, label = "Leather" },
	{ id = "mail", subclass = 3, label = "Mail" },
	{ id = "plate", subclass = 4, label = "Plate" },
};

local ARMOR_SETS = {
	WARRIOR = {
		[1] = { "leather", "mail", "plate" },
		[2] = { "leather", "mail", "plate" },
		[3] = { "mail", "plate" },
	},
	PALADIN = {
		[1] = { "cloth", "leather", "mail", "plate" },
		[2] = { "mail", "plate" },
		[3] = { "leather", "mail", "plate" },
	},
	HUNTER = {
		[1] = { "leather", "mail" },
		[2] = { "leather", "mail" },
		[3] = { "leather", "mail" },
	},
	SHAMAN = {
		[1] = { "cloth", "leather", "mail" },
		[2] = { "leather", "mail" },
		[3] = { "cloth", "leather", "mail" },
	},
	ROGUE = {
		[1] = { "leather" },
		[2] = { "leather" },
		[3] = { "leather" },
	},
	DRUID = {
		[1] = { "cloth", "leather" },
		[2] = { "leather" },
		[3] = { "cloth", "leather" },
	},
	PRIEST = {
		[1] = { "cloth" },
		[2] = { "cloth" },
		[3] = { "cloth" },
	},
	MAGE = {
		[1] = { "cloth" },
		[2] = { "cloth" },
		[3] = { "cloth" },
	},
	WARLOCK = {
		[1] = { "cloth" },
		[2] = { "cloth" },
		[3] = { "cloth" },
	},
};

local ARMOR_ID_BY_SUBCLASS = {
	[1] = "cloth",
	[2] = "leather",
	[3] = "mail",
	[4] = "plate",
};

local ARMOR = {
	[1] = { MAGE = true, PRIEST = true, WARLOCK = true },
	[2] = { DRUID = true, ROGUE = true },
	[3] = { HUNTER = true, SHAMAN = true },
	[4] = { WARRIOR = true, PALADIN = true },
	[6] = { WARRIOR = true, PALADIN = true, SHAMAN = true },
	[7] = { PALADIN = true },
	[8] = { DRUID = true },
	[9] = { SHAMAN = true },
	[11] = { DRUID = true, PALADIN = true, SHAMAN = true },
};

local WEAPON = {
	[0] = { HUNTER = true, PALADIN = true, SHAMAN = true, WARRIOR = true },
	[1] = { HUNTER = true, PALADIN = true, SHAMAN = true, WARRIOR = true },
	[2] = { HUNTER = true, ROGUE = true, WARRIOR = true },
	[3] = { HUNTER = true, ROGUE = true, WARRIOR = true },
	[4] = { DRUID = true, PALADIN = true, PRIEST = true, ROGUE = true, SHAMAN = true, WARRIOR = true },
	[5] = { DRUID = true, PALADIN = true, SHAMAN = true, WARRIOR = true },
	[6] = { DRUID = true, HUNTER = true, PALADIN = true, WARRIOR = true },
	[7] = { HUNTER = true, MAGE = true, PALADIN = true, ROGUE = true, WARLOCK = true, WARRIOR = true },
	[8] = { HUNTER = true, PALADIN = true, WARRIOR = true },
	[10] = { DRUID = true, MAGE = true, PRIEST = true, SHAMAN = true, WARLOCK = true },
	[13] = { DRUID = true, HUNTER = true, ROGUE = true, SHAMAN = true, WARRIOR = true },
	[15] = { DRUID = true, HUNTER = true, MAGE = true, PRIEST = true, ROGUE = true, SHAMAN = true, WARLOCK = true, WARRIOR = true },
	[16] = { ROGUE = true, WARRIOR = true },
	[18] = { HUNTER = true, ROGUE = true, WARRIOR = true },
	[19] = { MAGE = true, PRIEST = true, WARLOCK = true },
};

ForeverLoot.SLOTS = {
	{ id = "all", label = "All slots" },
	{ id = "head", label = "Head", locs = { INVTYPE_HEAD = true } },
	{ id = "neck", label = "Neck", locs = { INVTYPE_NECK = true } },
	{ id = "shoulder", label = "Shoulder", locs = { INVTYPE_SHOULDER = true } },
	{ id = "back", label = "Back", locs = { INVTYPE_CLOAK = true } },
	{ id = "chest", label = "Chest", locs = { INVTYPE_CHEST = true, INVTYPE_ROBE = true } },
	{ id = "wrist", label = "Wrist", locs = { INVTYPE_WRIST = true } },
	{ id = "hands", label = "Hands", locs = { INVTYPE_HAND = true } },
	{ id = "waist", label = "Waist", locs = { INVTYPE_WAIST = true } },
	{ id = "legs", label = "Legs", locs = { INVTYPE_LEGS = true } },
	{ id = "feet", label = "Feet", locs = { INVTYPE_FEET = true } },
	{ id = "finger", label = "Finger", locs = { INVTYPE_FINGER = true } },
	{ id = "trinket", label = "Trinket", locs = { INVTYPE_TRINKET = true } },
	{ id = "weapon", label = "Weapon", locs = { INVTYPE_WEAPON = true, INVTYPE_2HWEAPON = true, INVTYPE_WEAPONMAINHAND = true, INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true, INVTYPE_THROWN = true } },
	{ id = "offhand", label = "Off Hand", locs = { INVTYPE_SHIELD = true, INVTYPE_HOLDABLE = true, INVTYPE_WEAPONOFFHAND = true } },
	{ id = "relic", label = "Relic", locs = { INVTYPE_RELIC = true } },
};

ForeverLoot.BRACKETS = {
	{ id = "all", label = "All levels" },
	{ id = "10-20", label = "Levels 10-20", min = 10, max = 20 },
	{ id = "20-30", label = "Levels 20-30", min = 20, max = 30 },
	{ id = "30-40", label = "Levels 30-40", min = 30, max = 40 },
	{ id = "40-50", label = "Levels 40-50", min = 40, max = 50 },
	{ id = "50-60", label = "Levels 50-60", min = 50, max = 60 },
};

local SHARED_EQUIP = {
	INVTYPE_CLOAK = true,
	INVTYPE_NECK = true,
	INVTYPE_FINGER = true,
	INVTYPE_TRINKET = true,
	INVTYPE_BODY = true,
	INVTYPE_TABARD = true,
};

local db;
local requested = {};
local instantCache = {};
local nameCache = {};
local statsCache = {};
local blobCache = {};
local levelCache = {};
local roleCache = {};
local armorIdCache = {};
local qualityColors = {};

local function KeyHas(key, tokens)
	for _, token in ipairs(tokens) do
		if (string.find(key, token, 1, true)) then
			return true;
		end
	end

	return false;
end

local function StatAmount(stats, tokens, skipTokens)
	local total = 0;

	for key, value in pairs(stats) do
		if (type(key) == "string" and type(value) == "number" and KeyHas(key, tokens) and not (skipTokens and KeyHas(key, skipTokens))) then
			total = total + value;
		end
	end

	return total;
end

function ForeverLoot:GetDB()
	return db;
end

function ForeverLoot:NormalizeDB()
	if (type(ForeverLootDB) ~= "table") then
		ForeverLootDB = {};
	end

	db = ForeverLootDB;
	if (type(db.favorites) ~= "table") then
		db.favorites = {};
	end

	db.spec = tonumber(db.spec) or 0;
	db.slot = db.slot or "all";
	db.armorType = db.armorType or "all";
	db.bracket = db.bracket or "all";
	local knownBracket = false;
	for _, bracket in ipairs(self.BRACKETS) do
		if (bracket.id == db.bracket) then
			knownBracket = true;
			break;
		end
	end
	if (not knownBracket) then
		db.bracket = "all";
	end
	db.raid = db.raid or "MoltenCore";
	db.tab = db.tab == "raids" and "raids" or "dungeons";
	db.favoritesOnly = db.favoritesOnly and true or false;
	db.showAll = db.showAll and true or false;
	db.minimap = db.minimap ~= false;
	db.minimapAngle = tonumber(db.minimapAngle) or 225;

	if (db.class and not self.SPECS[db.class]) then
		db.class = nil;
	end
end

function ForeverLoot:PlayerClass()
	if (not UnitClass) then
		return nil;
	end

	local _, classFile = UnitClass("player");
	if (classFile and self.SPECS[classFile]) then
		return classFile;
	end
end

function ForeverLoot:ApplyPlayerClass()
	local classFile = self:PlayerClass();
	if (not classFile) then
		return false;
	end

	if (db.class ~= classFile) then
		db.class = classFile;
		db.spec = 0;
		db.armorType = "all";
	end

	return true;
end

function ForeverLoot:EnsureClass()
	local classFile = self:PlayerClass();
	if (classFile) then
		if (not db.class or not self.SPECS[db.class]) then
			db.class = classFile;
			db.spec = 0;
		end
		return db.class;
	end

	if (db.class and self.SPECS[db.class]) then
		return db.class;
	end

	db.class = "WARRIOR";
	db.spec = 0;
	return db.class;
end

function ForeverLoot:ClassName(classFile)
	if (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile]) then
		return LOCALIZED_CLASS_NAMES_MALE[classFile];
	end

	return classFile;
end

function ForeverLoot:GetItemInstant(itemId)
	local cached = instantCache[itemId];
	if (cached) then
		return cached;
	end

	local func = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant;
	if (not func) then
		return nil;
	end

	local ok, id, _, _, equipLoc, icon, classId, subClassId = pcall(func, itemId);
	if (not ok or type(id) ~= "number") then
		return nil;
	end

	cached = {
		equipLoc = equipLoc,
		icon = icon,
		classId = classId,
		subClassId = subClassId,
	};
	instantCache[itemId] = cached;
	return cached;
end

function ForeverLoot:GetItemName(itemId)
	local cached = nameCache[itemId];
	if (cached) then
		return cached[1], cached[2], cached[3], cached[4];
	end

	local func = (C_Item and C_Item.GetItemInfo) or GetItemInfo;
	if (not func) then
		return nil;
	end

	local ok, name, link, quality, _, requiredLevel = pcall(func, itemId);
	if (not ok or type(name) ~= "string") then
		return nil;
	end

	nameCache[itemId] = { name, link, quality, requiredLevel };
	return name, link, quality, requiredLevel;
end

function ForeverLoot:DungeonLevels(dungeon)
	local cached = levelCache[dungeon];
	if (cached) then
		return cached[1], cached[2];
	end

	local minLevel = dungeon.minLevel;
	local maxLevel = dungeon.maxLevel;
	local highestRequired = nil;
	local lowestRequired = nil;
	local waiting = false;

	for _, boss in ipairs(dungeon.bosses or {}) do
		for _, itemId in ipairs(boss.items or {}) do
			self:RequestItem(itemId);
			local _, _, _, requiredLevel = self:GetItemName(itemId);
			if (requiredLevel == nil) then
				waiting = true;
			elseif (type(requiredLevel) == "number" and requiredLevel > 0) then
				if (not highestRequired or requiredLevel > highestRequired) then
					highestRequired = requiredLevel;
				end
				if (not lowestRequired or requiredLevel < lowestRequired) then
					lowestRequired = requiredLevel;
				end
			end
		end
	end

	if (highestRequired and lowestRequired and not waiting) then
		minLevel = lowestRequired;
		maxLevel = highestRequired + 2;
		if (maxLevel < minLevel) then
			maxLevel = minLevel;
		end
		levelCache[dungeon] = { minLevel, maxLevel };
	end

	return minLevel, maxLevel;
end

function ForeverLoot:GetItemStats(itemId)
	local cached = statsCache[itemId];
	if (cached ~= nil) then
		return cached or nil;
	end

	local func = (C_Item and C_Item.GetItemStats) or GetItemStats;
	if (not func) then
		return nil;
	end

	local ok, stats = pcall(func, "item:" .. itemId);
	if (ok and type(stats) == "table" and next(stats)) then
		statsCache[itemId] = stats;
		return stats;
	end

	-- The item is loaded and simply has no stats. Don't ask again.
	if (nameCache[itemId]) then
		statsCache[itemId] = false;
	end

	return nil;
end

function ForeverLoot:RequestItem(itemId)
	if (requested[itemId]) then
		return;
	end

	requested[itemId] = true;

	if (C_Item and C_Item.RequestLoadItemDataByID) then
		pcall(C_Item.RequestLoadItemDataByID, itemId);
	end
end

function ForeverLoot:QualityColor(quality)
	quality = quality or 1;
	local cached = qualityColors[quality];
	if (cached) then
		return cached[1], cached[2], cached[3];
	end

	local r, g, b = 0.62, 0.62, 0.62;
	if (C_Item and C_Item.GetItemQualityColor) then
		local ok, first, second, third = pcall(C_Item.GetItemQualityColor, quality);
		if (ok and type(first) == "number") then
			r, g, b = first, second, third;
		elseif (ok and type(first) == "table" and first.GetRGB) then
			r, g, b = first:GetRGB();
		end
	elseif (GetItemQualityColor) then
		local cr, cg, cb = GetItemQualityColor(quality);
		if (cr) then
			r, g, b = cr, cg, cb;
		end
	end

	qualityColors[quality] = { r, g, b };
	return r, g, b;
end

local function MailFromLevel30()
	local bracketId = db and db.bracket or "all";
	if (bracketId == "all") then
		return true;
	end

	for _, bracket in ipairs(ForeverLoot.BRACKETS) do
		if (bracket.id == bracketId) then
			return (bracket.min or 0) >= 30;
		end
	end

	return true;
end

local function ArmorTypeAvailable(classFile, typeId)
	if (typeId == "plate") then
		return classFile == "WARRIOR" or classFile == "PALADIN";
	end

	if (typeId == "mail" and (classFile == "HUNTER" or classFile == "SHAMAN")) then
		return MailFromLevel30();
	end

	return true;
end

function ForeverLoot:GetArmorTypeIds(classFile, specIndex)
	specIndex = tonumber(specIndex) or 0;
	local key = classFile .. specIndex .. (db and db.bracket or "all");
	local cached = armorIdCache[key];
	if (cached) then
		return cached;
	end

	local sets = ARMOR_SETS[classFile];
	local indexes = {};

	if (specIndex and specIndex ~= 0 and sets and sets[specIndex]) then
		table.insert(indexes, specIndex);
	elseif (sets) then
		for index in pairs(sets) do
			table.insert(indexes, index);
		end
	end

	local seen = {};
	local picked = {};

	for _, index in ipairs(indexes) do
		for _, typeId in ipairs(sets[index]) do
			if (ArmorTypeAvailable(classFile, typeId) and not seen[typeId]) then
				seen[typeId] = true;
				table.insert(picked, typeId);
			end
		end
	end

	if (#picked == 0) then
		if (classFile == "WARRIOR" or classFile == "PALADIN") then
			armorIdCache[key] = { "mail" };
			return armorIdCache[key];
		end
		if (classFile == "HUNTER" or classFile == "SHAMAN") then
			armorIdCache[key] = { "leather" };
			return armorIdCache[key];
		end
	end

	local ordered = {};
	for _, info in ipairs(ARMOR_TYPE_INFO) do
		if (seen[info.id]) then
			table.insert(ordered, info.id);
		end
	end

	armorIdCache[key] = ordered;
	return ordered;
end

function ForeverLoot:GetArmorChoices(classFile, specIndex)
	local typeIds = self:GetArmorTypeIds(classFile, specIndex);
	if (#typeIds <= 1) then
		return {};
	end

	local choices = { { id = "all", label = "All" } };
	for _, typeId in ipairs(typeIds) do
		for _, info in ipairs(ARMOR_TYPE_INFO) do
			if (info.id == typeId) then
				table.insert(choices, { id = info.id, label = info.label });
				break;
			end
		end
	end

	return choices;
end

function ForeverLoot:ClassCanUse(classFile, info)
	if (not info or not info.classId) then
		return true;
	end

	if (SHARED_EQUIP[info.equipLoc]) then
		return true;
	end

	if (info.classId == 4) then
		if (not info.subClassId or info.subClassId == 0) then
			return true;
		end

		local armorId = ARMOR_ID_BY_SUBCLASS[info.subClassId];
		if (armorId) then
			local allowed = false;
			for _, typeId in ipairs(self:GetArmorTypeIds(classFile, db and db.spec or 0)) do
				if (typeId == armorId) then
					allowed = true;
					break;
				end
			end

			if (not allowed) then
				return false;
			end

			if (db and db.armorType and db.armorType ~= "all" and db.armorType ~= armorId) then
				return false;
			end

			return true;
		end

		local allowed = ARMOR[info.subClassId];
		if (not allowed) then
			return true;
		end

		return allowed[classFile] == true;
	end

	if (info.classId == 2) then
		local allowed = WEAPON[info.subClassId];
		if (not allowed) then
			return true;
		end

		return allowed[classFile] == true;
	end

	return false;
end

local slotLocs;

function ForeverLoot:SlotMatches(slotId, equipLoc)
	if (not slotId or slotId == "all") then
		return true;
	end

	if (not equipLoc or equipLoc == "") then
		return true;
	end

	if (not slotLocs) then
		slotLocs = {};
		for _, slot in ipairs(self.SLOTS) do
			slotLocs[slot.id] = slot.locs;
		end
	end

	local locs = slotLocs[slotId];
	if (not locs) then
		return true;
	end

	return locs[equipLoc] == true;
end

local WEAPON_LOCS = {
	INVTYPE_WEAPON = true,
	INVTYPE_2HWEAPON = true,
	INVTYPE_WEAPONMAINHAND = true,
	INVTYPE_WEAPONOFFHAND = true,
	INVTYPE_HOLDABLE = true,
	INVTYPE_RANGED = true,
	INVTYPE_RANGEDRIGHT = true,
	INVTYPE_THROWN = true,
};

function ForeverLoot:AllowedRoles(classFile, specIndex)
	specIndex = tonumber(specIndex) or 0;
	local key = (classFile or "") .. specIndex;
	local cached = roleCache[key];
	if (cached) then
		return cached;
	end

	local roles = {};
	local specs = self.SPECS[classFile];
	if (not specs) then
		roleCache[key] = roles;
		return roles;
	end

	if (specIndex and specIndex ~= 0 and specs[specIndex]) then
		for role in pairs(specs[specIndex].roles) do
			roles[role] = true;
		end
	else
		for _, spec in ipairs(specs) do
			for role in pairs(spec.roles) do
				roles[role] = true;
			end
		end
	end

	roleCache[key] = roles;
	return roles;
end

-- 1h / 2h / shield / holdable / off-hand weapon. spell = "healing" or "damage" matches the tooltip wording.
local SPEC_WEAPONS = {
	WARRIOR = {
		[1] = { ["2h"] = true, ranged = true },
		[2] = { ["1h"] = true, ranged = true },
		[3] = { ["1h"] = true, shield = true, ranged = true },
	},
	PALADIN = {
		-- Holy uses healing weapons and spell power weapons. Ret uses plain weapons plus spell power, not healing.
		[1] = { ["1h"] = true, ["2h"] = true, shield = true, hold = true, spell = "healing", spellAlso = "damage" },
		[2] = { ["1h"] = true, shield = true },
		[3] = { ["2h"] = true, spellAlso = "damage" },
	},
	PRIEST = {
		[1] = { ["1h"] = true, ["2h"] = true, hold = true, ranged = true, spell = "healing" },
		[2] = { ["1h"] = true, ["2h"] = true, hold = true, ranged = true, spell = "healing" },
		[3] = { ["1h"] = true, ["2h"] = true, hold = true, ranged = true, spell = "damage" },
	},
	SHAMAN = {
		[1] = { ["1h"] = true, ["2h"] = true, hold = true, shield = true, spell = "damage" },
		[2] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true },
		[3] = { ["1h"] = true, ["2h"] = true, hold = true, shield = true, spell = "healing" },
	},
	MAGE = {
		[1] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
		[2] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
		[3] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
	},
	WARLOCK = {
		[1] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
		[2] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
		[3] = { ["1h"] = true, ["2h"] = true, hold = true, offhand = true, ranged = true, spell = "damage" },
	},
	DRUID = {
		[1] = { ["1h"] = true, ["2h"] = true, hold = true, spell = "damage" },
		[3] = { ["1h"] = true, ["2h"] = true, hold = true, spell = "healing" },
	},
};

local function WeaponHand(equipLoc)
	if (equipLoc == "INVTYPE_2HWEAPON") then
		return "2h";
	end
	if (equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND") then
		return "1h";
	end
	if (equipLoc == "INVTYPE_SHIELD") then
		return "shield";
	end
	if (equipLoc == "INVTYPE_HOLDABLE") then
		return "hold";
	end
	if (equipLoc == "INVTYPE_WEAPONOFFHAND") then
		return "offhand";
	end
	if (equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_THROWN") then
		return "ranged";
	end
end

local function StripTooltipText(text)
	if (not text) then
		return "";
	end

	text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "");
	text = string.gsub(text, "|r", "");
	return string.lower(text);
end

local function TooltipBlob(itemId)
	local cached = blobCache[itemId];
	if (cached) then
		return cached;
	end

	if (not (C_TooltipInfo and C_TooltipInfo.GetItemByID)) then
		return nil;
	end

	local ok, data = pcall(C_TooltipInfo.GetItemByID, itemId);
	if (not ok or not data or not data.lines or #data.lines == 0) then
		return nil;
	end

	local parts = {};
	for _, line in ipairs(data.lines) do
		if (line.leftText) then
			table.insert(parts, line.leftText);
		end
	end

	cached = StripTooltipText(table.concat(parts, "\n"));
	blobCache[itemId] = cached;
	return cached;
end

-- Classic-era items carry spell power, healing and attack power as "Equip:" text rather than
-- as item stats, so GetItemStats never reports them. Read the tooltip instead.
-- Returns nil while the tooltip is not available yet.
local function ItemEffects(itemId)
	local blob = TooltipBlob(itemId);
	if (not blob) then
		return nil;
	end

	-- Same wording and priority as the first version. "Increases healing done" wins, so a healing
	-- item that also adds a little damage stays a healing item. "Increases damage and healing"
	-- does not contain that phrase, so it stays spell power for casters.
	local effects = {};
	if (string.find(blob, "increases healing done", 1, true)) then
		effects.healing = true;
	elseif (string.find(blob, "increases damage and healing", 1, true) or string.find(blob, "increases damage done", 1, true)) then
		effects.damage = true;
	end
	if (string.find(blob, "increases attack power", 1, true)) then
		effects.attack = true;
	end
	if (string.find(blob, "increased defense", 1, true) or string.find(blob, "increases defense", 1, true)) then
		effects.defense = true;
	end
	-- Thorns ("when struck") and block damage are tank effects, same as defense.
	if (string.find(blob, "when struck", 1, true) or string.find(blob, "you block", 1, true)) then
		effects.defense = true;
	end

	return effects;
end

-- Original weapon wording, kept separate so a "damage and healing" weapon still counts as
-- damage here, the way the first version did.
local function SpellWeaponKind(itemId)
	local blob = TooltipBlob(itemId);
	if (not blob) then
		return nil;
	end

	if (string.find(blob, "increases healing done", 1, true)) then
		return "healing";
	end
	if (string.find(blob, "increases damage and healing", 1, true) or string.find(blob, "increases damage done", 1, true)) then
		return "damage";
	end

	return "none";
end

local function IsWand(info)
	return info and info.classId == 2 and info.subClassId == 19;
end

local function SpecWeaponOk(self, classFile, specIndex, itemId, info)
	local rules = SPEC_WEAPONS[classFile];
	local rule = rules and rules[specIndex];
	local hand = WeaponHand(info.equipLoc);

	if (rule) then
		if (not hand or not rule[hand]) then
			return false;
		end

		-- Wands are decided by the effect/stat check below, not by the melee spell-weapon rule.
		if (IsWand(info)) then
			return true;
		end

		local kind = SpellWeaponKind(itemId);
		if (rule.spell or rule.spellAlso) then
			if (not kind) then
				return true;
			end
			if (kind == "none") then
				-- A required spell kind (Holy) rejects plain weapons. spellAlso alone (Ret) keeps them.
				return not rule.spell;
			end
			return kind == rule.spell or kind == rule.spellAlso;
		end

		if (kind == "healing" or kind == "damage") then
			return false;
		end

		return true;
	end

	local roles = self:AllowedRoles(classFile, specIndex);
	if (roles.caster or roles.heal) then
		return true;
	end

	local kind = SpellWeaponKind(itemId);
	if (kind == "healing" or kind == "damage") then
		return false;
	end

	return true;
end

function ForeverLoot:WeaponMatches(classFile, specIndex, itemId, info)
	if (not info or not (WEAPON_LOCS[info.equipLoc] or info.equipLoc == "INVTYPE_SHIELD")) then
		return true;
	end

	self:RequestItem(itemId);
	specIndex = tonumber(specIndex) or 0;

	if (specIndex == 0) then
		local specs = self.SPECS[classFile];
		if (not specs) then
			return true;
		end

		for index = 1, #specs do
			if (SpecWeaponOk(self, classFile, index, itemId, info)) then
				return true;
			end
		end

		return false;
	end

	return SpecWeaponOk(self, classFile, specIndex, itemId, info);
end

-- Holy paladins want spell power on anything they can equip. Retribution wants it on weapons only.
function ForeverLoot:WantsSpellPower(classFile, specIndex, itemId)
	if (classFile ~= "PALADIN") then
		return false;
	end

	specIndex = tonumber(specIndex) or 0;
	if (specIndex == 0 or specIndex == 1) then
		return true;
	end

	if (specIndex ~= 3) then
		return false;
	end

	local info = self:GetItemInstant(itemId);
	return info and (WEAPON_LOCS[info.equipLoc] or info.equipLoc == "INVTYPE_SHIELD");
end

-- Primary stats a role cares about. Stamina is neutral and never counts against an item.
local PRIMARY_STATS = { "STRENGTH", "AGILITY", "INTELLECT", "SPIRIT" };

local ROLE_STATS = {
	caster = { INTELLECT = true, SPIRIT = true },
	heal = { INTELLECT = true, SPIRIT = true },
	physical = { STRENGTH = true, AGILITY = true },
	tank = { STRENGTH = true, AGILITY = true },
};

-- Special effects win outright: spell power for casters, healing for healers, attack power for
-- physical specs, defense for tanks. Stats (intellect, spirit, strength, agility) are only looked
-- at when the item has none of those. Stamina is neutral and never counts against an item.
function ForeverLoot:StatMatches(classFile, specIndex, itemId)
	local roles = self:AllowedRoles(classFile, specIndex);
	if (not next(roles)) then
		return true;
	end

	-- Tooltip not loaded yet: keep the item until the data arrives.
	local effects = ItemEffects(itemId);
	if (not effects) then
		return true;
	end

	local stats = self:GetItemStats(itemId);
	local spellDamage = stats and StatAmount(stats, { "SPELL_POWER", "SPELL_DAMAGE" }, { "HEALING" }) or 0;
	local healing = stats and StatAmount(stats, { "HEALING" }) or 0;
	local attack = stats and StatAmount(stats, { "ATTACK_POWER" }) or 0;
	local defense = stats and StatAmount(stats, { "DEFENSE" }) or 0;

	-- Healing wins when it is the stronger effect, same as the first version. A little bit of
	-- spell damage on a healing item does not make it show up for a caster.
	local healingWins = effects.healing or healing > spellDamage;
	local hasHealing = healingWins and (effects.healing or healing > 0);
	local hasDamage = not healingWins and (effects.damage or spellDamage > 0);
	local hasAttack = effects.attack or attack > 0;
	local hasDefense = effects.defense or defense > 0;

	if (hasDamage or hasHealing or hasAttack or hasDefense) then
		if (hasDamage and (roles.caster or self:WantsSpellPower(classFile, specIndex, itemId))) then
			return true;
		end
		if (roles.heal and hasHealing) then
			return true;
		end
		if (roles.physical and hasAttack) then
			return true;
		end
		if (roles.tank and hasDefense) then
			return true;
		end

		return false;
	end

	if (not stats) then
		return true;
	end

	local wanted = {};
	for role in pairs(roles) do
		for stat in pairs(ROLE_STATS[role] or {}) do
			wanted[stat] = true;
		end
	end

	local info = self:GetItemInstant(itemId);
	local equipLoc = info and info.equipLoc;
	-- Spirit on jewelry and trinkets is worth seeing on every class, including a Stamina + Spirit ring for a warrior.
	if (equipLoc == "INVTYPE_NECK" or equipLoc == "INVTYPE_FINGER" or equipLoc == "INVTYPE_TRINKET") then
		wanted.SPIRIT = true;
	end

	-- Agility + Spirit or Strength + Spirit, with no spell power, is not caster or healer gear.
	-- Spirit on its own still counts, including a Stamina + Spirit ring.
	if ((roles.caster or roles.heal) and not roles.physical and StatAmount(stats, { "SPIRIT" }) > 0 and (StatAmount(stats, { "AGILITY" }) > 0 or StatAmount(stats, { "STRENGTH" }) > 0)) then
		wanted.SPIRIT = nil;
	end

	local hasPrimary = false;
	for _, stat in ipairs(PRIMARY_STATS) do
		if (StatAmount(stats, { stat }) > 0) then
			if (wanted[stat]) then
				return true;
			end
			hasPrimary = true;
		end
	end

	return not hasPrimary;
end

local EQUIP_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
local equippedSet = {};

function ForeverLoot:RebuildEquipped()
	for id in pairs(equippedSet) do
		equippedSet[id] = nil;
	end

	if (not GetInventoryItemID) then
		return;
	end

	for _, slot in ipairs(EQUIP_SLOTS) do
		local id = GetInventoryItemID("player", slot);
		if (id) then
			equippedSet[id] = true;
		end
	end
end

function ForeverLoot:IsEquipped(itemId)
	return equippedSet[itemId] == true or equippedSet[tonumber(itemId)] == true;
end

function ForeverLoot:IsFavorite(itemId)
	return db.favorites[itemId] or db.favorites[tostring(itemId)] or false;
end

function ForeverLoot:ToggleFavorite(itemId)
	local on = not self:IsFavorite(itemId);
	db.favorites[itemId] = on or nil;
	db.favorites[tostring(itemId)] = nil;
end

function ForeverLoot:ItemPasses(itemId)
	if (db.favoritesOnly and not self:IsFavorite(itemId)) then
		return false;
	end

	-- Ask for the item, then only keep it once the client actually has it. A real icon with
	-- "Retrieving item information" means the record exists but the item was never implemented.
	self:RequestItem(itemId);
	if (not self:GetItemName(itemId)) then
		return false;
	end

	local info = self:GetItemInstant(itemId);
	if (not info or not info.icon or info.icon == 134400) then
		return false;
	end

	if (not self:ClassCanUse(db.class, info)) then
		return false;
	end

	if (not self:SlotMatches(db.slot, info.equipLoc)) then
		return false;
	end

	-- "All items" only keeps the class/slot filters and skips every spec-based check.
	if (db.showAll) then
		return true;
	end

	if (not self:WeaponMatches(db.class, db.spec or 0, itemId, info)) then
		return false;
	end

	if (not self:StatMatches(db.class, db.spec or 0, itemId)) then
		return false;
	end

	return true;
end

function ForeverLoot:BracketById(bracketId)
	for _, bracket in ipairs(self.BRACKETS) do
		if (bracket.id == bracketId) then
			return bracket;
		end
	end

	return self.BRACKETS[1];
end

function ForeverLoot:DungeonInBracket(dungeon, bracket)
	if (not bracket or bracket.id == "all") then
		return true;
	end

	local minLevel, maxLevel = self:DungeonLevels(dungeon);
	minLevel = minLevel or 1;
	maxLevel = maxLevel or 60;
	return maxLevel >= bracket.min and minLevel <= bracket.max;
end
