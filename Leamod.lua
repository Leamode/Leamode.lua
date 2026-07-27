--[[
    СКРИПТ: Мгновенный предиктор ввода (AI-подобный чит-бот)
    АВТОР: palofsc
    НАЗНАЧЕНИЕ: Перехват ввода, подбор символов по словарю, 
    отправка верного слова до того, как система его запросит.
    ПЛАТФОРМА: Android (Lua + Tasker / MacroDroid / GameGuardian)
--]]

-- ============================================================
-- БЛОК 1: КОНФИГУРАЦИЯ И СЛОВАРЬ
-- ============================================================
local config = {
    target_package = "com.sammy.game",        -- пакет целевого приложения
    input_field_id = "edit_text_input",       -- ID поля ввода (для UI Automator)
    delay_ms = 1,                             -- задержка между попытками (мс)
    max_retries = 0,                          -- 0 = бесконечно пробовать
    dictionary_file = "/sdcard/dict.txt"      -- путь к файлу словаря
}

-- Встроенный словарь (используется, если файл не найден)
local builtin_dictionary = {
    "elmas", "altın", "zümrüt", "yakut", "pırlanta",
    "kılıç", "kalkan", "büyü", "iksir", "ejderha",
    "orman", "dağ", "deniz", "gökyüzü", "yıldız",
    "kral", "kraliçe", "şövalye", "büyücü", "okçu",
    "e", "el", "elm", "elma", "elmas",
    "a", "al", "alt", "altı", "altın",
    "k", "ka", "kal", "kalk", "kalkan"
}

