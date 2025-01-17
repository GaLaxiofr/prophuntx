local function ThrowError ( ErrMode, strCommand, strNeeded, strData )
	if ErrMode == 1 then
		ErrorNoHalt("!!PHX.UI.CreateVGUIType() --> [" .. strCommand .. "] argument 'data' is empty. Panel creation discarded.", 2)
	elseif ErrMode == 2 then
		error( "!!PHX.UI.CreateVGUIType() --> [" .. strCommand .. "] FAILED! - 'data' argument must contain ".. strNeeded .." value, got: " .. tostring(type(strData)) .." instead!!", 2 )
	end
end

local function CvarChangedMessage( ... )
	PHX:AddChat( PHX:Translate("PHXM_CVAR_CHANGED", ... ), Color(255, 194, 14) )
end

-- [!] VarArgs as Table
local function ConfirmMessage( cvar, value )
	--Derma_Message( PHX:Translate("PHXM_CVAR_CHANGED", ... ), "INFO", "OK" )
	PHX:MsgBox( {"PHXM_CVAR_CHANGED", cvar, value}, "MISC_INFO", "MISC_OK" )
end

PHX.CLUI = {
["check"]	= function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end

	if ( d and type(d) == "string" ) then
        local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
		pnl:SetBackgroundColor( Color(0,0,0,0) )
    
		local chk = vgui.Create("DCheckBoxLabel", pnl)
        chk:Dock(FILL)
		--chk:SetPos(0,0)
		chk:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
		chk:SetText(PHX:QTrans(l))	--chk:SetText(l)
		chk:SetFont("HudHintTextLarge")
		chk:SetValue( GetConVar(c):GetBool() ) -- forcebool, don't use PHX:CLCVar()
		function chk:OnChange(bool)
			local v = 0
			v = (bool and 1 or 0)
			if d == "SERVER" then
				net.Start("SvCommandReq")
				  net.WriteString(c)
				  net.WriteString(tostring(v))	-- Changed to String because GetGlobalBool doesn't like actual type (0 = ignored).
				net.SendToServer()
			elseif d == "CLIENT" then
				RunConsoleCommand(c, tostring(v))
				CvarChangedMessage(c, tostring(v))
				if v == 1 then
					surface.PlaySound("buttons/button9.wav")
				else
					surface.PlaySound("buttons/button19.wav")
				end
			end
		end
		return pnl
	else
		ThrowError(2, c, "string", d)
	end
	
end,

["label"] = function( c, d, p, l )
	local txt = vgui.Create("DLabel")
	txt:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
	txt:SetText(PHX:QTrans(l)) --txt:SetText(l)
	if !d then
		txt:SetFont("HudHintTextLarge")
	else
		txt:SetFont(d)
	end
	txt:SetTextColor(color_white)
	return txt
end,

["spacer"] = function( c, d, p, l )
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
	pnl:SetBackgroundColor(Color(0,0,0,0))
	
	return pnl
end,

["btn"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end

	if ( d and type(d) == "table" ) then

		local legal = #d
		
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
		pnl:SetBackgroundColor( Color(0,0,0,0) )
		
		local function m_btncreation( m_panel, m_panelText, m_func )
			local btn = vgui.Create("DButton", m_panel)
			btn:SetText(PHX:QTrans(m_panelText)) --btn:SetText(m_panelText)
			btn:Dock(LEFT)
			btn:DockMargin(0,2,8,2)
			-- If this looks stupid, but it working, it ain't stupid!
			btn:SizeToContents()
			btn:SetSize(btn:GetWide()+16,btn:GetTall())
			btn.DoClick = m_func
		end
		
		for i=1,legal do
			m_btncreation(pnl, d[i][1], d[i][2])	--1 = text string, 2 = function
		end
		return pnl
	else
		ThrowError(2, c, "table", d)
	end
end,

["slider"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end
	
	if ( d and type(d) == "table" ) then
		local min = d.min
		local max = d.max
		local dval = 0 -- this is fail-safe value, we can't guarantee the value of `d.init` yet.
		local dec = d.dec
		local kind = d.kind
		local float = d.float
		
		if d.init == nil then
			dval = c	-- use from 'c' instead.
		elseif isstring(dval) or d.init == "DEF_CONVAR" then
			dval = PHX:QCVar(c)	-- we can now enable default initialization value from the 'ConVar' (c) argument. See sh_propchooser.lua at ADDON_INFO.
		else
			dval = d.init -- assume it's correct number value. We keep this because there are still GetCVar() being used in cl_menu.lua
		end
		
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight()-6)
		pnl:SetBackgroundColor(Color(120,120,120,200))
		
		local slider = vgui.Create("DNumSlider",pnl)
		slider:SetPos(10,0)
		slider:SetSize(pnl:GetWide()*0.9,pnl:GetTall())
		slider:SetText(PHX:QTrans(l))		--slider:SetText(l)
		slider:SetToolTip(PHX:QTrans(l))	--slider:SetToolTip(l)
		slider:SetMin(min)
		slider:SetMax(max)
		slider:SetValue(dval)
		slider:SetDecimals(dec)
		slider.OnValueChanged = function(self,value)
			self:SetValue(value)
			if kind == "SERVER" then
				net.Start("SvCommandSliderReq")
				net.WriteString(c)
				net.WriteBool(float)
				if float then
					net.WriteFloat(value)
				else
					net.WriteInt(self:GetValue(), 16)
				end
				net.SendToServer()
			elseif kind == "CLIENT" then
				if float then
					RunConsoleCommand( c, tostring( value ) )
				else
					RunConsoleCommand( c, tostring(math.Round( value )) )
				end
			end
		end
		return pnl
	else
		ThrowError(2, c, "table", d)
	end
end,

["mute"] = function( c, d, p, l )
	if !d then
		ThrowError(1, c)
		return
	end
	
	if ( d and type(d) == "Player" and IsValid(d) ) then
		local ply = d
		local pnl = vgui.Create("DPanel")
		pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight()-6)
		pnl:SetBackgroundColor(Color(20,20,20,150))
		
        local buttonsize = p:GetColWide() * 0.85 / 24
        
		local ava = vgui.Create("AvatarImage", pnl)
		ava:Dock(LEFT)
		ava:SetSize(60,0)
		ava:SetPlayer(ply,64)
		
		local name = vgui.Create("DLabel", pnl)
		name:Dock(LEFT)
		name:DockMargin(8,4,8,4)
		name:SetSize(p:GetColWide()/2,0)
		name:SetText(ply:Nick())
		name:SetFont("HudHintTextLarge")
		name:SetTextColor(color_white)
		
		local imagebtn
		local button = vgui.Create("DButton", pnl)
		button:Dock(RIGHT)
		button:DockMargin(4,0,4,0)
		button:SetSize(60,0)
		button:SetText("")
		button.Paint = function(self)
			surface.SetDrawColor(90,90,90,0)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		
		button.DoClick = function()
			if not IsValid(ply) then return end
			if ply:IsAdmin() or table.HasValue(PHX.IgnoreMutedUserGroup, string.lower(ply:GetUserGroup())) then return end
			
			local mute = ply:IsMuted()
			ply:SetMuted(not mute)
			imagebtn:SetImage(PHX.UI:GetMutedStateIcon(not mute))
		end
		
		if ply == LocalPlayer() then
			button:SetVisible(false)
		else
			button:SetVisible(true)
		end
		
		if ply:IsAdmin() or table.HasValue( PHX.IgnoreMutedUserGroup, string.lower(ply:GetUserGroup()) ) then
			button:SetVisible(false)
		end
		
		imagebtn = vgui.Create("DImage",button)
		imagebtn:Dock(FILL)
		imagebtn:SetImage(PHX.UI:GetMutedStateIcon(ply:IsMuted()))
		
		return pnl
	else
		ThrowError(2, c, "Player Entity", d)
	end
end,

["binder"] = function( c, d, p, l )	
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
	pnl:SetBackgroundColor( Color(0,0,0,0) )
	
	local label = vgui.Create("DLabel", pnl)
	label:Dock(LEFT)
	label:SetSize(pnl:GetWide()*0.75,0)
	label:DockMargin(2,0,0,0)
	label:SetFont("HudHintTextLarge")
	label:SetText(PHX:QTrans(l)) --label:SetText(l)
	
	local bind = vgui.Create("DBinder", pnl)
	bind:Dock(LEFT)
	bind:SetSize(128 , 0)
	bind:DockMargin(4,2,0,2)
	
	local keyNum = GetConVar(c):GetInt()
	bind:SetValue(keyNum)
	function bind:OnChange( num )
		RunConsoleCommand(c, tostring(num))
		local tkeyName =  input.GetKeyName(num):upper()
		CvarChangedMessage(c, tostring(tkeyName))
		surface.PlaySound("buttons/button9.wav")
	end
	return pnl
end,

["langcombobox"] = function( c, d, p, l )
	if !l or l == "" or l == nil then l = false end
	if !d or d == false or d == nil then d = false end

	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide(),p:GetRowHeight())
	pnl:SetBackgroundColor( Color(0,0,0,0) )
	
	local label = vgui.Create("DLabel", pnl)
	label:Dock(LEFT)
	label:SetSize(400,0)
	label:DockMargin(2,0,0,0)
	label:SetFont("HudHintTextLarge")
	if (!l) then
		label:SetText(PHX:FTranslate("SUBTYPE_PREFERED_LANG"))
	else
		label:SetText(PHX:QTrans(l))
	end
	
	local cbox = vgui.Create("DComboBox", pnl)
	cbox:Dock(LEFT)
	cbox:SetSize(180 , 0)
	cbox:DockMargin(4,2,0,2)
	
	local btn = vgui.Create("DButton", pnl)
	btn:Dock(LEFT)
	btn:SetSize(64,0)
	btn:DockMargin(4,2,0,2)
	btn:SetText("Apply")
	btn:SetDisabled(true)
	
	function btn:DoClick()
		if cbox.selLang ~= "" and cbox.selLangName ~= "" then
			if (d) then
				-- Is Serverside?
				net.Start("SvCommandLang")
				net.WriteString(cbox.selLang)
				net.WriteString(c)
				net.SendToServer()
				CvarChangedMessage(c, cbox.selLang)
				ConfirmMessage(c, cbox.selLang)
			else
				-- because this is for client, force this to use ph_cl_language.
				RunConsoleCommand("ph_cl_language", cbox.selLang)
				chat.AddText( Color(60,220,30), PHX:Translate( "LANGUAGE_CHANGED", cbox.selLangName ) )
				print("[PHX] Prefered Language has changed to " .. cbox.selLangName )
				if PHX.UI.MainForm:IsValid() then PHX.UI.MainForm:Close() end
			end
			
		end
	end
	
	cbox.selLang = ""
	cbox.selLangName = ""
	
	local cvlang = "en_us"
	if (d) then
		cvlang = GetConVar(c):GetString()
	else
		cvlang = PHX:GetCLCVar( "ph_cl_language" )
	end
	
	local langCode = cvlang
	local langList = PHX.LANGUAGES
	
	if (!table.IsEmpty(langList[langCode])) then
		cbox:SetValue( langList[langCode].Name )
	else
		cbox:SetValue( "Error: Language " .. langCode .. " doesn't exists." )
	end
	
	for code,_ in pairs(langList) do
		cbox:AddChoice(langList[code].Name, langList[code].code)
	end
	
	function cbox:OnSelect(index, value, data)
		btn:SetDisabled(false)
		self.selLangName = value
		self.selLang 	 = data
	end
	
	return pnl
