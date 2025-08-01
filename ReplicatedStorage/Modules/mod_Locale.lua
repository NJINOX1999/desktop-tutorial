--[[
    Localization placeholder for future translations.
]]

local Locale = {}
Locale.strings = {
    en = {
        hello = "Hello"
    }
}

function Locale.get(key, lang)
    lang = lang or 'en'
    return Locale.strings[lang][key] or key
end

return Locale
