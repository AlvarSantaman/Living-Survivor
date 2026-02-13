-- Living Survivor Mod
-- Displays contextual survivor thoughts above the character
-- Build 42.13.2

-- Referencia al jugador
local player = nil

-- Estados anteriores de todos los moodles para detectar cambios
local previousMoodleLevels = {}

-- Cooldown para Panic nivel 1 (timestamp en segundos reales)
local panicLevel1LastTime = 0
local PANIC_LEVEL1_COOLDOWN = 10 -- segundos

-- Sistema de pensamientos iniciales (lockdown)
local startingThoughts = {
    ["Lockdown"] = {
        "Lockdown_1",
        "Lockdown_2",
        "Lockdown_3",
        "Lockdown_4"
    },
    ["Phone"] = {
        "Phone_1",
        "Phone_2",
        "Phone_3",
    },
    ["News"] = {
        "News_1",
        "News_2",
        "News_3",
        "News_4" 
    },
    ["Food"] = {
        "Food_1",
        "Food_2",
        "Food_3",
    },
    ["Neighbors"] = {
        "Neighbors_1",
        "Neighbors_2",
        "Neighbors_3",
        "Neighbors_4"
    }
}

local startingThoughtsActive = false
local thoughtsStarted = false
local gameStartTime = 0
local thoughtTimer = 0
local currentThoughtLine = nil
local currentThoughtIndex = 1
local initialBuilding = nil

local THOUGHT_START_DELAY = 10 -- segundos para empezar
local THOUGHT_INTERVAL = 6 -- segundos entre frases

-- Sistema de pensamientos "Outside" (al salir de casa)
local outsideThoughts = {
    "Outside_1",
    "Outside_2",
    "Outside_3",
    "Outside_4"
}

local outsideThoughtsState = "waiting" -- Estados: "waiting", "counting", "active", "completed", "cancelled"
local timeLeftInitialBuilding = 0
local outsideThoughtTimer = 0
local currentOutsideThoughtIndex = 1
local OUTSIDE_START_DELAY = 10 -- segundos fuera de casa para activar
local OUTSIDE_THOUGHT_INTERVAL = 6 -- segundos entre frases

-- Sistema de pensamientos "FirstPanic" (primer contacto con zombies)
local firstPanicThoughts = {
    "FirstPanic_1",
    "FirstPanic_2",
    "FirstPanic_3",
    "FirstPanic_4"
}

local firstPanicState = "waiting" -- Estados: "waiting", "active", "completed", "cancelled", "cooldown"
local firstPanicThoughtTimer = 0
local currentFirstPanicIndex = 1
local firstPanicCompletedTime = 0
local FIRST_PANIC_INTERVAL = 6 -- segundos entre frases
local FIRST_PANIC_COOLDOWN = 10 -- segundos después de completar antes de permitir pensamientos normales de Panic

-- Salud anterior para detectar ataques
local previousHealth = 100

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
        [1] = {"Panic_1_1", "Panic_1_2", "Panic_1_3"},
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

