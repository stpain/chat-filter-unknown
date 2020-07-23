

local addonName, CFU = ...

CFU.FONT_COLOUR = '|cffA330C9'
CFU.PlayerMixin = nil
CFU.ContextMenu = {}
CFU.ContextMenu_Separator = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"
CFU.ContextMenu_DropDown = CreateFrame("Frame", "ChatFilterUnknownContextMenuDropDown", UIParent, "UIDropDownMenuTemplate")

CFU.Loaded = false

--- create a custom frame for the merchant dropdown menu item level slider
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
    CFU.ContextMenu_FiltersMenuList = {
        { text='|cffffffffShift|r click to remove filter', isTitle=true, notCheckable=true, }
    }
    if CHATFILTERUNKNOWN_GLOBAL and CHATFILTERUNKNOWN_GLOBAL.Characters and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')] and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters then        
        for k, v in pairs(CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters) do
            table.insert(CFU.ContextMenu_FiltersMenuList, {
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
    CFU.ContextMenu_ChannelMenuList = {
        { text = 'Say', keepShownOnClick=true, checked=CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['SAY'], func=function(self)
            CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['SAY'] = self.checked
            if self.checked == true then
                ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CFU.ChatFilter)
                print('added filters to \'say\' messages')
            else
                ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", CFU.ChatFilter)
                print('aremoved filters to \'say\' messages')
            end
        end, },
        { text = 'Yell', keepShownOnClick=true, checked=CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['YELL'], func=function(self)
            CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['YELL'] = self.checked
            if self.checked == true then
                ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CFU.ChatFilter)
                print('added filters to \'yell\' messages')
            else
                ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", CFU.ChatFilter)
                print('aremoved filters to \'yell\' messages')
            end
        end, },
        { text = 'Whisper', keepShownOnClick=true, checked=CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['WHISPER'], func=function(self)
            CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['WHISPER'] = self.checked
            if self.checked == true then
                ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CFU.ChatFilter)
                print('added filters to \'whipser\' messages')
            else
                ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", CFU.ChatFilter)
                print('aremoved filters to \'whipser\' messages')
            end
        end, }
    }
    CFU.ContextMenu = {
        { text = 'Chat Filter Unknown', isTitle=true, notCheckable=true },
        { text = 'Edit Filters', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_FiltersMenuList },
        { text = 'Add Filters', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_AddFilterMenuList },
        { text = 'Select channel', notCheckable=true, hasArrow=true, menuList=CFU.ContextMenu_ChannelMenuList },
    }
end

function CFU.Init()
    if not CHATFILTERUNKNOWN_GLOBAL then 
        CHATFILTERUNKNOWN_GLOBAL = {
            AddonName = addonName,
            Characters = {},
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
        menuButton:SetSize(24,24)
        menuButton:SetNormalTexture(389193)
        menuButton:SetPushedTexture(389192)
        menuButton:RegisterForClicks('LeftButtonUp')
        menuButton:SetScript('OnClick', function(self, button)
            CFU.GenerateContextMenu()
            EasyMenu(CFU.ContextMenu, CFU.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
        end)
        if CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['SAY'] == true then
            ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CFU.ChatFilter)
        end
        if CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['YELL'] == true then
            ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CFU.ChatFilter)
        end
        if CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Channels['WHISPER'] == true then
            ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CFU.ChatFilter)
        end
		CFU.Loaded = true
        print('loaded successfully!')
    else
        print('not loaded')
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
    --local addSender = false
    if CHATFILTERUNKNOWN_GLOBAL and CHATFILTERUNKNOWN_GLOBAL.Characters and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')] and CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters then
        for k, v in pairs(CHATFILTERUNKNOWN_GLOBAL.Characters[UnitGUID('player')].Filters) do
            if msg:lower():find(tostring(k):lower()) then
                -- table.insert(CFU.ChatFilter, {
                --     Sender = sender,
                --     Message = msg,
                --     GUID = guid,
                -- })
                --addSender = true
                return v
            end
        end
    end
    -- if addSender == true then
    --     print('added', sender, 'to filter')
    -- end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CFU.ChatFilter)
