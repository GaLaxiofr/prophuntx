local LANG = {}

-- English Section
LANG["zh-TW"]   = {
    -- setting menu
    ["LPS_GENERAL_SETTINGS"]    = "常規設置",
    ["LPS_APPEARANCES"]         = "外觀",
    ["LPS_WEAPON_SETTINGS"]     = "最後一物武器設置",
    
    ["LPS_MENU_ENABLE"]         = "啟用最後一物",
	["LPS_ENABLE_MUSIC"]		= "最後一物時啟用音樂. 需要重開一輪來生效.",
    ["LPS_WEAPON_SELECT"]       = "給予武器 ('random' 或 'name'). 查看下麵的武器列表.",
    ["LPS_BTN_WEPLIST"]         = "可用武器列表",
    ["LPS_MINIMUM_PROPS_TEAM"]  = "最後一物觸發前所需的最少物品隊人數. 最小: 2.",
    
    ["LPS_WEPLIST"]             = "可用武器列表:\n%s\n你可以在控制台使用 'lps_weapon_list' 命令.",
    
	["LPS_SHOW_WEAPON"]			= "使最後一物武器可見", --Todo: Fix Me
    ["LPS_HALO_ENABLE"]         = "在最後一物周圍繪制光暈?",
    ["LPS_HALO_SEETHROUGHWALL"] = "光暈效果穿牆?",
    ["LPS_HALO_COLOUR"]         = "最後一物光暈效果顏色 ('rainbow' 或十六進制色碼)",
    ["LPS_TRAILS_ENABLE"]       = "在最後一物玩家身後繪制尾跡?",
    ["LPS_TRAILS_COLOUR"]       = "最後一物尾跡顏色 (十六進制色碼)",
    ["LPS_TRAIL_TEXTURE"]       = "最後一物玩家尾跡顏色材質",
    
    ["LPS_PLAY_MUSIC"]          = "當最後一物事件開始時播放背景音樂. (只適用於下一曲)",
    ["LPS_CL_DRAW_HALO"]        = "(客戶端) 展示/隱藏光暈, 即便伺服器啟用.",
    
    -- Internal: Weapon Settings
    ["LPS_WEPSET_REV_AMMO"]     = "最後一物左輪彈藥. -1=無限制.",
    ["LPS_WEPSET_SMG_AMMO"]     = "最後一物沖鋒槍彈藥. -1=無限制.",
    
    ["LPS_WEPSET_DAMAGE_REV"]   = "最後一物左輪傷害",
    ["LPS_WEPSET_DAMAGE_SMG"]   = "最後一物沖鋒槍傷害",
    ["LPS_WEPSET_DAMAGE_BLAST"] = "最後一物爆炸傷害",
    
    -- More into stuff now.
    ["LASTPROP_ANNOUNCE"]       = "你是最後一物!",
    ["LASTPROP_ANNOUNCE_ALL"]   = "最後一物正在負隅頑抗!",
    
    -- Weapon State
    ["WEAPON_STATE_READY"]      = "就緒",
    ["WEAPON_STATE_RELOAD"]     = "裝彈中...",
    ["WEAPON_STATE_OUTOFAMMO"]  = "彈藥耗盡",
    ["WEAPON_STATE_UNARMED"]    = "沒有武器",
    
    ["WEAPON_AMMO_UNLI"]        = "無限"
}

list.Set("PHX.LanguageInsertion", "[LastPropStanding] Chinese Traditional", LANG)