end,

-- This will translated in future version.
["textentry"] = function( c, d, p, l )
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(p:GetColWide() * 0.85,p:GetRowHeight())
	pnl:SetBackgroundColor( Color(0,0,0,0) )
	
	local label = vgui.Create("DLabel", pnl)
	label:Dock(LEFT)
	label:SetSize(pnl:GetWide()*0.6,0)
	label:DockMargin(2,0,0,0)
	label:SetFont("HudHintTextLarge")
	label:SetText(PHX:QTrans(l))
	
	local textEntry = vgui.Create("DTextEntry", pnl)
    local cvar = GetConVar(c):GetString()
	textEntry:Dock(LEFT)
	textEntry:SetSize(pnl:GetWide()*0.25, 0)
	textEntry:DockMargin(4,2,0,2)
    -- hack: Hexadecimal color values will ignores '#', i think this was intentional by gmod.
    if util.IsHexColor( cvar ) then
        textEntry:SetValue( "#" .. cvar )
    else
        textEntry:SetValue( GetConVar(c):GetString() )
    end
    textEntry:SetToolTip(PHX:QTrans(l))
	
	local btn = vgui.Create("DButton", pnl)
	btn:Dock(LEFT)
	btn:SetSize(64,0)
	btn:DockMargin(4,2,0,2)
	btn:SetText(PHX:QTrans("MISC_SET")) --btn:SetText("Set")
	
	textEntry.EnteredText = ""
	
	function textEntry:OnEnter()
		-- avoid using backslash for ph_fc_cue_path
		local properText = string.Replace(self:GetValue(), "\\", "/")
        
        -- Hack: Hexadecimal colors
        if util.IsHexColor( properText ) then
            self:SetText( "#" .. properText )
        else
            self:SetText( properText )
        end
        self.EnteredText = properText
	end
	
	function btn:DoClick()
		if textEntry.EnteredText ~= "" then
			if d == "SERVER" then
				net.Start("SvCommandTextEntry")
				net.WriteString(textEntry.EnteredText)
				net.WriteString(c)
				net.SendToServer()
			else
				RunConsoleCommand(c, textEntry.EnteredText)
			end
			ConfirmMessage(c, textEntry.EnteredText)
			CvarChangedMessage(c, textEntry.EnteredText)
		else
			PHX:MsgBox("PHXM_MSG_INPUT_IS_EMPTY", "MISC_WARN", "MISC_OK")
		end
	end
	
	return pnl
end,

-- todo: Add Customisable Combo Box in future version
    -- todo: not yet

-- Add More here :)
}