-- Definición de claves para pensamientos de lectura
local readingThoughtKeys = {
    ["SkillBook"] = {"SkillBook_1", "SkillBook_2", "SkillBook_3", "SkillBook_4"},
    ["RecipeBook"] = {"RecipeBook_1", "RecipeBook_2", "RecipeBook_3"},
    ["Novel"] = {"Novel_1", "Novel_2", "Novel_3", "Novel_4"}
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

-- Función para determinar el tipo de objeto de lectura
local function getReadingType(item)
    local fullType = item:getFullType()
    
    -- Excluir periódicos, Fliers y Brochures
    if fullType == "Base.Flier" or 
       fullType == "Base.Brochure" or 
       fullType:find("Newspaper") then
        return nil
    end
    
    -- Libros de habilidades
    if SkillBook[item:getSkillTrained()] then
        return "SkillBook"
    end
    
    -- Libros de recetas
    if item:getLearnedRecipes() and not item:getLearnedRecipes():isEmpty() then
        return "RecipeBook"
    end
    
    -- Novelas y libros con título
    local modData = item:getModData()
    if modData and (modData.literatureTitle or modData.printMedia) then
        return "Novel"
    end
    
    return nil
end

-- Función para mostrar pensamiento de lectura
local function showReadingThought(readingType)
    if not readingType or not readingThoughtKeys[readingType] then return end
    
    local keys = readingThoughtKeys[readingType]
    if #keys > 0 then
        local randomKey = keys[ZombRand(#keys) + 1]
        local thoughtText = getText("IGUI_LivingSurvivor_" .. randomKey)
        showThought(thoughtText)
    end
end

-- Verificar si el jugador está fuera del edificio inicial
local function isOutsideInitialBuilding()
    if not initialBuilding then return true end
    if not player then return true end
    
    local currentBuilding = player:getBuilding()
    return currentBuilding ~= initialBuilding
end

-- Verificar si un zombie puede ver al jugador
local function isSpottedByZombie()
    if not player then return false end
    
    local cell = player:getCell()
    if not cell then return false end
    
    local zombies = cell:getZombieList()
    if not zombies or zombies:size() == 0 then return false end
    
    for i = 0, zombies:size() - 1 do
        local zombie = zombies:get(i)
        if zombie and zombie:getTarget() == player then
            return true
        end
    end
    
    return false
end

-- Detectar si el jugador ha sido atacado (salud baja)
local function wasPlayerAttacked()
    if not player then return false end
    
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage then return false end
    
    local currentHealth = bodyDamage:getOverallBodyHealth()
    
    -- Si la salud bajó, fue atacado
    if currentHealth < previousHealth then
        previousHealth = currentHealth
        return true
    end
    
    previousHealth = currentHealth
    return false
end

-- Detener pensamientos iniciales (lockdown)
local function stopStartingThoughts(reason)
    if startingThoughtsActive then
        startingThoughtsActive = false
        print("Living Survivor: Starting thoughts stopped - " .. reason)
    end
end

-- Iniciar línea de pensamientos (lockdown)
local function startThoughtLine()
    -- Elegir línea aleatoria
    local lineNames = {"Lockdown", "Phone", "News", "Food", "Neighbors"}
    local randomLine = lineNames[ZombRand(#lineNames) + 1]
    
    currentThoughtLine = randomLine
    currentThoughtIndex = 1
    startingThoughtsActive = true
    thoughtsStarted = true
    
    print("Living Survivor: Starting thought line: " .. randomLine)
    
    -- Mostrar primer pensamiento inmediatamente
    local thoughtKey = startingThoughts[currentThoughtLine][currentThoughtIndex]
    showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
    
    currentThoughtIndex = currentThoughtIndex + 1
end

-- Procesar pensamientos iniciales (lockdown)
local function updateStartingThoughts()
    if not player or not player:isAlive() then return end
    
    local currentTime = os.time()
    
    -- Si no han empezado y han pasado 10 segundos, iniciar
    if not thoughtsStarted and (currentTime - gameStartTime >= THOUGHT_START_DELAY) then
        startThoughtLine()
        thoughtTimer = currentTime
        return
    end
    
    -- Si están activos, gestionar la secuencia
    if startingThoughtsActive then
        -- Verificar condiciones de parada
        if isOutsideInitialBuilding() then
            stopStartingThoughts("Left initial building")
            return
        end
        
        if isSpottedByZombie() then
            stopStartingThoughts("Spotted by zombie")
            return
        end
        
        -- Mostrar siguiente pensamiento cada 6 segundos
        if currentTime - thoughtTimer >= THOUGHT_INTERVAL then
            thoughtTimer = currentTime
            
            local thoughts = startingThoughts[currentThoughtLine]
            if currentThoughtIndex <= #thoughts then
                local thoughtKey = thoughts[currentThoughtIndex]
                showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
                currentThoughtIndex = currentThoughtIndex + 1
            else
                -- Línea completada naturalmente
                stopStartingThoughts("Line completed")
            end
        end
    end
end

-- Iniciar pensamientos "Outside"
local function startOutsideThoughts()
    outsideThoughtsState = "active"
    currentOutsideThoughtIndex = 1
    
    print("Living Survivor: Outside thoughts started")
    
    -- Mostrar primer pensamiento inmediatamente
    local thoughtKey = outsideThoughts[currentOutsideThoughtIndex]
    showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
    
    currentOutsideThoughtIndex = currentOutsideThoughtIndex + 1
    outsideThoughtTimer = os.time()
end

-- Cancelar pensamientos "Outside"
local function cancelOutsideThoughts(reason)
    if outsideThoughtsState ~= "cancelled" and outsideThoughtsState ~= "completed" then
        outsideThoughtsState = "cancelled"
        print("Living Survivor: Outside thoughts cancelled - " .. reason)
    end
end

-- Procesar pensamientos "Outside"
local function updateOutsideThoughts()
    if not player or not player:isAlive() then return end
    
    -- Si ya están completados o cancelados, no hacer nada
    if outsideThoughtsState == "completed" or outsideThoughtsState == "cancelled" then
        return
    end
    
    local currentTime = os.time()
    local isOutside = isOutsideInitialBuilding()
    
    -- Verificar si un zombie lo detecta (cancela en cualquier estado)
    if isSpottedByZombie() then
        cancelOutsideThoughts("Spotted by zombie")
        return
    end
    
    -- Estado: esperando a que salga por primera vez
    if outsideThoughtsState == "waiting" then
        if isOutside then
            -- Salió de casa, empezar a contar
            outsideThoughtsState = "counting"
            timeLeftInitialBuilding = currentTime
            print("Living Survivor: Player left initial building, counting started")
        end
        return
    end
    
    -- Estado: contando 10 segundos fuera
    if outsideThoughtsState == "counting" then
        if not isOutside then
            -- Volvió a entrar, resetear
            outsideThoughtsState = "waiting"
            print("Living Survivor: Player returned to initial building, countdown reset")
            return
        end
        
        -- Verificar si han pasado 10 segundos fuera
        if currentTime - timeLeftInitialBuilding >= OUTSIDE_START_DELAY then
            startOutsideThoughts()
        end
        return
    end
    
    -- Estado: activo (mostrando pensamientos)
    if outsideThoughtsState == "active" then
        -- Mostrar siguiente pensamiento cada 6 segundos
        if currentTime - outsideThoughtTimer >= OUTSIDE_THOUGHT_INTERVAL then
            outsideThoughtTimer = currentTime
            
            if currentOutsideThoughtIndex <= #outsideThoughts then
                local thoughtKey = outsideThoughts[currentOutsideThoughtIndex]
                showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
                currentOutsideThoughtIndex = currentOutsideThoughtIndex + 1
            else
                -- Línea completada
                outsideThoughtsState = "completed"
                print("Living Survivor: Outside thoughts completed")
            end
        end
    end
end

-- Iniciar pensamientos "FirstPanic"
local function startFirstPanicThoughts()
    firstPanicState = "active"
    currentFirstPanicIndex = 1
    
    print("Living Survivor: FirstPanic thoughts started")
    
    -- Mostrar primer pensamiento inmediatamente
    local thoughtKey = firstPanicThoughts[currentFirstPanicIndex]
    showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
    
    currentFirstPanicIndex = currentFirstPanicIndex + 1
    firstPanicThoughtTimer = os.time()
end

-- Cancelar pensamientos "FirstPanic"
local function cancelFirstPanicThoughts(reason)
    if firstPanicState == "active" then
        firstPanicState = "cancelled"
        print("Living Survivor: FirstPanic thoughts cancelled - " .. reason)
    end
end

-- Procesar pensamientos "FirstPanic"
local function updateFirstPanicThoughts()
    if not player or not player:isAlive() then return end
    
    -- Si ya están completados o cancelados, no hacer nada
    if firstPanicState == "completed" or firstPanicState == "cancelled" then
        return
    end
    
    -- Si está en cooldown, verificar si ya pasaron los 10 segundos
    if firstPanicState == "cooldown" then
        local currentTime = os.time()
        if currentTime - firstPanicCompletedTime >= FIRST_PANIC_COOLDOWN then
            firstPanicState = "completed"
            print("Living Survivor: FirstPanic cooldown finished, normal Panic thoughts enabled")
        end
        return
    end
    
    -- Estado: activo (mostrando pensamientos)
    if firstPanicState == "active" then
        -- Verificar si fue atacado
        if wasPlayerAttacked() then
            cancelFirstPanicThoughts("Player was attacked")
            return
        end
        
        local currentTime = os.time()
        
        -- Mostrar siguiente pensamiento cada 6 segundos
        if currentTime - firstPanicThoughtTimer >= FIRST_PANIC_INTERVAL then
            firstPanicThoughtTimer = currentTime
            
            if currentFirstPanicIndex <= #firstPanicThoughts then
                local thoughtKey = firstPanicThoughts[currentFirstPanicIndex]
                showThought(getText("IGUI_LivingSurvivor_" .. thoughtKey))
                currentFirstPanicIndex = currentFirstPanicIndex + 1
            else
                -- Línea completada, iniciar cooldown
                firstPanicState = "cooldown"
                firstPanicCompletedTime = currentTime
                print("Living Survivor: FirstPanic thoughts completed, starting cooldown")
            end
        end
    end
end

-- Función que se ejecuta cada tick del juego
local function onPlayerUpdate()
    if not player or not player:isAlive() then return end
    
    -- Sistema de pensamientos iniciales (lockdown)
    updateStartingThoughts()
    
    -- Sistema de pensamientos "Outside"
    updateOutsideThoughts()
    
    -- Sistema de pensamientos "FirstPanic"
    updateFirstPanicThoughts()
    
    -- Revisar cada moodle
    for moodleName, thoughtKeys in pairs(moodleThoughtKeys) do
        local currentLevel = getMoodleLevel(moodleName)
        local previousLevel = previousMoodleLevels[moodleName] or 0
        
        -- Solo mostrar pensamiento si el nivel SUBE (no cuando baja)
        if currentLevel > previousLevel and currentLevel > 0 then
            
            local shouldShowThought = true
            
            -- LÓGICA ESPECIAL PARA PANIC
            if moodleName == "Panic" then
                -- Si es la primera vez que aparece Panic y estamos esperando
                if previousLevel == 0 and firstPanicState == "waiting" then
                    -- Activar FirstPanic en vez del pensamiento normal
                    startFirstPanicThoughts()
                    shouldShowThought = false
                -- Si FirstPanic está activo o en cooldown, ignorar cambios de Panic
                elseif firstPanicState == "active" or firstPanicState == "cooldown" then
                    shouldShowThought = false
                -- Si FirstPanic está completado, aplicar lógica normal de Panic con cooldown
                elseif firstPanicState == "completed" then
                    -- Solo para nivel 1
                    if currentLevel == 1 then
                        local currentTime = os.time()
                        if currentTime - panicLevel1LastTime < PANIC_LEVEL1_COOLDOWN then
                            shouldShowThought = false
                        else
                            panicLevel1LastTime = currentTime
                        end
                    end
                end
            end
            
            -- MOSTRAR PENSAMIENTO SI CORRESPONDE
            if shouldShowThought then
                local levelKeys = thoughtKeys[currentLevel]
                if levelKeys and #levelKeys > 0 then
                    -- Seleccionar clave aleatoria del grado actual
                    local randomKey = levelKeys[ZombRand(#levelKeys) + 1]
                    local thoughtText = getText("IGUI_LivingSurvivor_" .. randomKey)
                    showThought(thoughtText)
                end
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
            
            -- Info de pensamientos iniciales
            print("Lockdown thoughts started: " .. tostring(thoughtsStarted))
            print("Lockdown thoughts active: " .. tostring(startingThoughtsActive))
            if currentThoughtLine then
                print("Lockdown current line: " .. currentThoughtLine .. " [" .. currentThoughtIndex .. "]")
            end
            
            -- Info de pensamientos "Outside"
            print("Outside thoughts state: " .. outsideThoughtsState)
            if outsideThoughtsState == "counting" then
                local timeOutside = os.time() - timeLeftInitialBuilding
                print("Time outside: " .. timeOutside .. "s / " .. OUTSIDE_START_DELAY .. "s")
            end
            if outsideThoughtsState == "active" then
                print("Outside current index: " .. currentOutsideThoughtIndex)
            end
            
            -- Info de pensamientos "FirstPanic"
            print("FirstPanic state: " .. firstPanicState)
            if firstPanicState == "active" then
                print("FirstPanic current index: " .. currentFirstPanicIndex)
            end
            if firstPanicState == "cooldown" then
                local timeInCooldown = os.time() - firstPanicCompletedTime
                print("FirstPanic cooldown: " .. timeInCooldown .. "s / " .. FIRST_PANIC_COOLDOWN .. "s")
            end
            
            print("Outside building: " .. tostring(isOutsideInitialBuilding()))
            print("Spotted by zombie: " .. tostring(isSpottedByZombie()))
            print("Current health: " .. previousHealth)
            print("============================")
        end
    end
end

-- Función que se ejecuta al iniciar el juego
local function onGameStart()
    player = getPlayer()
    previousMoodleLevels = {}
    panicLevel1LastTime = 0
    
    -- Inicializar sistema de pensamientos iniciales (lockdown)
    gameStartTime = os.time()
    startingThoughtsActive = false
    thoughtsStarted = false
    currentThoughtLine = nil
    currentThoughtIndex = 1
    thoughtTimer = 0
    initialBuilding = player:getBuilding()
    
    -- Inicializar sistema de pensamientos "Outside"
    outsideThoughtsState = "waiting"
    timeLeftInitialBuilding = 0
    outsideThoughtTimer = 0
    currentOutsideThoughtIndex = 1
    
    -- Inicializar sistema de pensamientos "FirstPanic"
    firstPanicState = "waiting"
    firstPanicThoughtTimer = 0
    currentFirstPanicIndex = 1
    firstPanicCompletedTime = 0
    
    -- Inicializar salud
    local bodyDamage = player:getBodyDamage()
    if bodyDamage then
        previousHealth = bodyDamage:getOverallBodyHealth()
    end

    -- Contar moodles
    local moodleCount = 0
    for _ in pairs(moodleThoughtKeys) do
        moodleCount = moodleCount + 1
    end

    print("Living Survivor: Mod cargado correctamente")
    print("Living Survivor: Detectando " .. moodleCount .. " moodles")
    print("Living Survivor: Sistema de lectura activado")
    print("Living Survivor: Sistema de pensamientos iniciales activado")
    print("Living Survivor: Sistema de pensamientos Outside activado")
    print("Living Survivor: Sistema de pensamientos FirstPanic activado")
    print("Living Survivor: Pulsa º para ver estado del mod")
end

-- Sobrescribir ISReadABook.perform para detectar lectura completada
local originalISReadABookPerform = ISReadABook.perform
function ISReadABook:perform()
    originalISReadABookPerform(self)
    
    -- Verificar que el item existe y es literatura
    if self.item and self.item:getCategory() == "Literature" then
        local readingType = getReadingType(self.item)
        if readingType then
            showReadingThought(readingType)
        end
    end
end

-- Registrar eventos
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnKeyPressed.Add(onKeyPressed)
Events.OnGameStart.Add(onGameStart)

print("Living Survivor mod loaded successfully!")