-- Living Survivor Mod
-- Displays contextual survivor thoughts above the character
-- Build 42.13.2

-- Referencia al jugador
local player = nil

-- Traducciones activas para el idioma actual
local currentTranslations = nil

-- Estados anteriores de todos los moodles para detectar cambios
local previousMoodleLevels = {}

-- Definición de claves para cada moodle
local moodleThoughtKeys = {
    ["Endurance"] = {
        [1] = {"Endurance_1_1", "Endurance_1_2", "Endurance_1_3"},
        [2] = {"Endurance_2_1", "Endurance_2_2", "Endurance_2_3"},
        [3] = {"Endurance_3_1", "Endurance_3_2", "Endurance_3_3"},
        [4] = {"Endurance_4_1", "Endurance_4_2", "Endurance_4_3"}
    },
    ["HeavyLoad"] = {
        [1] = {"HeavyLoad_1_1", "HeavyLoad_1_2", "HeavyLoad_1_3"},
        [2] = {"HeavyLoad_2_1", "HeavyLoad_2_2", "HeavyLoad_2_3"},
        [3] = {"HeavyLoad_3_1", "HeavyLoad_3_2", "HeavyLoad_3_3"},
        [4] = {"HeavyLoad_4_1", "HeavyLoad_4_2", "HeavyLoad_4_3"}
    },
    ["Angry"] = {
        [1] = {"Angry_1_1", "Angry_1_2", "Angry_1_3"},
        [2] = {"Angry_2_1", "Angry_2_2", "Angry_2_3"},
        [3] = {"Angry_3_1", "Angry_3_2", "Angry_3_3"},
        [4] = {"Angry_4_1", "Angry_4_2", "Angry_4_3"}
    },
    ["Stress"] = {
        [1] = {"Stress_1_1", "Stress_1_2", "Stress_1_3"},
        [2] = {"Stress_2_1", "Stress_2_2", "Stress_2_3"},
        [3] = {"Stress_3_1", "Stress_3_2", "Stress_3_3"},
        [4] = {"Stress_4_1", "Stress_4_2", "Stress_4_3"}
    },
    ["Thirst"] = {
        [1] = {"Thirst_1_1", "Thirst_1_2", "Thirst_1_3"},
        [2] = {"Thirst_2_1", "Thirst_2_2", "Thirst_2_3"},
        [3] = {"Thirst_3_1", "Thirst_3_2", "Thirst_3_3"},
        [4] = {"Thirst_4_1", "Thirst_4_2", "Thirst_4_3"}
    },
    ["Tired"] = {
        [1] = {"Tired_1_1", "Tired_1_2", "Tired_1_3"},
        [2] = {"Tired_2_1", "Tired_2_2", "Tired_2_3"},
        [3] = {"Tired_3_1", "Tired_3_2", "Tired_3_3"},
        [4] = {"Tired_4_1", "Tired_4_2", "Tired_4_3"}
    },
    ["Hungry"] = {
        [1] = {"Hungry_1_1", "Hungry_1_2", "Hungry_1_3"},
        [2] = {"Hungry_2_1", "Hungry_2_2", "Hungry_2_3"},
        [3] = {"Hungry_3_1", "Hungry_3_2", "Hungry_3_3"},
        [4] = {"Hungry_4_1", "Hungry_4_2", "Hungry_4_3"}
    },
    ["Panic"] = {
        [1] = {"Panic_1_1", "Panic_1_2"},
        [2] = {"Panic_2_1", "Panic_2_2", "Panic_2_3"},
        [3] = {"Panic_3_1", "Panic_3_2", "Panic_3_3"},
        [4] = {"Panic_4_1", "Panic_4_2", "Panic_4_3"}
    },
    ["Sick"] = {
        [1] = {"Sick_1_1", "Sick_1_2", "Sick_1_3"},
        [2] = {"Sick_2_1", "Sick_2_2", "Sick_2_3"},
        [3] = {"Sick_3_1", "Sick_3_2", "Sick_3_3"},
        [4] = {"Sick_4_1", "Sick_4_2", "Sick_4_3"}
    },
    ["Bored"] = {
        [1] = {"Bored_1_1", "Bored_1_2", "Bored_1_3"},
        [2] = {"Bored_2_1", "Bored_2_2", "Bored_2_3"},
        [3] = {"Bored_3_1", "Bored_3_2", "Bored_3_3"},
        [4] = {"Bored_4_1", "Bored_4_2", "Bored_4_3"}
    },
    ["Unhappy"] = {
        [1] = {"Unhappy_1_1", "Unhappy_1_2", "Unhappy_1_3"},
        [2] = {"Unhappy_2_1", "Unhappy_2_2", "Unhappy_2_3"},
        [3] = {"Unhappy_3_1", "Unhappy_3_2", "Unhappy_3_3"},
        [4] = {"Unhappy_4_1", "Unhappy_4_2", "Unhappy_4_3"}
    },
    ["Bleeding"] = {
        [1] = {"Bleeding_1_1", "Bleeding_1_2", "Bleeding_1_3"},
        [2] = {"Bleeding_2_1", "Bleeding_2_2", "Bleeding_2_3"},
        [3] = {"Bleeding_3_1", "Bleeding_3_2", "Bleeding_3_3"},
        [4] = {"Bleeding_4_1", "Bleeding_4_2", "Bleeding_4_3"}
    },
    ["Wet"] = {
        [1] = {"Wet_1_1", "Wet_1_2", "Wet_1_3"},
        [2] = {"Wet_2_1", "Wet_2_2", "Wet_2_3"},
        [3] = {"Wet_3_1", "Wet_3_2", "Wet_3_3"},
        [4] = {"Wet_4_1", "Wet_4_2", "Wet_4_3"}
    },
    ["HasACold"] = {
        [1] = {"HasACold_1_1", "HasACold_1_2", "HasACold_1_3"},
        [2] = {"HasACold_2_1", "HasACold_2_2", "HasACold_2_3"},
        [3] = {"HasACold_3_1", "HasACold_3_2", "HasACold_3_3"},
        [4] = {"HasACold_4_1", "HasACold_4_2", "HasACold_4_3"}
    },
    ["Injured"] = {
        [1] = {"Injured_1_1", "Injured_1_2", "Injured_1_3"},
        [2] = {"Injured_2_1", "Injured_2_2", "Injured_2_3"},
        [3] = {"Injured_3_1", "Injured_3_2", "Injured_3_3"},
        [4] = {"Injured_4_1", "Injured_4_2", "Injured_4_3"}
    },
    ["Pain"] = {
        [1] = {"Pain_1_1", "Pain_1_2", "Pain_1_3"},
        [2] = {"Pain_2_1", "Pain_2_2", "Pain_2_3"},
        [3] = {"Pain_3_1", "Pain_3_2", "Pain_3_3"},
        [4] = {"Pain_4_1", "Pain_4_2", "Pain_4_3"}
    },
    ["Drunk"] = {
        [1] = {"Drunk_1_1", "Drunk_1_2", "Drunk_1_3"},
        [2] = {"Drunk_2_1", "Drunk_2_2", "Drunk_2_3"},
        [3] = {"Drunk_3_1", "Drunk_3_2", "Drunk_3_3"},
        [4] = {"Drunk_4_1", "Drunk_4_2", "Drunk_4_3"}
    },
    ["FoodEaten"] = {
        [1] = {"FoodEaten_1_1", "FoodEaten_1_2"},
        [2] = {"FoodEaten_2_1", "FoodEaten_2_2", "FoodEaten_2_3"},
        [3] = {"FoodEaten_3_1", "FoodEaten_3_2", "FoodEaten_3_3"},
        [4] = {"FoodEaten_4_1", "FoodEaten_4_2", "FoodEaten_4_3"}
    },
    ["Hyperthermia"] = {
        [1] = {"Hyperthermia_1_1", "Hyperthermia_1_2", "Hyperthermia_1_3"},
        [2] = {"Hyperthermia_2_1", "Hyperthermia_2_2", "Hyperthermia_2_3"},
        [3] = {"Hyperthermia_3_1", "Hyperthermia_3_2", "Hyperthermia_3_3"},
        [4] = {"Hyperthermia_4_1", "Hyperthermia_4_2", "Hyperthermia_4_3"}
    },
    ["Hypothermia"] = {
        [1] = {"Hypothermia_1_1", "Hypothermia_1_2", "Hypothermia_1_3"},
        [2] = {"Hypothermia_2_1", "Hypothermia_2_2", "Hypothermia_2_3"},
        [3] = {"Hypothermia_3_1", "Hypothermia_3_2", "Hypothermia_3_3"},
        [4] = {"Hypothermia_4_1", "Hypothermia_4_2", "Hypothermia_4_3"}
    },
    ["Uncomfortable"] = {
        [1] = {"Uncomfortable_1_1", "Uncomfortable_1_2", "Uncomfortable_1_3"},
        [2] = {"Uncomfortable_2_1", "Uncomfortable_2_2", "Uncomfortable_2_3"},
        [3] = {"Uncomfortable_3_1", "Uncomfortable_3_2", "Uncomfortable_3_3"},
        [4] = {"Uncomfortable_4_1", "Uncomfortable_4_2", "Uncomfortable_4_3"}
    },
    ["NoxiousSmell"] = {
        [1] = {"NoxiousSmell_1_1", "NoxiousSmell_1_2", "NoxiousSmell_1_3"},
        [2] = {"NoxiousSmell_2_1", "NoxiousSmell_2_2", "NoxiousSmell_2_3"},
        [3] = {"NoxiousSmell_3_1", "NoxiousSmell_3_2", "NoxiousSmell_3_3"},
        [4] = {"NoxiousSmell_4_1", "NoxiousSmell_4_2", "NoxiousSmell_4_3"}
    }
}

