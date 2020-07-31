--[[
    chat filter unknown
]]

local addonName, CFU = ...

CFU.FONT_COLOUR = '|cffA330C9'
CFU.PlayerMixin = nil
CFU.ContextMenu = {}
CFU.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
CFU.ContextMenu_DropDown = CreateFrame("Frame", "ChatFilterUnknownContextMenuDropDown", UIParent, "UIDropDownMenuTemplate")

CFU.Loaded = false

CFU.ContextMenu_CustomFrame_NewPhrase = CreateFrame('FRAME', 'CFU_ContextMenu_NewPhrase', UIParent, 'UIDropDownCustomMenuEntryTemplate')
CFU.ContextMenu_CustomFrame_NewPhrase:SetSize(150, 16)

CFU.ContextMenu_CustomFrame_NewPhrase.editbox = CreateFrame('EditBox', 'CFU_ContextMenu_NewPhrase_Editbox', CFU.ContextMenu_CustomFrame_NewPhrase, "InputBoxTemplate")
CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetFontObject('GameFontNormal')
CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetPoint('LEFT', 10, 0)
CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetPoint('RIGHT', -28, 0)
CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetSize(100, 16)
CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetText('Filter phrase')

CFU.ContextMenu_CustomFrame_NewPhrase.button = CreateFrame("BUTTON", "CFU_ContextMenu_NewPhrase_Button", CFU.ContextMenu_CustomFrame_NewPhrase)
CFU.ContextMenu_CustomFrame_NewPhrase.button:SetPoint('RIGHT', -2, 0)
CFU.ContextMenu_CustomFrame_NewPhrase.button:SetNormalTexture(130866)
CFU.ContextMenu_CustomFrame_NewPhrase.button:SetPushedTexture(130865)
CFU.ContextMenu_CustomFrame_NewPhrase.button:EnableMouse(true)
CFU.ContextMenu_CustomFrame_NewPhrase.button:RegisterForClicks('LeftButtonUp')
CFU.ContextMenu_CustomFrame_NewPhrase.button:SetSize(20,20)
CFU.ContextMenu_CustomFrame_NewPhrase.button:SetScript('OnClick', function(self)
    if CHATFILTERUNKNOWN_GLOBAL and CHATFILTERUNKNOWN_GLOBAL.Characters and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')] and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters then
        if CFU.ContextMenu_CustomFrame_NewPhrase.editbox:GetText() then
            CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters[tostring(CFU.ContextMenu_CustomFrame_NewPhrase.editbox:GetText())] = true
            CFU.ContextMenu_CustomFrame_NewPhrase.editbox:SetText('')
        end
    end
    CloseDropDownMenus()
end)

function CFU.GenerateContextMenu()
    CFU.ContextMenu_RemoveFilterMenuList = {
        { text='|cffffffffShift|r click to remove filter', isTitle=true, notCheckable=true, }
    }
    if CHATFILTERUNKNOWN_GLOBAL and CHATFILTERUNKNOWN_GLOBAL.Characters and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')] and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters then        
        for k, v in pairs(CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters) do
            table.insert(CFU.ContextMenu_RemoveFilterMenuList, {
                text=tostring(k),
                checked=v,
                keepShownOnClick=true,
                func=function(self)
                    if not IsShiftKeyDown() then
                        CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters[k] = not CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters[k]
                        self.checked = CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters[k]
                    elseif IsShiftKeyDown() then
                        CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters[k] = nil
                    end
                end,
            })
        end
    end
    CFU.ContextMenu_AddFilterMenuList = {
        { text='Add filter', isTitle=true, notCheckable=true, },
        { text=' ', customFrame=CFU.ContextMenu_CustomFrame_NewPhrase, },
    }
    CFU.ContextMenu_ChannelMenuList = {}
    for k, v in pairs({'Say', 'Yell', 'Whisper'}) do
        table.insert(CFU.ContextMenu_ChannelMenuList, {
            text = v,
            keepShownOnClick=true,
            checked=CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels[v:upper()],
            func=function(self)
                CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels[v:upper()] = self.checked
                if self.checked == true then
                    ChatFrame_AddMessageEventFilter(tostring("CHAT_MSG_"..v:upper()), CFU.ChatFilter)
                else
                    ChatFrame_RemoveMessageEventFilter(tostring("CHAT_MSG_"..v:upper()), CFU.ChatFilter)
                end
            end,
        })
    end
    CFU.ContextMenu = {
        { text = 'Chat Filter Unknown', isTitle=true, notCheckable=true },
        { text = 'Add Filter', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_AddFilterMenuList },
        { text = 'Remove Filter', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_RemoveFilterMenuList },
        { text = 'Filter channel', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_ChannelMenuList },
    }