-- ============================================================
-- БЛОК 2: ЗАГРУЗКА СЛОВАРЯ
-- ============================================================
local function load_dictionary()
    local dict = {}
    local file = io.open(config.dictionary_file, "r")
    if file then
        for line in file:lines() do
            line = line:match("^%s*(.-)%s*$")  -- обрезаем пробелы
            if line ~= "" then
                dict[#dict + 1] = line
            end
        end
        file:close()
    end
    -- если файл пуст или не найден, используем встроенный
    if #dict == 0 then
        dict = builtin_dictionary
    end
    -- сортировка: сначала длинные слова для быстрого исключения
    table.sort(dict, function(a, b) return #a > #b end)
    return dict
end

-- ============================================================
-- БЛОК 3: ПЕРЕХВАТ ВВОДА (ЧТЕНИЕ ТЕКУЩЕГО ТЕКСТА)
-- ============================================================
local function get_current_input()
    --[[
        Вариант А: через UI Automator (требует рут / accessibility service)
        os.execute("uiautomator dump /sdcard/ui.xml")
        -- парсим ui.xml, ищем нужный элемент по ID или тексту
    ]]
    
    --[[
        Вариант Б: через буфер обмена (самый простой, без рута)
        Имитируем: долгое нажатие -> выделить всё -> копировать
    ]]
    os.execute("input swipe 500 500 500 500 100")      -- долгий тап
    os.execute("sleep 0.05")
    os.execute("input keyevent 29 --longpress")         -- Ctrl+A
    os.execute("sleep 0.02")
    os.execute("input keyevent 278 --longpress")        -- Ctrl+C
    os.execute("sleep 0.05")
    
    -- читаем буфер обмена (нужен доступ к /data/clipboard или Termux API)
    local handle = io.popen("termux-clipboard-get 2>/dev/null || cat /data/clipboard 2>/dev/null")
    local text = handle:read("*a"):gsub("\n", ""):gsub("\r", "")
    handle:close()
    return text
end

-- ============================================================
-- БЛОК 4: АЛГОРИТМ ПРЕДСКАЗАНИЯ
-- ============================================================
local function predict_word(current_input, dictionary)
    if current_input == "" then return nil end
    
    current_input = current_input:lower()
    
    -- Фаза 1: точное совпадение префикса
    local candidates = {}
    for _, word in ipairs(dictionary) do
        if word:sub(1, #current_input) == current_input then
            candidates[#candidates + 1] = word
        end
    end
    
    -- Фаза 2: если нет точного префикса, ищем частичное совпадение
    if #candidates == 0 then
        for _, word in ipairs(dictionary) do
            if word:find(current_input, 1, true) then
                candidates[#candidates + 1] = word
            end
        end
    end
    
    -- возвращаем самое вероятное (первое по сортировке)
    if #candidates > 0 then
        return candidates[1]
    end
    return nil
end

-- ============================================================
-- БЛОК 5: ОТПРАВКА СИМВОЛОВ В ПОЛЕ ВВОДА
-- ============================================================
local function type_text(text)
    -- очистка поля
    os.execute("input keyevent 29 --longpress")  -- Ctrl+A
    os.execute("sleep 0.01")
    os.execute("input keyevent 67")              -- Delete
    
    -- ввод через буфер обмена (мгновенно)
    local cmd = string.format("echo '%s' | termux-clipboard-set 2>/dev/null || echo '%s' > /data/clipboard", text, text)
    os.execute(cmd)
    os.execute("sleep 0.01")
    os.execute("input keyevent 278 --longpress") -- Ctrl+V (вставить)
    os.execute("sleep 0.01")
    os.execute("input keyevent 66")              -- Enter (отправить)
end

-- ============================================================
-- БЛОК 6: ПОБУКВЕННЫЙ ПЕРЕБОР (АГРЕССИВНЫЙ РЕЖИМ)
-- ============================================================
local function brute_force_char(current_input, dictionary)
    local alphabet = {
        "a","b","c","d","e","f","g","h","i","j","k","l","m",
        "n","o","p","q","r","s","t","u","v","w","x","y","z",
        "ı","ğ","ü","ş","ö","ç"
    }
    
    for _, char in ipairs(alphabet) do
        local attempt = current_input .. char
        local prediction = predict_word(attempt, dictionary)
        if prediction and prediction:sub(1, #attempt) == attempt then
            os.execute("input keyevent 67")  -- удаляем последний символ если не подходит
            return char, prediction
        end
    end
    return nil, nil
end

-- ============================================================
-- БЛОК 7: ГЛАВНЫЙ ЦИКЛ ПРЕДСКАЗАНИЯ
-- ============================================================
local function main_loop()
    local dictionary = load_dictionary()
    local last_input = ""
    local last_prediction = ""
    
    print("[PREDICTOR] Запущен. Цель: " .. config.target_package)
    print("[PREDICTOR] Слов в словаре: " .. #dictionary)
    
    while true do
        -- фокусируемся на целевом приложении
        os.execute("am start -n " .. config.target_package .. "/.MainActivity 2>/dev/null")
        os.execute("sleep 0.3")
        
        -- тапаем по полю ввода (координаты настраиваются под разрешение)
        os.execute("input tap 540 960")  -- центр экрана 1080x1920
        os.execute("sleep 0.1")
        
        local current_input = get_current_input()
        
        if current_input ~= last_input then
            print("[INPUT] Текущий ввод: '" .. current_input .. "'")
            last_input = current_input
            
            -- пробуем предсказать целое слово
            local prediction = predict_word(current_input, dictionary)
            
            if prediction and prediction ~= last_prediction then
                print("[PREDICT] Предсказано: '" .. prediction .. "'")
                
                -- отправляем слово мгновенно
                type_text(prediction)
                last_prediction = prediction
                
                print("[SENT] Отправлено: " .. prediction)
            else
                -- если предсказать не удалось, перебираем по буквам
                print("[BRUTE] Запуск побуквенного перебора...")
                local char, pred = brute_force_char(current_input, dictionary)
                if char then
                    os.execute("input text " .. char)
                    print("[BRUTE] Добавлен символ: " .. char)
                end
            end
        end
        
        os.execute("sleep 0.01")  -- минимальная задержка (10 мс)
    end
end

-- ============================================================
-- БЛОК 8: ЗАПУСК
-- ============================================================
-- Проверка окружения
local function check_environment()
    -- проверяем наличие Termux
    local f = io.open("/data/data/com.termux/files/usr/bin/termux-clipboard-get", "r")
    if f then f:close(); return true end
    
    -- проверяем рут
    local handle = io.popen("su -c 'id' 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    if result:find("uid=0") then return true end
    
    return false
end

if check_environment() then
    print("[OK] Окружение готово.")
    main_loop()
else
    print("[ERROR] Требуется Termux или ROOT доступ!")
    print("[INFO] Установите Termux: apt install termux-api")
end
