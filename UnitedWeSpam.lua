-- Written by Kynetix @ Kil'Jaeden-US Alliance

--channel owner displays message - DisplayChannelOwner()

local isOn
local isTimerOn = "false";
local isOwner = "false"; 
local total = 0;
local spamMessage = "NOTHING";
local messageStart
local guildName
local playerName = UnitName("player");
local number

function UnitedWeSpam_OnLoad(this)
	SLASH_UNITEDWESPAM1= "/uws";
	SlashCmdList["UNITEDWESPAM"] = UnitedWeSpam_CommandParse;	
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("PLAYER_LOGOUT");	
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	this:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
	this:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE_USER");
end

function UnitedWeSpam_OnEvent(this, event, ...)
	if (event=="PLAYER_LOGIN") then
		if (UWSOn == nil) then
			UWSOn = true
		end
		if (UWSTimer == nil) then
			UWSTimer = 90
		end
		UnitedWeSpam_Hello();
		GuildRoster();		
	end
	
	if (event=="PLAYER_LOGOUT") then
		UWSOn = UWSOn;		
		this:UnregisterEvent("PLAYER_LOGIN");
		this:UnregisterEvent("PLAYER_LOGOUT");
		this:UnregisterEvent("GUILD_ROSTER_UPDATE");
		this:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE");
		this:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE_USER");
	end
	
	if (event=="GUILD_ROSTER_UPDATE") then
		guildName = GetGuildInfo("player");	
		spamMessage = GetGuildInfoText();
		messageStart = strfind(spamMessage, "UWS:");		
		if(messageStart ~= nil) then
			spamMessage = strsub(spamMessage, messageStart + 4);
			--UnitedWeSpam_Message('United We Spam set to: '..spamMessage);
			--this:UnregisterEvent("GUILD_ROSTER_UPDATE");
		end
	end
	
	local channelMessage, _, _, _, _, _, _, _, channelName, _, _ = select(1, ...)
	
	if (event=="CHAT_MSG_CHANNEL_NOTICE" and isOn == "ON") then
		if (channelName == "Trade - City" and channelMessage == "YOU_JOINED") then
			JoinPermanentChannel('UWS'..guildName, nil, 1, 0);
			SetChannelOwner('UWS'..guildName, playerName);
			isTimerOn = "true";	
		elseif (channelName == "Trade - City" and channelMessage == "SUSPENDED") then
			LeaveChannelByName('UWS'..guildName);
			isTimerOn = "false";
			isOwner = "false";
		end	
	end
	
	local channelMessage1, sender, _, _, target, _, _, _, channelName1, _, _ = select(1, ...)
	
	if (event =="CHAT_MSG_CHANNEL_NOTICE_USER" and isOn == "ON") then
	channel, channelName, instanceID = GetChannelName("UWS"..guildName)
		if(channelMessage1 == "OWNER_CHANGED" and channelName1 == channelName and playerName == sender) then
			isOwner = "true";			
		end		
	end	
end

local function UnitedWeSpam_OnUpdate(self, elapsed)
	total = total + elapsed
	
    if (total >= UWSTimer) then
		
		if(isTimerOn == "true" and isOwner == "true" and isOn == "ON") then
			SendChatMessage(spamMessage,"CHANNEL",nil,GetChannelName("Trade - City"))
		end
		GuildRoster();
        total = 0
	end
end

local f = CreateFrame("frame")
f:SetScript("OnUpdate", UnitedWeSpam_OnUpdate)

function UnitedWeSpam_Hello()
	if (UWSOn == true) then
		isOn = "ON"
	elseif (UWSOn == false) then
		isOn = "OFF"
	end
	UnitedWeSpam_Message('United We Spam by Kynetix <Refraction> of Kil\'Jaeden Alliance-US');
	UnitedWeSpam_Message('Type "/uws help" for... help.');
	UnitedWeSpam_Message('United We Spam is '..isOn);	
end

function UnitedWeSpam_Message(message)
	DEFAULT_CHAT_FRAME:AddMessage("[UnitedWeSpam] " .. message, .65, .65, .65);
end

function UnitedWeSpam_CommandParse(parameterstring)
	local command = nil;
	command=string.lower(parameterstring);
	number = strfind(command, "timer")
		
	if (command == 'off') then
		UWSOn = false
		isOn = "OFF"
		LeaveChannelByName('UWS'..guildName);
		JoinPermanentChannel('UWS'..guildName, nil, 1, 0);
		UnitedWeSpam_Message('United We Spam is '..isOn);
	elseif (command == 'on') then
		UWSOn = true
		isOn = "ON"
		isTimerOn = "true"
		SetChannelOwner('UWS'..guildName, playerName);
		UnitedWeSpam_Message('United We Spam is '..isOn);
	elseif (command == 'test') then
		UnitedWeSpam_Message(isOwner..' '..isTimerOn..' '..isOn);
	elseif (command == 'message') then
		UnitedWeSpam_Message('United We Spam set to: '..spamMessage);
	elseif (number ~= nil) then
		UWSTimer = tonumber(strsub(command, number + 6));
		if(UWSTimer == nil or UWSTimer < 0) then
			UWSTimer = 90;
		end
		UnitedWeSpam_Message('United We Spam set to: '..UWSTimer);
	else
		UnitedWeSpam_Message('UWS commands include /uws on, /uws off, and /uws message')
	end

end