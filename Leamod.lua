--[[
    СКРИПТ: OCR-Based Real-Time Screen Reader + Auto Answer
    ПЛАТФОРМА: Android (Lua + Termux + Tesseract OCR)
    НАЗНАЧЕНИЕ: Считывает текст с экрана, анализирует символы,
    предсказывает слово из словаря, вводит ответ до завершения ввода.
    РАБОТАЕТ В ЛЮБОМ ПРИЛОЖЕНИИ БЕЗ ПРИВЯЗКИ К ПАКЕТУ.
--]]

-- ============================================================
-- БЛОК 1: КОНФИГУРАЦИЯ
-- ============================================================
local config = {
    screenshot_path = "/sdcard/screen.png",
    cropped_path = "/sdcard/crop.png",
    text_output = "/sdcard/ocr_output.txt",
    dict_path = "/sdcard/words.txt",
    tap_x = 540,       -- центр экрана X (1080/2)
    tap_y = 1920,      -- низ экрана (поле ввода обычно снизу)
    crop_x = 0,
    crop_y = 1400,     -- обрезаем верх, оставляем низ с текстом
    crop_w = 1080,
    crop_h = 400,
    scan_interval = 50, -- мс между сканированиями
}

-- ============================================================
-- БЛОК 2: ВСТРОЕННЫЙ СЛОВАРЬ
-- ============================================================
local builtin_words = {
    -- турецкие слова по длине
    "e","a","k","l","m","n","o","s","t","u","y",
    "el","al","ka","la","ma","na","ol","sa","ta","ya",
    "elm","alt","kal","lam","mal","olm","sal","tam","yap",
    "elma","altı","kalk","lama","mala","olma","sala","tama","yapı",
    "elmas","altın","kalkan","lambda","olmas","salak","tamam","yapım",
    "elması","altını","kalkanı","olmazsa","salakça","tamamen",
    -- английские слова
    "a","b","c","d","e","f","g","h","i","j","k","l","m",
    "n","o","p","q","r","s","t","u","v","w","x","y","z",
    "ab","ad","am","an","as","at","be","by","do","go","he","hi",
    "if","in","is","it","me","my","no","of","on","or","so","to",
    "and","are","but","can","did","for","get","got","had","has",
    "her","him","his","how","its","let","may","new","not","now",
    "off","old","one","our","out","put","say","see","she","the",
    "too","two","use","was","way","who","why","yes","you",
    "have","here","just","know","like","look","make","more","much",
    "must","name","need","only","over","same","some","such","take",
    "than","that","them","then","they","this","very","well","what",
    "when","will","with","your",
    "about","after","again","being","could","every","first","found",
    "great","house","large","might","never","other","place","right",
    "since","small","still","their","there","these","thing","think",
    "those","under","water","where","which","while","world","would",
}

-- ============================================================
-- БЛОК 3: ЗАХВАТ ЭКРАНА + OCR
-- ============================================================
local function capture_and_ocr()
    -- делаем скриншот
    os.execute("screencap -p " .. config.screenshot_path .. " 2>/dev/null")
    
    -- обрезаем только нижнюю часть где текст
    local crop_cmd = string.format(
        "convert %s -crop %dx%d+%d+%d %s 2>/dev/null",
        config.screenshot_path,
        config.crop_w, config.crop_h,
        config.crop_x, config.crop_y,
        config.cropped_path
    )
    os.execute(crop_cmd)
    
    -- OCR через Tesseract (язык: eng+tur)
    local ocr_cmd = string.format(
        "tesseract %s %s -l eng+tur --psm 6 2>/dev/null",
        config.cropped_path,
        config.text_output:gsub("%.txt$", "")
    )
    os.execute(ocr_cmd)
    
    -- читаем результат
    local f = io.open(config.text_output, "r")
    if not f then return "" end
    local text = f:read("*a"):gsub("\n", " "):gsub("%s+", " "):lower()
    f:close()
    return text
end

