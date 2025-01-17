local LANG = {}

-- English Section
LANG["ru"]   = {
    -- setting menu
    ["LPS_GENERAL_SETTINGS"]    = "Общие настройки",
    ["LPS_APPEARANCES"]         = "Внешний вид",
    ["LPS_WEAPON_SETTINGS"]     = "Настройки оружия последнего объекта",
    
    ["LPS_MENU_ENABLE"]         = "Включить оружие последнему объекту",
	["LPS_ENABLE_MUSIC"]		= "Включить музыку при последнем объекте. Для вступления в силу требуется перезагрузка раунда.",
    ["LPS_WEAPON_SELECT"]       = "Оружие, которое нужно дать («случайное» или «именное»). См. список оружия ниже.",
    ["LPS_BTN_WEPLIST"]         = "Список доступного оружия",
    ["LPS_MINIMUM_PROPS_TEAM"]  = "Минимальное количество объектов в команде до срабатывания последнего объекта. Минимум: 2.",
    
    ["LPS_WEPLIST"]             = "Список доступного оружия:\n%s\nВы можете использовать 'lps_weapon_list' в консоли.",
    
	["LPS_SHOW_WEAPON"]			= "Сделать видимым оружие последнему объекту", --Todo: Fix Me
    ["LPS_HALO_ENABLE"]         = "Отображать эффект контура вокруг последнего объекта?",
    ["LPS_HALO_SEETHROUGHWALL"] = "Отображать эффект контура через стены?",
    ["LPS_HALO_COLOUR"]         = "Цвет для эффекта контура последнего объекта («радуга» или шестнадцатеричный код)",
    ["LPS_TRAILS_ENABLE"]       = "Отображать след за последним объектом-игроком?",
    ["LPS_TRAILS_COLOUR"]       = "Цвет для следа последнего объекта (шестнадцатеричный код)",
    ["LPS_TRAIL_TEXTURE"]       = "Текстура цвета следа для последнего объекта-игрока",
    
    ["LPS_PLAY_MUSIC"]          = "Воспроизведение фоновой музыки при начале события последнего объекта. (Применяется только для следующей музыки)",
    ["LPS_CL_DRAW_HALO"]        = "(На стороне клиента) Показать/скрыть контур, даже если сервер скрыл его.",
    
    -- Internal: Weapon Settings
    ["LPS_WEPSET_REV_AMMO"]     = "Револьверные патроны (Событие: Последний объект). -1=Бесконечно.",
    ["LPS_WEPSET_SMG_AMMO"]     = "Патроны пистолета-пулемёта (Событие: Последний объект). -1=Бесконечно.",
    
    ["LPS_WEPSET_DAMAGE_REV"]   = "Урон револьвера (Событие: Последний объект)",
    ["LPS_WEPSET_DAMAGE_SMG"]   = "Урон пистолета-пулемёта (Событие: Последний объект)",
    ["LPS_WEPSET_DAMAGE_BLAST"] = "Урон от взрыва (Событие: Последний объект)",
    
    -- More into stuff now.
    ["LASTPROP_ANNOUNCE"]       = "Вы последний оставшийся объект!",
    ["LASTPROP_ANNOUNCE_ALL"]   = "Последний оставшийся объект ещё сопротивляется!",
    
    -- Weapon State
    ["WEAPON_STATE_READY"]      = "Готово",
    ["WEAPON_STATE_RELOAD"]     = "Перезарядка...",
    ["WEAPON_STATE_OUTOFAMMO"]  = "Нет патронов",
    ["WEAPON_STATE_UNARMED"]    = "Нет оружия",
    
    ["WEAPON_AMMO_UNLI"]        = "Бесконечно"
}

list.Set("PHX.LanguageInsertion", "[LastPropStanding] Russian", LANG)