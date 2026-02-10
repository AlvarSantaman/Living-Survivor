-- Living Survivor - Language Loader
-- Initializes the translation system

-- Inicializar tabla global
LivingSurvivorLang = LivingSurvivorLang or {}

-- Load language files
require "LSLang/EN"
require "LSLang/ES"

-- Alias para variantes de español
LivingSurvivorLang["AR"] = LivingSurvivorLang["ES"]

print("Living Survivor: Translations loaded successfully")