-- Función para mostrar un pensamiento sobre el personaje
local function showThought(text)
    if not player then return end
    player:Say(text)
end

-- Función para obtener el nivel de un moodle específico
local function getMoodleLevel(moodleName)
    if not player then return 0 end
    
    local moodles = player:getMoodles()
    if not moodles then return 0 end
    
    local moodlesValuesForType = Registries.MOODLE_TYPE:values()
    local numMoodles = moodlesValuesForType:size()
    
    for i = 0, numMoodles - 1 do
        local moodleType = moodlesValuesForType:get(i)
        local moodleTranslationName = moodleType:getTranslationName()
        
        if moodleTranslationName == moodleName then
            local level = moodles:getMoodleLevel(moodleType)
            return level or 0
        end
    end
    
    return 0
end

-- Función que se ejecuta cada tick del juego
local function onPlayerUpdate()
    if not player or not player:isAlive() then return end
    
    -- Revisar cada moodle
    for moodleName, thoughtKeys in pairs(moodleThoughtKeys) do
        local currentLevel = getMoodleLevel(moodleName)
        local previousLevel = previousMoodleLevels[moodleName] or 0
        
        -- Solo mostrar pensamiento si el nivel SUBE (no cuando baja)
        if currentLevel > previousLevel and currentLevel > 0 then
            local levelKeys = thoughtKeys[currentLevel]
            if levelKeys and #levelKeys > 0 then
                -- Seleccionar clave aleatoria del grado actual
                local randomKey = levelKeys[ZombRand(#levelKeys) + 1]
                
                -- Obtener texto traducido desde la tabla de idioma
                local thoughtText = currentTranslations[randomKey] or randomKey
                
                showThought(thoughtText)
            end
        end
        
        -- Actualizar el nivel anterior
        previousMoodleLevels[moodleName] = currentLevel
    end
end

-- Función de prueba manual (mantener tecla º)
local function onKeyPressed(key)
    if key == 41 then
        if player and player:isAlive() then
            print("=== Living Survivor Debug ===")
            for moodleName, _ in pairs(moodleThoughtKeys) do
                local level = getMoodleLevel(moodleName)
                if level > 0 then
                    print(moodleName .. ": Nivel " .. level)
                end
            end
            print("============================")
        end
    end
end

-- Función que se ejecuta al iniciar el juego
local function onGameStart()
    player = getPlayer()
    previousMoodleLevels = {} -- Reset al iniciar

    -- Detectar idioma del juego y cargar traducciones
    local lang = "EN"
    if Translator and Translator.getLanguage then
        local ok, result = pcall(function()
            return tostring(Translator.getLanguage():name())
        end)
        if ok and result then lang = result end
    end
    currentTranslations = LivingSurvivorLang[lang] or LivingSurvivorLang["EN"]

    -- Contar moodles
    local moodleCount = 0
    for _ in pairs(moodleThoughtKeys) do
        moodleCount = moodleCount + 1
    end

    print("Living Survivor: Mod cargado correctamente")
    print("Living Survivor: Idioma detectado: " .. lang)
    print("Living Survivor: Detectando " .. moodleCount .. " moodles")
    print("Living Survivor: Pulsa º para ver moodles activos")
end

-- Registrar eventos
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnKeyPressed.Add(onKeyPressed)
Events.OnGameStart.Add(onGameStart)

print("Living Survivor mod loaded successfully!")