-- ============================================================
-- БЛОК 4: ПОИСК ПОСЛЕДНЕГО НЕЗАВЕРШЁННОГО СЛОВА
-- ============================================================
local function find_incomplete_word(screen_text)
    -- ищем последнее слово, которое выглядит как начало ввода
    -- обычно оно в конце строки или после двоеточия/вопроса
    local patterns = {
        "([a-zığüşöç]+)$",                    -- последнее слово
        ": ?([a-zığüşöç]+)$",                 -- после двоеточия
        "? ?([a-zığüşöç]+)$",                 -- после вопроса
        "\"([a-zığüşöç]+)\"$",                -- в кавычках
        "'([a-zığüşöç]+)'$",                  -- в одинарных кавычках
    }
    
    for _, pat in ipairs(patterns) do
        local word = screen_text:match(pat)
        if word and #word > 0 then
            return word
        end
    end
    
    -- если ничего не нашли, берём последний кусок текста
    local parts = {}
    for part in screen_text:gmatch("%S+") do
        parts[#parts + 1] = part
    end
    return parts[#parts] or ""
end

-- ============================================================
-- БЛОК 5: ЗАГРУЗКА ВНЕШНЕГО СЛОВАРЯ
-- ============================================================
local function load_dictionary()
    local words = {}
    local seen = {}
    
    -- пробуем загрузить внешний файл
    local f = io.open(config.dict_path, "r")
    if f then
        for line in f:lines() do
            line = line:match("^%s*(.-)%s*$"):lower()
            if line ~= "" and not seen[line] then
                words[#words + 1] = line
                seen[line] = true
            end
        end
        f:close()
    end
    
    -- добавляем встроенные слова
    for _, w in ipairs(builtin_words) do
        if not seen[w] then
            words[#words + 1] = w
            seen[w] = true
        end
    end
    
    -- сортировка по длине (длинные первее)
    table.sort(words, function(a, b) return #a > #b end)
    return words
end

-- ============================================================
-- БЛОК 6: ПРЕДСКАЗАНИЕ СЛОВА
-- ============================================================
local function predict_word(prefix, dictionary)
    if not prefix or prefix == "" then return nil end
    prefix = prefix:lower()
    
    -- точное совпадение префикса
    for _, word in ipairs(dictionary) do
        if #word >= #prefix and word:sub(1, #prefix) == prefix then
            return word
        end
    end
    
    -- частичное совпадение (слово содержит префикс)
    for _, word in ipairs(dictionary) do
        if word:find(prefix, 1, true) then
            return word
        end
    end
    
    return nil
end

-- ============================================================
-- БЛОК 7: ОТПРАВКА СЛОВА
-- ============================================================
local function send_word(word)
    -- метод 1: через буфер обмена (мгновенно)
    os.execute("am broadcast -a clipper.set -e text '" .. word .. "' 2>/dev/null")
    os.execute("sleep 0.02")
    
    -- метод 2: через input text (по буквам, если буфер не сработал)
    -- os.execute("input text '" .. word .. "'")
    -- os.execute("sleep 0.05")
    
    -- отправка (Enter)
    os.execute("input keyevent 66")
    
    print("[SENT] >>> " .. word)
end

-- ============================================================
-- БЛОК 8: ГЛАВНЫЙ ЦИКЛ
-- ============================================================
local function main()
    local dictionary = load_dictionary()
    local last_prefix = ""
    local last_prediction = ""
    local sent_words = {}
    
    print("====================================")
    print("  OCR PREDICTOR v2.0 - AKTIF")
    print("  Sozluk: " .. #dictionary .. " kelime")
    print("====================================")
    
    -- тапаем по полю ввода для фокуса
    os.execute("input tap " .. config.tap_x .. " " .. config.tap_y)
    os.execute("sleep 0.1")
    
    while true do
        local screen_text = capture_and_ocr()
        local current_word = find_incomplete_word(screen_text)
        
        if current_word and current_word ~= "" then
            -- проверяем не отправляли ли уже
            if sent_words[current_word] then
                os.execute("sleep 0.05")
                goto continue
            end
            
            if current_word ~= last_prefix then
                print("[OCR] Ekranda: '" .. current_word .. "'")
                last_prefix = current_word
                
                local prediction = predict_word(current_word, dictionary)
                
                if prediction and prediction ~= last_prediction then
                    print("[PREDICT] Tahmin: '" .. prediction .. "'")
                    last_prediction = prediction
                    
                    -- мгновенная отправка
                    send_word(prediction)
                    sent_words[current_word] = true
                    sent_words[prediction] = true
                    
                    -- сбрасываем чтобы ловить следующее слово
                    last_prefix = ""
                    last_prediction = ""
                end
            end
        end
        
        ::continue::
        os.execute("sleep " .. (config.scan_interval / 1000))
    end
end

-- ============================================================
-- ЗАПУСК
-- ============================================================
local function check_deps()
    -- проверка Tesseract
    local f = io.popen("which tesseract 2>/dev/null")
    local tesseract = f:read("*a"):gsub("\n", "")
    f:close()
    
    -- проверка ImageMagick (convert)
    local f2 = io.popen("which convert 2>/dev/null")
    local convert = f2:read("*a"):gsub("\n", "")
    f2:close()
    
    if tesseract == "" then
        print("[ERROR] Tesseract OCR yuklu degil!")
        print("[FIX] pkg install tesseract tesseract-data-eng tesseract-data-tur")
        return false
    end
    if convert == "" then
        print("[ERROR] ImageMagick yuklu degil!")
        print("[FIX] pkg install imagemagick")
        return false
    end
    return true
end

if check_deps() then
    main()
else
    print("[INFO] Gereksinimleri yukleyin ve tekrar calistirin.")
end