end

function CFU.Init()
    if not CHATFILTERUNKNOWN_GLOBAL then 
        CHATFILTERUNKNOWN_GLOBAL = {
            AddonName = addonName,
            Characters = {},
            FilteredCharacters = {},
        } 
    end
    local guid = UnitGUID('player')
    if guid then
        if not CHATFILTERUNKNOWN_GLOBAL.Characters[guid] then
            CHATFILTERUNKNOWN_GLOBAL.Characters[guid] = {
                Filters = {},
                Channels = {
                    ['SAY'] = true,
                    ['YELL'] = true,
                    ['WHISPER'] = true,
                },
            }
        end
        local menuButton = CreateFrame('BUTTON', 'CFU_MenuButton', QuickJoinToastButton)
        menuButton:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT', 0, 4)
        menuButton:SetPoint('TOPRIGHT', QuickJoinToastButton, 'TOPRIGHT', 0, 36)
        menuButton:SetNormalTexture(389193)
        menuButton:SetPushedTexture(389192)
        menuButton:RegisterForClicks('LeftButtonUp')
        menuButton:SetScript('OnClick', function(self, button)
            CFU.GenerateContextMenu()
            EasyMenu(CFU.ContextMenu, CFU.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
        end)
        for k, v in pairs({'Say', 'Yell', 'Whisper'}) do
            if CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels[v:upper()] == true then
                ChatFrame_AddMessageEventFilter(tostring("CHAT_MSG_"..v:upper()), CFU.ChatFilter)
            end
        end
		CFU.Loaded = true
    else
        CFU.Loaded = false
    end
end

CFU.EventFrame = CreateFrame('FRAME', 'ChatFilterUnknownEventFrame', UIParent)
CFU.EventFrame:RegisterEvent('ADDON_LOADED')
CFU.EventFrame:SetScript("OnEvent", function(self, event, ...)
    CFU.Events[event](CFU, ...)
end)

CFU.Events = {
    ['ADDON_LOADED'] = function(self, ...)
        if select(1, ...):lower() == "chatfilterunknown" then
            C_Timer.After(2, CFU.Init) --delay this to help ensure guid is ready
        end
    end,
}

function CFU.ChatFilter(self, event, ...)
    local msg = select(1, ...)
    local sender = select(2, ...)
    local guid = select(12, ...)
    if CHATFILTERUNKNOWN_GLOBAL and CHATFILTERUNKNOWN_GLOBAL.Characters and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')] and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters then
        for k, v in pairs(CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters) do
            if msg:lower():find(tostring(k):lower()) then
                if not CHATFILTERUNKNOWN_GLOBAL['FilteredCharacters'] then CHATFILTERUNKNOWN_GLOBAL['FilteredCharacters'] = {} end
                table.insert(CHATFILTERUNKNOWN_GLOBAL['FilteredCharacters'], {
                    Sender = sender,
                    Message = msg,
                    GUID = guid,
                    DateTime = GetServerTime(),
                })
                return v
            end
        end
    end
end

--- add this as a default setting, the point of the addon is to filter things out
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CFU.ChatFilter)