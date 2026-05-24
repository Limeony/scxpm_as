// ========== VERSION ==========

string SCXPM_VERSION = "1.0"; 
bool SCXPM_Enabled = true;

// ========== FILES PATH ==========

const string PATH_MAIN_DATA = "scripts/plugins/store/scxpm_as/data/";
const string PATH_LOGS = "scripts/plugins/store/scxpm_as/logs/";
const string DB_DIR = "scripts/plugins/store/scxpm_as/data/";

// ========== DATABASE SYSTEM ==========

dictionary g_PlayerDatabase;
bool g_bDatabaseReady = false;
bool g_bPendingSave = false;
const float SAVE_INTERVAL = 15.0;       

// ========== LAST SAVED VALUES FOR COMPARISON ==========

dictionary g_LastSavedData;

// ========== DATA ARRAYS ==========

array<int> xp(33, 0);
array<int> neededxp(33, 30);
array<int> playerlevel(33, 1);
array<int> skillpoints(33, 1);
array<string> rank(33, "Frightened Civilian");
array<int> health(33, 0);
array<int> armor(33, 0);
array<int> rhealth(33, 0);
array<int> rarmor(33, 0);
array<int> rammo(33, 0);
array<int> gravity(33, 0);
array<int> speed(33, 0);
array<int> dist(33, 0);
array<int> dodge(33, 0);
array<int> medals(33, 1);
array<int> skillIncrement(33, 1);   
array<int> lastSelectedSkill(33, 0);

// ========== LIMITS ==========

const int MAX_HEALTH = 450;
const int MAX_ARMOR = 450;
const int MAX_RHEALTH = 300;
const int MAX_RARMOR = 300;
const int MAX_RAMMO = 30;
const int MAX_GRAVITY = 40;
const int MAX_SPEED = 80;
const int MAX_DIST = 60;
const int MAX_DODGE = 90;
const int MAX_MEDALS = 15;
const int MAX_LEVEL = 1800;
const int MAX_XP = 11500000;
const int FRAGS_PER_MEDAL = 50000;
const int SAVE_MIN_LEVEL = 1;
const int SAVE_MIN_MEDALS = 1;

// ========== WEAPON IDS ==========

const int WEAPON_CROWBAR = 1;
const int WEAPON_GLOCK = 2;
const int WEAPON_357 = 3;
const int WEAPON_MP5 = 4;
const int WEAPON_CROSSBOW = 6;
const int WEAPON_SHOTGUN = 7;
const int WEAPON_RPG = 8;
const int WEAPON_GAUSS = 9;
const int WEAPON_EGON = 10;
const int WEAPON_HORNETGUN = 11;
const int WEAPON_HANDGRENADE = 12;
const int WEAPON_TRIPMINE = 13;
const int WEAPON_SATCHEL = 14;
const int WEAPON_SNARK = 15;
const int WEAPON_UZI = 17;
const int WEAPON_UZIAKIMBO = 17;
const int WEAPON_MEDKIT = 18;
const int WEAPON_PIPEWRENCH = 20;
const int WEAPON_MINIGUN = 21;
const int WEAPON_GRAPPLE = 22;
const int WEAPON_SNIPERRIFLE = 23;
const int WEAPON_M249 = 24;
const int WEAPON_M16 = 25;
const int WEAPON_SPORELAUNCHER = 26;
const int WEAPON_DESERT_EAGLE = 27;
const int WEAPON_DISPLACER = 29;

// ========== AMMO CONSTANTS ==========

int AMMO_9MM = 1;
int AMMO_357 = 2;
int AMMO_BUCKSHOT = 3;
int AMMO_CROSSBOW = 4;
int AMMO_RPG = 5;
int AMMO_GAUSS = 6;
int AMMO_556 = 7;
int AMMO_762 = 8;
int AMMO_ARGRENADES = 9;
int AMMO_SPORECLIP = 10;
int AMMO_ROACH = 11;

// ========== TRACKING ARRAYS ==========

array<float> lastfrags(33, 0);
array<int> totalFrags(33, 0);
array<int> sessionFrags(33, 0);
array<int> rhealthwait(33, 0);
array<int> rarmorwait(33, 0);
array<int> ammowait(33, 0);
array<bool> has_godmode(33, false);
array<bool> has_noclip(33, false);
array<int> lastDeadflag(33, 1);
array<int> starthealth(33, 100);
array<int> startarmor(33, 0);
array<float> lastGodModeCheck(33, 0);
array<bool> loaddata(33, false);
array<bool> firstSpawn(33, true);
array<float> hud_pos_x(33, 0.65);
array<float> hud_pos_y(33, 0.04);

// ========== ADMIN SETTINGS ==========

float g_fXPGainMultiplier = 1.0;
dictionary pmenu_state;

// ========== HELPER FUNCTIONS ==========

int floatround(float value)
{
    return int(value + 0.5);
}

string AddCommas(int iNum)
{
    string szOutput;
    string szTmp;
    uint iOutputPos = 0;
    uint iNumPos = 0;
    uint iNumLen;
    
    szTmp = string(iNum);
    iNumLen = szTmp.Length();
    
    if (iNumLen <= 3)
    {
        szOutput = szTmp;
    }
    else
    {
        szOutput = "?????????????";
        while (iNumPos < iNumLen) 
        {
            szOutput.SetCharAt(iOutputPos++, char(szTmp[iNumPos++]));
            
            if ((iNumLen - iNumPos) != 0 && !(((iNumLen - iNumPos) % 3) != 0)) 
                szOutput.SetCharAt(iOutputPos++, char(","));
        }
        szOutput.Replace("?", "");
    }
    
    return szOutput;
}

void SCXPM_Log(const string& in szMessage)
{
    DateTime thetime(UnixTimestamp());
    int year = thetime.GetYear();
    int month = thetime.GetMonth();
    int day = thetime.GetDayOfMonth();
    int hour = thetime.GetHour();
    int minutes = thetime.GetMinutes();
    int seconds = thetime.GetSeconds();
    
    string szMonths;
    string szDays;
    string szHours;
    string szMinutes;
    string szSeconds;
    if (month < 10) szMonths = "0" + month;
    else szMonths = month;
    if (day < 10) szDays = "0" + day;
    else szDays = day;
    if (hour < 10) szHours = "0" + hour;
    else szHours = hour;
    if (minutes < 10) szMinutes = "0" + minutes;
    else szMinutes = minutes;
    if (seconds < 10) szSeconds = "0" + seconds;
    else szSeconds = seconds;
    
    string fullpath = PATH_LOGS + "LOG_" + year + "-" + szMonths + "-" + szDays + ".log";
    File@ thefile = g_FileSystem.OpenFile(fullpath, OpenFile::APPEND);
    
    if (thefile !is null && thefile.IsOpen())
    {
        thefile.Write(szHours + ":" + szMinutes + ":" + szSeconds + " - " + szMessage);
        thefile.Close();
    }
}

void CreateDirectoryIfNotExists(const string& in szPath)
{
    string szTestFile = szPath + "/.test";
    File@ testFile = g_FileSystem.OpenFile(szTestFile, OpenFile::WRITE);
    if (testFile !is null && testFile.IsOpen())
    {
        testFile.Close();
        g_FileSystem.RemoveFile(szTestFile);
    }
}

bool FileExistsFunc(const string& in szPath)
{
    File@ f = g_FileSystem.OpenFile(szPath, OpenFile::READ);
    if (f !is null && f.IsOpen())
    {
        f.Close();
        return true;
    }
    return false;
}

// ========== DATABASE HELPER FUNCTIONS ==========

string ReadActiveSlot()
{
    string pointerPath = DB_DIR + "db_pointer.txt";
    
    if (!FileExistsFunc(pointerPath))
    {
        File@ fNew = g_FileSystem.OpenFile(pointerPath, OpenFile::WRITE);
        if (fNew !is null && fNew.IsOpen())
        {
            fNew.Write("A");
            fNew.Close();
            SCXPM_Log("Created new db_pointer.txt with default slot A\n");
        }
        return "A";
    }
    
    File@ pFile = g_FileSystem.OpenFile(pointerPath, OpenFile::READ);
    if (pFile !is null && pFile.IsOpen())
    {
        string slot;
        pFile.ReadLine(slot);
        pFile.Close();
        slot.Trim();
        if (slot == "A" || slot == "B")
            return slot;
    }
    return "A";
}

void UpdateActiveSlot(const string& in newSlot)
{
    string pointerPath = DB_DIR + "db_pointer.txt";
    File@ pFile = g_FileSystem.OpenFile(pointerPath, OpenFile::WRITE);
    if (pFile !is null && pFile.IsOpen())
    {
        pFile.Write(newSlot);
        pFile.Close();
        SCXPM_Log("Active slot updated to " + newSlot + "\n");
    }
}

string BuildJsonFromDatabase()
{
    string json = "{\n  \"integrity_check\": \"OK\",\n  \"version\": \"" + SCXPM_VERSION + "\",\n  \"players\": {\n";
    
    array<string>@ keys = g_PlayerDatabase.getKeys();
    for (uint i = 0; i < keys.length(); i++)
    {
        if (i > 0)
            json += ",\n";
        json += "    \"" + keys[i] + "\": \"" + string(g_PlayerDatabase[keys[i]]) + "\"";
    }
    
    json += "\n  }\n}";
    return json;
}

bool VerifyJsonContent(const string& in jsonContent)
{
    if (jsonContent.Find("integrity_check") < 0)
        return false;
    if (jsonContent.Find("\"OK\"") < 0)
        return false;
    if (jsonContent.Length() < 20)
        return false;
    return true;
}

bool ParseJsonToDatabase(const string& in jsonContent)
{
    if (!VerifyJsonContent(jsonContent))
        return false;
    
    int playersStart = jsonContent.Find("\"players\": {");
    if (playersStart < 0)
        return false;
    
    int braceStart = jsonContent.Find("{", playersStart);
    if (braceStart < 0)
        return false;
    
    int braceEnd = -1;
    int braceDepth = 1;
    for (int i = braceStart + 1; i < int(jsonContent.Length()); i++)
    {
        if (jsonContent[i] == '{')
            braceDepth++;
        else if (jsonContent[i] == '}')
        {
            braceDepth--;
            if (braceDepth == 0)
            {
                braceEnd = i;
                break;
            }
        }
    }
    
    if (braceEnd < 0)
        return false;
    
    string playersContent = jsonContent.SubString(braceStart + 1, braceEnd - braceStart - 1);
    
    array<string>@ lines = playersContent.Split('\n');
    for (uint i = 0; i < lines.length(); i++)
    {
        string line = lines[i];
        line.Trim();
        if (line.Length() == 0 || line == ",")
            continue;
        
        if (line.EndsWith(","))
            line = line.SubString(0, line.Length() - 1);
        
        line.Trim();
        
        int colonPos = line.Find(":");
        if (colonPos < 0)
            continue;
        
        int firstQuote = line.Find("\"");
        int secondQuote = line.Find("\"", firstQuote + 1);
        if (firstQuote < 0 || secondQuote < 0)
            continue;
        
        string steamid = line.SubString(firstQuote + 1, secondQuote - firstQuote - 1);
        
        int dataStartQuote = line.Find("\"", colonPos + 1);
        if (dataStartQuote < 0)
            continue;
        int dataEndQuote = line.Find("\"", dataStartQuote + 1);
        if (dataEndQuote < 0)
            continue;
        
        string data = line.SubString(dataStartQuote + 1, dataEndQuote - dataStartQuote - 1);
        
        if (steamid.Length() > 0 && data.Length() > 0)
            g_PlayerDatabase[steamid] = data;
    }
    
    return true;
}

void ForceSaveToFile()
{
    if (!g_bDatabaseReady)
        return;
    
    if (g_PlayerDatabase.getSize() == 0)
        return;
    
    CreateDirectoryIfNotExists(DB_DIR);
    
    string currentSlot = ReadActiveSlot();
    string nextSlot = (currentSlot == "A") ? "B" : "A";
    string targetPath = DB_DIR + "database_" + nextSlot + ".json";
    string tempPath = DB_DIR + "database_" + nextSlot + ".tmp";
    
    string jsonContent = BuildJsonFromDatabase();
    
    File@ fTemp = g_FileSystem.OpenFile(tempPath, OpenFile::WRITE);
    if (fTemp is null || !fTemp.IsOpen())
    {
        SCXPM_Log("ERROR: Cannot create temp file " + tempPath + "\n");
        return;
    }
    
    fTemp.Write(jsonContent);
    fTemp.Close();
    
    if (!VerifyJsonFile(tempPath))
    {
        SCXPM_Log("ERROR: Temp file verification failed, save aborted\n");
        g_FileSystem.RemoveFile(tempPath);
        return;
    }
    
    if (FileExistsFunc(targetPath))
        g_FileSystem.RemoveFile(targetPath);
    
    File@ fSrc = g_FileSystem.OpenFile(tempPath, OpenFile::READ);
    if (fSrc is null || !fSrc.IsOpen())
    {
        SCXPM_Log("ERROR: Cannot read temp file for copy\n");
        return;
    }
    
    File@ fDst = g_FileSystem.OpenFile(targetPath, OpenFile::WRITE);
    if (fDst is null || !fDst.IsOpen())
    {
        SCXPM_Log("ERROR: Cannot create target file " + targetPath + "\n");
        fSrc.Close();
        return;
    }
    
    string content;
    string line;
    while (!fSrc.EOFReached())
    {
        fSrc.ReadLine(line);
        content += line + "\n";
    }
    fDst.Write(content);
    fDst.Close();
    fSrc.Close();
    
    g_FileSystem.RemoveFile(tempPath);
    
    UpdateActiveSlot(nextSlot);
    
    SCXPM_Log("Database saved to slot " + nextSlot + " (" + g_PlayerDatabase.getSize() + " entries)\n");
}

void ForceSaveAllPlayers()
{
    if (!g_bDatabaseReady)
        return;
    
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer !is null && pPlayer.IsConnected())
        {
            int id = pPlayer.entindex();
            
            int currentFrags = int(pPlayer.pev.frags);
            int sessionFragGain = currentFrags - sessionFrags[id];
            if (sessionFragGain > 0)
            {
                totalFrags[id] += sessionFragGain;
                sessionFrags[id] = currentFrags;
            }
            
            if (loaddata[id] && (playerlevel[id] >= SAVE_MIN_LEVEL || medals[id] >= SAVE_MIN_MEDALS))
            {
                string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
                if (szSteamID.Length() >= 2 && szSteamID != "STEAM_ID_LAN")
                {
                    string currentData = BuildPlayerDataString(id);
                    g_PlayerDatabase[szSteamID] = currentData;
                    UpdateLastSavedData(id);
                }
            }
        }
    }
    
    ForceSaveToFile();
    SCXPM_Log("Force save all players completed\n");
}

bool VerifyJsonFile(const string& in path)
{
    File@ fCheck = g_FileSystem.OpenFile(path, OpenFile::READ);
    if (fCheck is null || !fCheck.IsOpen())
        return false;
    
    string content;
    string line;
    while (!fCheck.EOFReached())
    {
        fCheck.ReadLine(line);
        content += line;
    }
    fCheck.Close();
    
    return VerifyJsonContent(content);
}

// ========== SLOT COMPARISON FUNCTIONS ==========

string GetPlayerDataFromSlot(const string& in szSteamID, const string& in slot)
{
    string dbPath = DB_DIR + "database_" + slot + ".json";
    
    if (!FileExistsFunc(dbPath))
        return "";
    
    File@ fData = g_FileSystem.OpenFile(dbPath, OpenFile::READ);
    if (fData is null || !fData.IsOpen())
        return "";
    
    string content;
    string line;
    while (!fData.EOFReached())
    {
        fData.ReadLine(line);
        content += line;
    }
    fData.Close();
    
    // Quick parse to find player data
    string searchKey = "\"" + szSteamID + "\": \"";
    int startPos = content.Find(searchKey);
    if (startPos < 0)
        return "";
    
    startPos += searchKey.Length();
    int endPos = content.Find("\"", startPos);
    if (endPos < 0)
        return "";
    
    return content.SubString(startPos, endPos - startPos);
}

bool IsPlayerDataBetter(const string& in data1, const string& in data2)
{
    if (data1.Length() == 0) return false;
    if (data2.Length() == 0) return true;
    
    array<string>@ config1 = data1.Split('#');
    array<string>@ config2 = data2.Split('#');
    
    if (config1.length() < 14) return false;
    if (config2.length() < 14) return true;
    
    int xp1 = atoi(config1[0]);
    int xp2 = atoi(config2[0]);
    
    int level1 = atoi(config1[12]);
    int level2 = atoi(config2[12]);
    
    int medals1 = atoi(config1[1]);
    int medals2 = atoi(config2[1]);
    
    int frags1 = atoi(config1[13]);
    int frags2 = atoi(config2[13]);
    
    // Compare by XP first, then level, then medals, then frags
    if (xp1 > xp2) return true;
    if (xp1 < xp2) return false;
    
    if (level1 > level2) return true;
    if (level1 < level2) return false;
    
    if (medals1 > medals2) return true;
    if (medals1 < medals2) return false;
    
    return (frags1 > frags2);
}

string GetBestPlayerData(const string& in szSteamID)
{
    string dataA = GetPlayerDataFromSlot(szSteamID, "A");
    string dataB = GetPlayerDataFromSlot(szSteamID, "B");
    
    if (IsPlayerDataBetter(dataA, dataB))
        return dataA;
    else
        return dataB;
}

void LoadGlobalDatabase()
{
    CreateDirectoryIfNotExists(DB_DIR);
    
    string currentSlot = ReadActiveSlot();
    string primaryPath = DB_DIR + "database_" + currentSlot + ".json";
    
    SCXPM_Log("Attempting to load database from slot " + currentSlot + "\n");
    
    if (FileExistsFunc(primaryPath))
    {
        File@ fData = g_FileSystem.OpenFile(primaryPath, OpenFile::READ);
        if (fData !is null && fData.IsOpen())
        {
            string content;
            string line;
            while (!fData.EOFReached())
            {
                fData.ReadLine(line);
                content += line;
            }
            fData.Close();
            
            if (ParseJsonToDatabase(content))
            {
                SCXPM_Log("Database loaded from slot " + currentSlot + " (" + g_PlayerDatabase.getSize() + " entries)\n");
                
                // Store last saved data for comparison
                array<string>@ keys = g_PlayerDatabase.getKeys();
                for (uint i = 0; i < keys.length(); i++)
                {
                    g_LastSavedData[keys[i]] = string(g_PlayerDatabase[keys[i]]);
                }
                return;
            }
            else
            {
                SCXPM_Log("WARNING: Slot " + currentSlot + " is corrupted!\n");
            }
        }
    }
    
    string backupSlot = (currentSlot == "A") ? "B" : "A";
    string backupPath = DB_DIR + "database_" + backupSlot + ".json";
    
    SCXPM_Log("Attempting to load from backup slot " + backupSlot + "\n");
    
    if (FileExistsFunc(backupPath))
    {
        File@ fBackup = g_FileSystem.OpenFile(backupPath, OpenFile::READ);
        if (fBackup !is null && fBackup.IsOpen())
        {
            string content;
            string line;
            while (!fBackup.EOFReached())
            {
                fBackup.ReadLine(line);
                content += line;
            }
            fBackup.Close();
            
            if (ParseJsonToDatabase(content))
            {
                SCXPM_Log("Database loaded from backup slot " + backupSlot + " (" + g_PlayerDatabase.getSize() + " entries)\n");
                UpdateActiveSlot(backupSlot);
                
                // Store last saved data for comparison
                array<string>@ keys = g_PlayerDatabase.getKeys();
                for (uint i = 0; i < keys.length(); i++)
                {
                    g_LastSavedData[keys[i]] = string(g_PlayerDatabase[keys[i]]);
                }
                return;
            }
        }
    }
    
    SCXPM_Log("No valid database found, starting fresh\n");
    
    // Clear dictionary without reassigning
    array<string>@ keys = g_PlayerDatabase.getKeys();
    for (uint i = 0; i < keys.length(); i++)
    {
        g_PlayerDatabase.delete(keys[i]);
    }
    
    g_bDatabaseReady = true;
    g_bPendingSave = true;
    ForceSaveToFile();
}

// ========== COMPARE AND SAVE FUNCTION ==========

bool HasPlayerDataImproved(int index, const string& in currentData)
{
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index);
    if (pPlayer is null) return false;
    
    string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
        return false;
    
    if (!g_LastSavedData.exists(szSteamID))
        return true;  // No saved data, need to save
    
    string lastData = string(g_LastSavedData[szSteamID]);
    if (lastData == currentData)
        return false;  // No changes
    
    // Parse current data
    array<string>@ currentConfig = currentData.Split('#');
    // Parse last saved data
    array<string>@ lastConfig = lastData.Split('#');
    
    if (currentConfig.length() < 14 || lastConfig.length() < 14)
        return true;
    
    int currentLevel = atoi(currentConfig[12]);
    int lastLevel = atoi(lastConfig[12]);
    
    // For max level players, only check frags and medals
    if (currentLevel >= MAX_LEVEL && lastLevel >= MAX_LEVEL)
    {
        int currentMedals = atoi(currentConfig[1]);
        int lastMedals = atoi(lastConfig[1]);
        int currentFrags = atoi(currentConfig[13]);
        int lastFrags = atoi(lastConfig[13]);
        
        // Only save if medals or frags increased
        if (currentMedals > lastMedals) return true;
        if (currentFrags > lastFrags) return true;
        
        return false; 
    }
    
    // Normal comparison for non-max players
    int currentXP = atoi(currentConfig[0]);
    int lastXP = atoi(lastConfig[0]);
    int currentMedals = atoi(currentConfig[1]);
    int lastMedals = atoi(lastConfig[1]);
    int currentFrags = atoi(currentConfig[13]);
    int lastFrags = atoi(lastConfig[13]);
    
    // Check if any value increased
    if (currentXP > lastXP) return true;
    if (currentMedals > lastMedals) return true;
    if (currentLevel > lastLevel) return true;
    if (currentFrags > lastFrags) return true;
    
    // Check skill values (only matter if not max level)
    if (atoi(currentConfig[2]) > atoi(lastConfig[2])) return true;  // health
    if (atoi(currentConfig[3]) > atoi(lastConfig[3])) return true;  // armor
    if (atoi(currentConfig[4]) > atoi(lastConfig[4])) return true;  // rhealth
    if (atoi(currentConfig[5]) > atoi(lastConfig[5])) return true;  // rarmor
    if (atoi(currentConfig[6]) > atoi(lastConfig[6])) return true;  // rammo
    if (atoi(currentConfig[7]) > atoi(lastConfig[7])) return true;  // gravity
    if (atoi(currentConfig[8]) > atoi(lastConfig[8])) return true;  // speed
    if (atoi(currentConfig[9]) > atoi(lastConfig[9])) return true;  // dist
    if (atoi(currentConfig[10]) > atoi(lastConfig[10])) return true; // dodge
    if (atoi(currentConfig[11]) > atoi(lastConfig[11])) return true; // skillpoints
    
    return false;
}

void UpdateLastSavedData(int index)
{
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index);
    if (pPlayer is null) return;
    
    string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
        return;
    
    string currentData = BuildPlayerDataString(index);
    g_LastSavedData[szSteamID] = currentData;
}

void AutoSaveIfChanged()
{
    if (!g_bDatabaseReady)
        return;
    
    bool bNeedsSave = false;
    
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer !is null && pPlayer.IsConnected())
        {
            int id = pPlayer.entindex();
            
            if (!loaddata[id])
                continue;
            
            if (playerlevel[id] < SAVE_MIN_LEVEL && medals[id] < SAVE_MIN_MEDALS)
                continue;
            
            string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
                continue;
            
            string currentData = BuildPlayerDataString(id);
            
            if (HasPlayerDataImproved(id, currentData))
            {
                g_PlayerDatabase[szSteamID] = currentData;
                UpdateLastSavedData(id);
                bNeedsSave = true;
                
                // Different log message for max level players
                if (playerlevel[id] >= MAX_LEVEL)
                {
                    SCXPM_Log("Auto-save triggered for " + string(pPlayer.pev.netname) + " - Frags/Medals changed (MAX LEVEL)\n");
                }
                else
                {
                    SCXPM_Log("Auto-save triggered for " + string(pPlayer.pev.netname) + " - Data improved\n");
                }
            }
        }
    }
    
    if (bNeedsSave)
    {
        ForceSaveToFile();
        SCXPM_Log("Auto-save completed (15s interval)\n");
    }
}

// ========== SAVE/LOAD FUNCTIONS ==========

void scxpm_savedata(int index, bool bForce = false)
{
    if (!g_bDatabaseReady)
        return;
    
    if (!loaddata[index])
        return;
    
    if (playerlevel[index] < SAVE_MIN_LEVEL && medals[index] < SAVE_MIN_MEDALS)
        return;
    
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index);
    if (pPlayer is null) return;
    
    string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
        return;
    
    string currentData = BuildPlayerDataString(index);
    
    // Check if we should save
    bool bShouldSave = bForce;
    if (!bForce)
    {
        bShouldSave = HasPlayerDataImproved(index, currentData);
    }
    
    if (!bShouldSave)
        return;
    
    g_PlayerDatabase[szSteamID] = currentData;
    UpdateLastSavedData(index);
    
    // For important events (level up, medal, skill upgrade), save immediately
    if (bForce)
    {
        ForceSaveToFile();
        if (playerlevel[index] >= MAX_LEVEL)
        {
            SCXPM_Log("Force save for " + string(pPlayer.pev.netname) + " - Medal/Frags update (MAX LEVEL)\n");
        }
        else
        {
            SCXPM_Log("Force save for " + string(pPlayer.pev.netname) + " - Important event\n");
        }
    }
    else
    {
        g_bPendingSave = true;
    }
    
    string szName = string(pPlayer.pev.netname);
    SCXPM_Log("Saved data for " + szName + " (" + szSteamID + ") - Level: " + playerlevel[index] + ", Total Frags: " + totalFrags[index] + "\n");
}

void ParseAndLoadPlayerData(int index, const string& in data)
{
    array<string>@ config = data.Split('#');
    
    if (config.length() >= 15)
    {
        xp[index] = atoi(config[0]);
        medals[index] = atoi(config[1]);
        health[index] = atoi(config[2]);
        armor[index] = atoi(config[3]);
        rhealth[index] = atoi(config[4]);
        rarmor[index] = atoi(config[5]);
        rammo[index] = atoi(config[6]);
        gravity[index] = atoi(config[7]);
        speed[index] = atoi(config[8]);
        dist[index] = atoi(config[9]);
        dodge[index] = atoi(config[10]);
        skillpoints[index] = atoi(config[11]);
        playerlevel[index] = atoi(config[12]);
        totalFrags[index] = atoi(config[13]);
    }
    else if (config.length() >= 14)
    {
        xp[index] = atoi(config[0]);
        medals[index] = atoi(config[1]);
        health[index] = atoi(config[2]);
        armor[index] = atoi(config[3]);
        rhealth[index] = atoi(config[4]);
        rarmor[index] = atoi(config[5]);
        rammo[index] = atoi(config[6]);
        gravity[index] = atoi(config[7]);
        speed[index] = atoi(config[8]);
        dist[index] = atoi(config[9]);
        dodge[index] = atoi(config[10]);
        skillpoints[index] = atoi(config[11]);
        playerlevel[index] = atoi(config[12]);
        totalFrags[index] = atoi(config[13]);
    }
    
    if (medals[index] < 1) medals[index] = 1;
    if (medals[index] > MAX_MEDALS) medals[index] = MAX_MEDALS;
    if (playerlevel[index] < 1) playerlevel[index] = 1;
    if (playerlevel[index] > MAX_LEVEL) playerlevel[index] = MAX_LEVEL;
}

void scxpm_loaddata(int index)
{
    if (!g_bDatabaseReady)
        return;
    
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index);
    if (pPlayer is null) return;
    
    string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
    {
        LoadEmptySkills(index);
        return;
    }
    
    // Try to get best data from both slots first
    string bestData = GetBestPlayerData(szSteamID);
    
    if (bestData.Length() > 0)
    {
        // Load from best data
        ParseAndLoadPlayerData(index, bestData);
        
        scxpm_calcneedxp(index);
        scxpm_getrank(index);
        
        loaddata[index] = true;
        sessionFrags[index] = 0;
        
        // Store in memory database
        g_PlayerDatabase[szSteamID] = bestData;
        UpdateLastSavedData(index);
        
        string szName = string(pPlayer.pev.netname);
        SCXPM_Log("Loaded best data for " + szName + " (" + szSteamID + ") - Level: " + playerlevel[index] + ", Medals: " + medals[index] + ", Total Frags: " + totalFrags[index] + "\n");
        return;
    }
    
    // Fallback to memory database if file reading failed
    if (g_PlayerDatabase.exists(szSteamID))
    {
        string data = string(g_PlayerDatabase[szSteamID]);
        data.Trim();
        ParseAndLoadPlayerData(index, data);
        
        scxpm_calcneedxp(index);
        scxpm_getrank(index);
        
        loaddata[index] = true;
        sessionFrags[index] = 0;
        
        UpdateLastSavedData(index);
        
        string szName = string(pPlayer.pev.netname);
        SCXPM_Log("Loaded data for " + szName + " (" + szSteamID + ") - Level: " + playerlevel[index] + ", Medals: " + medals[index] + ", Total Frags: " + totalFrags[index] + "\n");
    }
    else
    {
        LoadEmptySkills(index);
    }
}

void LoadEmptySkills(int index)
{
    xp[index] = 0;
    medals[index] = 1;
    health[index] = 0;
    armor[index] = 0;
    rhealth[index] = 0;
    rarmor[index] = 0;
    rammo[index] = 0;
    gravity[index] = 0;
    speed[index] = 0;
    dist[index] = 0;
    dodge[index] = 0;
    skillpoints[index] = 1;
    playerlevel[index] = 1;
    totalFrags[index] = 0;
    sessionFrags[index] = 0;
    loaddata[index] = true;
    
    scxpm_calcneedxp(index);
    scxpm_getrank(index);
    
    // Store initial data for comparison
    UpdateLastSavedData(index);
    
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(index);
    if (pPlayer !is null)
    {
        SCXPM_Log("Created new save data for " + string(pPlayer.pev.netname) + "\n");
    }
}

string BuildPlayerDataString(int id)
{
    string stuff;
    stuff += string(xp[id]) + "#";
    stuff += string(medals[id]) + "#";
    stuff += string(health[id]) + "#";
    stuff += string(armor[id]) + "#";
    stuff += string(rhealth[id]) + "#";
    stuff += string(rarmor[id]) + "#";
    stuff += string(rammo[id]) + "#";
    stuff += string(gravity[id]) + "#";
    stuff += string(speed[id]) + "#";
    stuff += string(dist[id]) + "#";
    stuff += string(dodge[id]) + "#";
    stuff += string(skillpoints[id]) + "#";
    stuff += string(playerlevel[id]) + "#";
    stuff += string(totalFrags[id]);
    return stuff;
}

void AutoSaveFrags()
{
    if (!g_bDatabaseReady)
        return;
    
    bool bAnyChange = false;
    
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer !is null && pPlayer.IsConnected())
        {
            int id = pPlayer.entindex();
            int currentFrags = int(pPlayer.pev.frags);
            int sessionFragGain = currentFrags - sessionFrags[id];
            
            if (sessionFragGain > 0)
            {
                totalFrags[id] += sessionFragGain;
                sessionFrags[id] = currentFrags;
                bAnyChange = true;
            }
        }
    }
    
    if (bAnyChange)
    {
        // Update database for all players with changes
        for (int i = 1; i <= 32; i++)
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if (pPlayer !is null && pPlayer.IsConnected())
            {
                int id = pPlayer.entindex();
                if (loaddata[id] && (playerlevel[id] >= SAVE_MIN_LEVEL || medals[id] >= SAVE_MIN_MEDALS))
                {
                    string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
                    if (szSteamID.Length() >= 2 && szSteamID != "STEAM_ID_LAN")
                    {
                        string currentData = BuildPlayerDataString(id);
                        if (HasPlayerDataImproved(id, currentData))
                        {
                            g_PlayerDatabase[szSteamID] = currentData;
                            UpdateLastSavedData(id);
                        }
                    }
                }
            }
        }
        g_bPendingSave = true;
    }
}

// ========== GAME LOGIC FUNCTIONS ==========

void scxpm_calcneedxp(int id)
{
    if (playerlevel[id] >= MAX_LEVEL) 
    {
        neededxp[id] = 0;
        return;
    }
    float m70 = float(playerlevel[id]) * 70.0;
    float mselfm3dot2 = float(playerlevel[id]) * float(playerlevel[id]) * 3.5;
    neededxp[id] = floatround(m70 + mselfm3dot2 + 30.0);
}

void scxpm_getrank(int id)
{
    int level = playerlevel[id];
    
    if (level == MAX_LEVEL)
        rank[id] = "Highest Force Leader";
    else if (level >= 1700)
        rank[id] = "Highest Force Member";
    else if (level >= 1600)
        rank[id] = "Top 15 of most famous Leaders";
    else if (level >= 1500)
        rank[id] = "Top 30 of most famous Leaders";
    else if (level >= 1400)
        rank[id] = "General";
    else if (level >= 1300)
        rank[id] = "Hidden Operations Leader";
    else if (level >= 1200)
        rank[id] = "Hidden Operations Scheduler";
    else if (level >= 1100)
        rank[id] = "Hidden Operations Member";
    else if (level >= 1000)
        rank[id] = "United Forces Leader";
    else if (level >= 900)
        rank[id] = "United Forces Member";
    else if (level >= 800)
        rank[id] = "Special Force Leader";
    else if (level >= 700)
        rank[id] = "Special Force Member";
    else if (level >= 600)
        rank[id] = "Professional Force Leader";
    else if (level >= 500)
        rank[id] = "Professional Force Member";
    else if (level >= 400)
        rank[id] = "Professional Free Agent";
    else if (level >= 300)
        rank[id] = "Free Agent";
    else if (level >= 200)
        rank[id] = "Private First Class";
    else if (level >= 100)
        rank[id] = "Private Second Class";
    else if (level >= 50)
        rank[id] = "Private Third Class";
    else if (level >= 20)
        rank[id] = "Fighter";
    else if (level >= 5)
        rank[id] = "Civilian";
    else
        rank[id] = "Frightened Civilian";
}

float scxpm_medal_bonus(int id)
{
    return 1.0 + (float(medals[id]) * 0.022);
}

int scxpm_get_effective_health(int id)
{
    float bonus = scxpm_medal_bonus(id);
    int shealth = starthealth[id];
    return floatround(float(shealth + health[id]) * bonus);
}

int scxpm_get_effective_armor(int id)
{
    float bonus = scxpm_medal_bonus(id);
    int sarmor = startarmor[id];
    return floatround(float(sarmor + armor[id]) * bonus);
}

int scxpm_get_block_chance(int id)
{
    int chance = dodge[id] / 3;
    if (chance > 100) chance = 100;
    chance = floatround(float(chance) * scxpm_medal_bonus(id));
    return chance > 100 ? 100 : chance;
}

float scxpm_get_gravity(int id)
{
    float grav = 1.0 - (float(gravity[id]) * 0.015);
    if (grav < 0.1) grav = 0.1;
    float bonus = scxpm_medal_bonus(id);
    float result = grav * (1.0 - (bonus - 1.0) * 0.5);
    return result < 0.05 ? 0.05 : result;
}

// ========== AMMO FUNCTIONS ==========

void scxpm_randomammo(int id, CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    int number = Math.RandomLong(0, 6);
    
    if (number == 0)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_9MM);
        if (ammo < 250)
        {
            GiveItem(pPlayer, "ammo_9mmclip");
            GiveItem(pPlayer, "ammo_9mmclip");
        }
        else
            number = 1;
    }
    if (number == 1)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_357);
        if (ammo < 36)
        {
            GiveItem(pPlayer, "ammo_357");
            GiveItem(pPlayer, "ammo_357");
        }
        else
            number = 2;
    }
    if (number == 2)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_BUCKSHOT);
        if (ammo < 125)
        {
            GiveItem(pPlayer, "ammo_buckshot");
            GiveItem(pPlayer, "ammo_buckshot");
        }
        else
            number = 3;
    }
    if (number == 3)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_GAUSS);
        if (ammo < 100)
        {
            GiveItem(pPlayer, "ammo_gaussclip");
            GiveItem(pPlayer, "ammo_gaussclip");
        }
        else
            number = 4;
    }
    if (number == 4)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_CROSSBOW);
        if (ammo < 50)
        {
            GiveItem(pPlayer, "ammo_crossbow");
            GiveItem(pPlayer, "ammo_crossbow");
        }
        else
            number = 5;
    }
    if (number == 5)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_RPG);
        if (ammo < 5)
        {
            GiveItem(pPlayer, "ammo_rpgclip");
            GiveItem(pPlayer, "ammo_rpgclip");
        }
        else
            number = 6;
    }
    if (number == 6)
    {
        int ammo = pPlayer.m_rgAmmo(AMMO_762);
        if (ammo < 15)
        {
            GiveItem(pPlayer, "ammo_762");
            GiveItem(pPlayer, "ammo_762");
        }
        else
        {
            GiveItem(pPlayer, "ammo_556");
            GiveItem(pPlayer, "ammo_556");
            GiveItem(pPlayer, "ammo_556");
            GiveItem(pPlayer, "ammo_556");
        }
    }
}

void scxpm_give_ammo(int id, CBasePlayer@ pPlayer, int weaponId)
{
    if (pPlayer is null) return;
    
    if (weaponId == WEAPON_GLOCK)
    {
        if (pPlayer.m_rgAmmo(AMMO_9MM) < 250)
        {
            GiveItem(pPlayer, "ammo_9mmclip");
            GiveItem(pPlayer, "ammo_9mmclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_357 || weaponId == WEAPON_DESERT_EAGLE)
    {
        if (pPlayer.m_rgAmmo(AMMO_357) < 36)
        {
            GiveItem(pPlayer, "ammo_357");
            GiveItem(pPlayer, "ammo_357");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_MP5)
    {
        if (pPlayer.m_rgAmmo(AMMO_9MM) < 250)
        {
            GiveItem(pPlayer, "ammo_9mmAR");
            GiveItem(pPlayer, "ammo_9mmAR");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_CROSSBOW)
    {
        if (pPlayer.m_rgAmmo(AMMO_CROSSBOW) < 50)
        {
            GiveItem(pPlayer, "ammo_crossbow");
            GiveItem(pPlayer, "ammo_crossbow");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_SHOTGUN)
    {
        if (pPlayer.m_rgAmmo(AMMO_BUCKSHOT) < 125)
        {
            GiveItem(pPlayer, "ammo_buckshot");
            GiveItem(pPlayer, "ammo_buckshot");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_RPG)
    {
        if (pPlayer.m_rgAmmo(AMMO_RPG) < 5)
        {
            GiveItem(pPlayer, "ammo_rpgclip");
            GiveItem(pPlayer, "ammo_rpgclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_GAUSS || weaponId == WEAPON_EGON)
    {
        if (pPlayer.m_rgAmmo(AMMO_GAUSS) < 100)
        {
            GiveItem(pPlayer, "ammo_gaussclip");
            GiveItem(pPlayer, "ammo_gaussclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_DISPLACER)
    {
        if (pPlayer.m_rgAmmo(AMMO_GAUSS) < 100)
        {
            GiveItem(pPlayer, "ammo_gaussclip");
            GiveItem(pPlayer, "ammo_gaussclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_UZI || weaponId == WEAPON_UZIAKIMBO)
    {
        if (pPlayer.m_rgAmmo(AMMO_9MM) < 250)
        {
            GiveItem(pPlayer, "ammo_uziclip");
            GiveItem(pPlayer, "ammo_uziclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_MINIGUN)
    {
        if (pPlayer.m_rgAmmo(AMMO_556) < 600)
        {
            GiveItem(pPlayer, "ammo_556");
            GiveItem(pPlayer, "ammo_556");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_SNIPERRIFLE)
    {
        if (pPlayer.m_rgAmmo(AMMO_762) < 15)
        {
            GiveItem(pPlayer, "ammo_762");
            GiveItem(pPlayer, "ammo_762");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else if (weaponId == WEAPON_M249)
    {
        if (pPlayer.m_rgAmmo(AMMO_556) < 600)
        {
            GiveItem(pPlayer, "ammo_556");
            GiveItem(pPlayer, "ammo_556");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
	else if (weaponId == WEAPON_M16)
	{
		bool needAmmo556 = (pPlayer.m_rgAmmo(AMMO_556) < 600);
		bool needARgrenades = (pPlayer.m_rgAmmo(AMMO_ARGRENADES) < 10);
		
		if (!needAmmo556 && !needARgrenades)
		{
			scxpm_randomammo(id, pPlayer);
		}
		else
		{
			switch ((needAmmo556 ? 1 : 0) | (needARgrenades ? 2 : 0))
			{
				case 1:
					GiveItem(pPlayer, "ammo_556clip");
					GiveItem(pPlayer, "ammo_556clip");
					break;
				case 2:
					GiveItem(pPlayer, "ammo_ARgrenades");
					break;
				case 3:
					GiveItem(pPlayer, "ammo_556clip");
					GiveItem(pPlayer, "ammo_556clip");
					GiveItem(pPlayer, "ammo_ARgrenades");
					break;
			}
		}
	}
    else if (weaponId == WEAPON_SPORELAUNCHER)
    {
        if (pPlayer.m_rgAmmo(AMMO_SPORECLIP) < 30)
        {
            GiveItem(pPlayer, "ammo_sporeclip");
            GiveItem(pPlayer, "ammo_sporeclip");
            GiveItem(pPlayer, "ammo_sporeclip");
        }
        else
            scxpm_randomammo(id, pPlayer);
    }
    else
    {
        scxpm_randomammo(id, pPlayer);
    }
}

int GiveItem(CBasePlayer@ pPlayer, const string& in szItem)
{
    if (pPlayer is null) return 0;
    
    if (!szItem.StartsWith("weapon_") && !szItem.StartsWith("ammo_") && !szItem.StartsWith("item_"))
        return 0;
    
    CBaseEntity@ pEntity = g_EntityFuncs.Create(szItem, g_vecZero, g_vecZero, true);
    if (pEntity is null) return 0;
    
    Vector vecOrigin = pPlayer.pev.origin;
    g_EntityFuncs.SetOrigin(pEntity, vecOrigin);
    pEntity.pev.spawnflags |= SF_NORESPAWN;
    g_EntityFuncs.DispatchSpawn(pEntity.edict());
    
    int iSolid = pEntity.pev.solid;
    pEntity.Touch(pPlayer);
    if (pEntity.pev.solid != iSolid)
        return pEntity.entindex();
    
    g_EntityFuncs.Remove(pEntity);
    return -1;
}

// ========== SKILL UPGRADE FUNCTIONS ==========

void scxpm_upgrade_skill_amount(CBasePlayer@ pPlayer, int skillNum, int amount)
{
    if (pPlayer is null) return;
    int id = pPlayer.entindex();
    
    if (skillpoints[id] <= 0 || amount <= 0) return;
    
    int maxValue = 0, currentValue = 0;
    string skillName;
    
    switch(skillNum)
    {
        case 1: skillName = "Strength"; currentValue = health[id]; maxValue = MAX_HEALTH; break;
        case 2: skillName = "Superior Armor"; currentValue = armor[id]; maxValue = MAX_ARMOR; break;
        case 3: skillName = "Regeneration"; currentValue = rhealth[id]; maxValue = MAX_RHEALTH; break;
        case 4: skillName = "Nano Armor"; currentValue = rarmor[id]; maxValue = MAX_RARMOR; break;
        case 5: skillName = "Ammo Reincarnation"; currentValue = rammo[id]; maxValue = MAX_RAMMO; break;
        case 6: skillName = "Anti Gravity Device"; currentValue = gravity[id]; maxValue = MAX_GRAVITY; break;
        case 7: skillName = "Awareness"; currentValue = speed[id]; maxValue = MAX_SPEED; break;
        case 8: skillName = "Team Power"; currentValue = dist[id]; maxValue = MAX_DIST; break;
        case 9: skillName = "Block Attack"; currentValue = dodge[id]; maxValue = MAX_DODGE; break;
        default: return;
    }
    
    int maxPossible = maxValue - currentValue;
    int toUpgrade = amount;
    if (toUpgrade > maxPossible) toUpgrade = maxPossible;
    if (toUpgrade > skillpoints[id]) toUpgrade = skillpoints[id];
    
    if (toUpgrade <= 0)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] " + skillName + " is already at max level!\n");
        return;
    }
    
    skillpoints[id] -= toUpgrade;
    
    switch(skillNum)
    {
        case 1: 
            health[id] += toUpgrade;
            break;
        case 2: 
            armor[id] += toUpgrade;
            break;
        case 3: rhealth[id] += toUpgrade; break;
        case 4: rarmor[id] += toUpgrade; break;
        case 5: rammo[id] += toUpgrade; break;
        case 6: 
            gravity[id] += toUpgrade;
            if (pPlayer.IsAlive())
                pPlayer.pev.gravity = scxpm_get_gravity(id);
            break;
        case 7: speed[id] += toUpgrade; break;
        case 8: dist[id] += toUpgrade; break;
        case 9: dodge[id] += toUpgrade; break;
    }
    
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] " + skillName + " upgraded by " + toUpgrade + " levels! Now: " + (currentValue + toUpgrade) + "/" + maxValue + "\n");
    
    if (pPlayer.IsAlive() && (skillNum == 1 || skillNum == 2))
    {
        if (skillNum == 1)
        {
            int newMax = scxpm_get_effective_health(id);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Your maximum health is now " + newMax + " HP\n");
        }
        else if (skillNum == 2)
        {
            int newMax = scxpm_get_effective_armor(id);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Your maximum armor is now " + newMax + " AP\n");
        }
    }
    
    scxpm_savedata(id, true);
}

void scxpm_upgrade_skill_max(CBasePlayer@ pPlayer, int skillNum)
{
    if (pPlayer is null) return;
    int id = pPlayer.entindex();
    
    if (skillpoints[id] <= 0) return;
    
    int maxValue = 0, currentValue = 0;
    string skillName;
    
    switch(skillNum)
    {
        case 1: skillName = "Strength"; currentValue = health[id]; maxValue = MAX_HEALTH; break;
        case 2: skillName = "Superior Armor"; currentValue = armor[id]; maxValue = MAX_ARMOR; break;
        case 3: skillName = "Regeneration"; currentValue = rhealth[id]; maxValue = MAX_RHEALTH; break;
        case 4: skillName = "Nano Armor"; currentValue = rarmor[id]; maxValue = MAX_RARMOR; break;
        case 5: skillName = "Ammo Reincarnation"; currentValue = rammo[id]; maxValue = MAX_RAMMO; break;
        case 6: skillName = "Anti Gravity Device"; currentValue = gravity[id]; maxValue = MAX_GRAVITY; break;
        case 7: skillName = "Awareness"; currentValue = speed[id]; maxValue = MAX_SPEED; break;
        case 8: skillName = "Team Power"; currentValue = dist[id]; maxValue = MAX_DIST; break;
        case 9: skillName = "Block Attack"; currentValue = dodge[id]; maxValue = MAX_DODGE; break;
        default: return;
    }
    
    int maxPossible = maxValue - currentValue;
    int toUpgrade = maxPossible;
    if (toUpgrade > skillpoints[id]) toUpgrade = skillpoints[id];
    
    if (toUpgrade <= 0)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] " + skillName + " is already at max level!\n");
        return;
    }
    
    skillpoints[id] -= toUpgrade;
    
    switch(skillNum)
    {
        case 1: 
            health[id] += toUpgrade;
            break;
        case 2: 
            armor[id] += toUpgrade;
            break;
        case 3: rhealth[id] += toUpgrade; break;
        case 4: rarmor[id] += toUpgrade; break;
        case 5: rammo[id] += toUpgrade; break;
        case 6: 
            gravity[id] += toUpgrade;
            if (pPlayer.IsAlive())
                pPlayer.pev.gravity = scxpm_get_gravity(id);
            break;
        case 7: speed[id] += toUpgrade; break;
        case 8: dist[id] += toUpgrade; break;
        case 9: dodge[id] += toUpgrade; break;
    }
    
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] " + skillName + " upgraded by " + toUpgrade + " levels! (MAX) Now: " + (currentValue + toUpgrade) + "/" + maxValue + "\n");
    
    if (pPlayer.IsAlive() && (skillNum == 1 || skillNum == 2))
    {
        if (skillNum == 1)
        {
            int newMax = scxpm_get_effective_health(id);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Your maximum health is now " + newMax + " HP\n");
        }
        else if (skillNum == 2)
        {
            int newMax = scxpm_get_effective_armor(id);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Your maximum armor is now " + newMax + " AP\n");
        }
    }
    
    scxpm_savedata(id, true);
}

void scxpm_auto_max_skills(CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    int id = pPlayer.entindex();
    
    if (health[id] >= MAX_HEALTH && armor[id] >= MAX_ARMOR && 
        rhealth[id] >= MAX_RHEALTH && rarmor[id] >= MAX_RARMOR &&
        rammo[id] >= MAX_RAMMO && gravity[id] >= MAX_GRAVITY &&
        speed[id] >= MAX_SPEED && dist[id] >= MAX_DIST && 
        dodge[id] >= MAX_DODGE)
        return;
    
    int totalSpent = 0;
    
    if (health[id] < MAX_HEALTH) { totalSpent += MAX_HEALTH - health[id]; health[id] = MAX_HEALTH; }
    if (armor[id] < MAX_ARMOR) { totalSpent += MAX_ARMOR - armor[id]; armor[id] = MAX_ARMOR; }
    if (rhealth[id] < MAX_RHEALTH) { totalSpent += MAX_RHEALTH - rhealth[id]; rhealth[id] = MAX_RHEALTH; }
    if (rarmor[id] < MAX_RARMOR) { totalSpent += MAX_RARMOR - rarmor[id]; rarmor[id] = MAX_RARMOR; }
    if (rammo[id] < MAX_RAMMO) { totalSpent += MAX_RAMMO - rammo[id]; rammo[id] = MAX_RAMMO; }
    if (gravity[id] < MAX_GRAVITY)
    {
        totalSpent += MAX_GRAVITY - gravity[id];
        gravity[id] = MAX_GRAVITY;
        if (pPlayer.IsAlive())
            pPlayer.pev.gravity = scxpm_get_gravity(id);
    }
    if (speed[id] < MAX_SPEED) { totalSpent += MAX_SPEED - speed[id]; speed[id] = MAX_SPEED; }
    if (dist[id] < MAX_DIST) { totalSpent += MAX_DIST - dist[id]; dist[id] = MAX_DIST; }
    if (dodge[id] < MAX_DODGE) { totalSpent += MAX_DODGE - dodge[id]; dodge[id] = MAX_DODGE; }
    
    if (totalSpent > 0)
    {
        skillpoints[id] -= totalSpent;
        if (skillpoints[id] < 0) skillpoints[id] = 0;
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Congratulations! All your skills have been automatically maxed out!\n");
        scxpm_savedata(id, true);
    }
}

void scxpm_reset_skills(CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    int id = pPlayer.entindex();
    
    int totalPoints = health[id] + armor[id] + rhealth[id] + rarmor[id] + 
                      rammo[id] + gravity[id] + speed[id] + dist[id] + dodge[id];
    skillpoints[id] += totalPoints;
    
    health[id] = 0;
    armor[id] = 0;
    rhealth[id] = 0;
    rarmor[id] = 0;
    rammo[id] = 0;
    gravity[id] = 0;
    speed[id] = 0;
    dist[id] = 0;
    dodge[id] = 0;
    
    if (pPlayer.IsAlive())
    {
        int newHealth = scxpm_get_effective_health(id);
        int newArmor = scxpm_get_effective_armor(id);
        
        if (pPlayer.pev.health > newHealth)
            pPlayer.pev.health = newHealth;
        if (pPlayer.pev.armorvalue > newArmor)
            pPlayer.pev.armorvalue = newArmor;
        pPlayer.pev.gravity = 1.0;
    }
    
    scxpm_getrank(id);
    
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] All skills reset! Returned " + totalPoints + " skillpoints.\n");
    scxpm_savedata(id, true);
}

// ========== MENU HANDLER ==========
class MenuHandler
{
    CTextMenu@ menu;
    
    void InitMenu(CBasePlayer@ pPlayer, TextMenuPlayerSlotCallback@ callback)
    {
        CTextMenu temp(@callback);
        @menu = @temp;
    }
    
    void OpenMenu(CBasePlayer@ pPlayer, int time, int page)
    {
        menu.Register();
        menu.Open(time, page, pPlayer);
    }
}

MenuHandler@ MenuGetPlayer(CBasePlayer@ pPlayer)
{
    string steamid = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if (steamid == 'STEAM_ID_LAN')
        steamid = string(pPlayer.pev.netname);
    
    if (!pmenu_state.exists(steamid))
    {
        MenuHandler state;
        pmenu_state[steamid] = state;
    }
    return cast<MenuHandler@>(pmenu_state[steamid]);
}

// ========== DELAYED MENU OPEN FUNCTIONS ==========
void SCXPM_ShowMainMenuDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowMainMenu(pPlayer);
}

void SCXPM_ShowStatsMenuDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowStatsMenu(pPlayer);
}

void SCXPM_ShowSkillSelectionMenuDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowSkillSelectionMenu(pPlayer);
}

void SCXPM_ShowUpgradeConfirmMenuDelayed(EHandle hPlayer, int skillNum)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowUpgradeConfirmMenu(pPlayer, skillNum);
}

void SCXPM_ShowHUDSettingsDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowHUDSettings(pPlayer);
}

void SCXPM_ShowSkillsInfoMenuDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowSkillsInfoMenu(pPlayer);
}

void SCXPM_ShowIncrementMenuDelayed(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
        SCXPM_ShowIncrementMenu(pPlayer);
}

// ========== MENU FUNCTIONS ==========

void SCXPM_ShowSkillSelectionMenu(CBasePlayer@ pPlayer)
{
    int id = pPlayer.entindex();
    
    if (skillpoints[id] <= 0)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] No skill points!\n");
        return;
    }
    
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, SkillSelectionMenuCallback);
    
    string title = "=== UPGRADE SKILLS ===\n";
    title += "Available Skillpoints: " + skillpoints[id] + "\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("Strength [ " + health[id] + "/" + MAX_HEALTH + " ]", any(1)); 
    state.menu.AddItem("Superior Armor [ " + armor[id] + "/" + MAX_ARMOR + " ]", any(2));
    state.menu.AddItem("Regeneration [ " + rhealth[id] + "/" + MAX_RHEALTH + " ]", any(3));
    state.menu.AddItem("Nano Armor [ " + rarmor[id] + "/" + MAX_RARMOR + " ]", any(4));
    state.menu.AddItem("Ammo Reincarnation [ " + rammo[id] + "/" + MAX_RAMMO + " ]", any(5));
    state.menu.AddItem("Anti-Gravity Device [ " + gravity[id] + "/" + MAX_GRAVITY + " ]", any(6));
    state.menu.AddItem("Awareness [ " + speed[id] + "/" + MAX_SPEED + " ]", any(7));
    state.menu.AddItem("Team Power [ " + dist[id] + "/" + MAX_DIST + " ]", any(8));
    state.menu.AddItem("Block Attack [ " + dodge[id] + "/" + MAX_DODGE + " ]", any(9));
    
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowUpgradeConfirmMenu(CBasePlayer@ pPlayer, int skillNum)
{
    int id = pPlayer.entindex();
    
    int maxValue = 0, currentValue = 0;
    string skillName;
    
    switch(skillNum)
    {
        case 1: skillName = "Strength"; currentValue = health[id]; maxValue = MAX_HEALTH; break;
        case 2: skillName = "Superior Armor"; currentValue = armor[id]; maxValue = MAX_ARMOR; break;
        case 3: skillName = "Regeneration"; currentValue = rhealth[id]; maxValue = MAX_RHEALTH; break;
        case 4: skillName = "Nano Armor"; currentValue = rarmor[id]; maxValue = MAX_RARMOR; break;
        case 5: skillName = "Ammo Reincarnation"; currentValue = rammo[id]; maxValue = MAX_RAMMO; break;
        case 6: skillName = "Anti Gravity Device"; currentValue = gravity[id]; maxValue = MAX_GRAVITY; break;
        case 7: skillName = "Awareness"; currentValue = speed[id]; maxValue = MAX_SPEED; break;
        case 8: skillName = "Team Power"; currentValue = dist[id]; maxValue = MAX_DIST; break;
        case 9: skillName = "Block Attack"; currentValue = dodge[id]; maxValue = MAX_DODGE; break;
        default: return;
    }
    
    int maxPossible = maxValue - currentValue;
    int maxUpgrade = skillIncrement[id];
    if (maxUpgrade > maxPossible) maxUpgrade = maxPossible;
    if (maxUpgrade > skillpoints[id]) maxUpgrade = skillpoints[id];
    
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, UpgradeConfirmMenuCallback);
    
    string title = "=== UPGRADE " + skillName + " ===\n\n";
    title += "Current Level: " + currentValue + " / " + maxValue + "\n";
    title += "Available Skillpoints: " + skillpoints[id] + "\n";
    title += "Current increment: " + skillIncrement[id] + " point(s)\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("Upgrade " + skillIncrement[id] + " point(s) (" + maxUpgrade + " max)", any(skillNum));
    state.menu.AddItem("Upgrade to MAX (up to " + maxPossible + " points)", any(skillNum + 100));
    state.menu.AddItem("Change Increment Amount", any(999));
    state.menu.AddItem("Back", any(0));
    
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowIncrementMenu(CBasePlayer@ pPlayer)
{
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, IncrementChoiceMenuCallback);
    
    int id = pPlayer.entindex();
    string title = "=== SELECT INCREMENT AMOUNT ===\n\n";
    title += "Current increment: " + skillIncrement[id] + "\n\n";
    title += "Choose how many skill points\nto spend per upgrade:\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("1 point", any(1));
    state.menu.AddItem("5 points", any(5));
    state.menu.AddItem("10 points", any(10));
    state.menu.AddItem("25 points", any(25));
    state.menu.AddItem("50 points", any(50));
    state.menu.AddItem("100 points", any(100));
    state.menu.AddItem("Back", any(0));
    
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowStatsMenu(CBasePlayer@ pPlayer)
{
    int id = pPlayer.entindex();
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, StatsMenuCallback);
    
    string title = "=== SCXPM STATISTICS ===\n\n";
    title += "Level: " + playerlevel[id] + " / " + MAX_LEVEL + "\n";
    title += "Rank: " + rank[id] + "\n";
    title += "XP: " + AddCommas(xp[id]) + " / " + AddCommas(neededxp[id]) + "\n";
    title += "Frags: " + int(pPlayer.pev.frags) + "\n";
    title += "Total Frags: " + totalFrags[id] + "\n";
    title += "Medals: " + medals[id] + " / " + MAX_MEDALS + " (+" + int(medals[id] * 2.2) + "% bonus)\n";
    title += "Skill Points: " + skillpoints[id] + "\n\n";
    title += "=== SKILLS ===\n";
    title += "Strength: " + health[id] + "/" + MAX_HEALTH + "\n";
    title += "Superior Armor: " + armor[id] + "/" + MAX_ARMOR + "\n";
    title += "Regeneration: " + rhealth[id] + "/" + MAX_RHEALTH + "\n";
    title += "Nano Armor: " + rarmor[id] + "/" + MAX_RARMOR + "\n";
    title += "Ammo Reincarnation: " + rammo[id] + "/" + MAX_RAMMO + "\n";
    title += "Anti Gravity: " + gravity[id] + "/" + MAX_GRAVITY + " (" + int(gravity[id]*1.5) + "%)\n";
    title += "Awareness: " + speed[id] + "/" + MAX_SPEED + "\n";
    title += "Team Power: " + dist[id] + "/" + MAX_DIST + "\n";
    title += "Block Attack: " + dodge[id] + "/" + MAX_DODGE + " (" + scxpm_get_block_chance(id) + "%)\n\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("Back", any(0));
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowSkillsInfoMenu(CBasePlayer@ pPlayer)
{
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, SkillsInfoMenuCallback);
    
    string title = "== SKILLS INFORMATION ==\n\n\n";
    title += "Strength: +1 HP per level\n";
    title += "   Max: " + MAX_HEALTH + " (+" + MAX_HEALTH + " HP)\n\n";
    title += "Superior Armor: +1 AP per level\n";
    title += "   Max: " + MAX_ARMOR + " (+" + MAX_ARMOR + " AP)\n\n";
    title += "Regeneration: Health regeneration\n";
    title += "   Max: " + MAX_RHEALTH + "\n\n";
    title += "Nano Armor: Armor regeneration\n";
    title += "   Max: " + MAX_RARMOR + "\n\n";
    title += "Ammo Reincarnation: Ammo regeneration\n";
    title += "   Max: " + MAX_RAMMO + "\n\n";
    title += "Anti Gravity: -1.5% gravity per level (hold jump)\n";
    title += "   Max: " + MAX_GRAVITY + " (" + int(MAX_GRAVITY * 1.5) + "% reduction)\n\n";
    title += "Awareness: Enhances other skills\n";
    title += "   Max: " + MAX_SPEED + "\n\n";
    title += "Team Power: Heals nearby teammates\n";
    title += "   Max: " + MAX_DIST + "\n\n";
    title += "Block Attack: Chance to block damage\n";
    title += "   Max: " + MAX_DODGE + " (" + (MAX_DODGE / 3) + "% chance)\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("Back", any(0));
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowHUDSettings(CBasePlayer@ pPlayer)
{
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, HUDSettingsCallback);
    
    int id = pPlayer.entindex();
    string title = "=== HUD SETTINGS ===\n\n";
    title += "Current X: " + hud_pos_x[id] + "\n";
    title += "Current Y: " + hud_pos_y[id] + "\n\n";
    title += "Use the options below to move the HUD\n";
    title += "Default position: X=0.65, Y=0.04";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("Move Up (Y -0.01)", any(1));
    state.menu.AddItem("Move Down (Y +0.01)", any(2));
    state.menu.AddItem("Move Left (X -0.01)", any(3));
    state.menu.AddItem("Move Right (X +0.01)", any(4));
    state.menu.AddItem("Reset to Default", any(5));
    state.menu.AddItem("Back", any(0));
    
    state.OpenMenu(pPlayer, 0, 0);
}

void SCXPM_ShowMainMenu(CBasePlayer@ pPlayer)
{
    MenuHandler@ state = MenuGetPlayer(pPlayer);
    state.InitMenu(pPlayer, MainMenuCallback);
    
    string title = "=== SCXPM v" + SCXPM_VERSION + " ===\n";
    title += "Select an option:\n";
    
    state.menu.SetTitle(title);
    state.menu.AddItem("My Statistics", any(1));
    state.menu.AddItem("Upgrade Skills", any(2));
    state.menu.AddItem("Reset All Skills", any(3));
    state.menu.AddItem("HUD Settings", any(4));
    state.menu.AddItem("Skills Information", any(5));
    state.menu.AddItem("Players List", any(6));
    
    state.OpenMenu(pPlayer, 0, 0);
}

// ========== MENU CALLBACKS ==========

void MainMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    switch(choice)
    {
        case 1:
            g_Scheduler.SetTimeout("SCXPM_ShowStatsMenuDelayed", 0.01, EHandle(pPlayer));
            break;
        case 2:
            g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
            break;
        case 3:
            scxpm_reset_skills(pPlayer);
            g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
            break;
        case 4:
            g_Scheduler.SetTimeout("SCXPM_ShowHUDSettingsDelayed", 0.01, EHandle(pPlayer));
            break;
        case 5:
            g_Scheduler.SetTimeout("SCXPM_ShowSkillsInfoMenuDelayed", 0.01, EHandle(pPlayer));
            break;
        case 6:
            scxpm_playerslist_command(pPlayer);
            g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
            break;
    }
}

void IncrementChoiceMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int id = pPlayer.entindex();
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    if (choice == 0)
    {
        if (lastSelectedSkill[id] >= 1 && lastSelectedSkill[id] <= 9)
        {
            g_Scheduler.SetTimeout("SCXPM_ShowUpgradeConfirmMenuDelayed", 0.01, EHandle(pPlayer), lastSelectedSkill[id]);
        }
        else
        {
            g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
        }
    }
    else if (choice == 1 || choice == 5 || choice == 10 || choice == 25 || choice == 50 || choice == 100)
    {
        skillIncrement[id] = choice;
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Increment set to: " + choice + " point(s)\n");
        if (lastSelectedSkill[id] >= 1 && lastSelectedSkill[id] <= 9)
        {
            g_Scheduler.SetTimeout("SCXPM_ShowUpgradeConfirmMenuDelayed", 0.01, EHandle(pPlayer), lastSelectedSkill[id]);
        }
        else
        {
            g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
        }
    }
}

void SkillSelectionMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int id = pPlayer.entindex();
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    if (choice == 0)
    {
        g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
    }
    else if (choice >= 1 && choice <= 9)
    {
        lastSelectedSkill[id] = choice;
        g_Scheduler.SetTimeout("SCXPM_ShowUpgradeConfirmMenuDelayed", 0.01, EHandle(pPlayer), choice);
    }
}

void UpgradeConfirmMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int id = pPlayer.entindex();
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    if (choice == 0)
    {
        g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
    }
    else if (choice == 999)
    {
        g_Scheduler.SetTimeout("SCXPM_ShowIncrementMenuDelayed", 0.01, EHandle(pPlayer));
    }
    else if (choice >= 1 && choice <= 9)
    {
        scxpm_upgrade_skill_amount(pPlayer, choice, skillIncrement[id]);
        
        int newValue = 0, maxValue = 0;
        switch(choice)
        {
            case 1: newValue = health[id]; maxValue = MAX_HEALTH; break;
            case 2: newValue = armor[id]; maxValue = MAX_ARMOR; break;
            case 3: newValue = rhealth[id]; maxValue = MAX_RHEALTH; break;
            case 4: newValue = rarmor[id]; maxValue = MAX_RARMOR; break;
            case 5: newValue = rammo[id]; maxValue = MAX_RAMMO; break;
            case 6: newValue = gravity[id]; maxValue = MAX_GRAVITY; break;
            case 7: newValue = speed[id]; maxValue = MAX_SPEED; break;
            case 8: newValue = dist[id]; maxValue = MAX_DIST; break;
            case 9: newValue = dodge[id]; maxValue = MAX_DODGE; break;
        }
        
        if (newValue < maxValue && skillpoints[id] > 0)
        {
            lastSelectedSkill[id] = choice;
            g_Scheduler.SetTimeout("SCXPM_ShowUpgradeConfirmMenuDelayed", 0.01, EHandle(pPlayer), choice);
        }
        else
        {
            g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
        }
    }
    else if (choice >= 100 && choice <= 109)
    {
        int skillNum = choice - 100;
        scxpm_upgrade_skill_max(pPlayer, skillNum);
        g_Scheduler.SetTimeout("SCXPM_ShowSkillSelectionMenuDelayed", 0.01, EHandle(pPlayer));
    }
}

void SkillsInfoMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    if (choice == 0)
    {
        g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
    }
}

void HUDSettingsCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int id = pPlayer.entindex();
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    switch(choice)
    {
        case 1:
            hud_pos_y[id] -= 0.01;
            if (hud_pos_y[id] < 0.0) hud_pos_y[id] = 0.0;
            break;
        case 2:
            hud_pos_y[id] += 0.01;
            if (hud_pos_y[id] > 1.0) hud_pos_y[id] = 1.0;
            break;
        case 3:
            hud_pos_x[id] -= 0.01;
            if (hud_pos_x[id] < 0.0) hud_pos_x[id] = 0.0;
            break;
        case 4:
            hud_pos_x[id] += 0.01;
            if (hud_pos_x[id] > 1.0) hud_pos_x[id] = 1.0;
            break;
        case 5:
            hud_pos_x[id] = 0.65;
            hud_pos_y[id] = 0.04;
            break;
        case 0:
            g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
            return;
    }
    
    g_Scheduler.SetTimeout("SCXPM_ShowHUDSettingsDelayed", 0.01, EHandle(pPlayer));
}

void StatsMenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item)
{
    if (item is null || item.m_pUserData is null) return;
    
    int choice = 0;
    if (!item.m_pUserData.retrieve(choice)) return;
    
    if (choice == 0)
    {
        g_Scheduler.SetTimeout("SCXPM_ShowMainMenuDelayed", 0.01, EHandle(pPlayer));
    }
}

// ========== HUD FUNCTIONS ==========

void scxpm_showdata()
{
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer is null) continue;
        
        int id = pPlayer.entindex();
        string hudtext;
        
        if (playerlevel[id] == MAX_LEVEL)
        {
            hudtext = "Level: 1800 / 1800\nRank: Highest Force Leader\nMedals: " + medals[id] + " / " + MAX_MEDALS;
        }
        else
        {
            hudtext = "Exp.: " + AddCommas(xp[id]) + " / " + AddCommas(neededxp[id]) + " (+" + AddCommas(neededxp[id] - xp[id]) + ")\n";
            hudtext += "Level: " + playerlevel[id] + " / " + MAX_LEVEL + "\n";
            hudtext += "Rank: " + rank[id] + "\n";
            hudtext += "Medals: " + medals[id] + " / " + MAX_MEDALS;
        }
        
        HUDTextParams textParams;
        textParams.x = hud_pos_x[id];
        textParams.y = hud_pos_y[id];
        textParams.effect = 0;
        textParams.r1 = 50;
        textParams.g1 = 135;
        textParams.b1 = 180;
        textParams.a1 = 0;
        textParams.fadeinTime = 0.0;
        textParams.fadeoutTime = 0.0;
        textParams.holdTime = 255.0;
        textParams.fxTime = 0.0;
        textParams.channel = 3;
        
        g_PlayerFuncs.HudMessage(pPlayer, textParams, hudtext);
    }
}

// ========== REGENERATION ==========

void scxpm_regen()
{
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer is null || !pPlayer.IsAlive()) continue;
        
        int id = pPlayer.entindex();
        int halfspeed = speed[id] / 2;
        float medalBonus = scxpm_medal_bonus(id);
        
        if (rhealth[id] > 0)
        {
            int maxHealth = floatround(float(starthealth[id] + health[id] + (speed[id] / 2)) * medalBonus);
            if (rhealthwait[id] == 0)
            {
                if (pPlayer.pev.health < maxHealth)
                {
                    pPlayer.pev.health++;
                    rhealthwait[id] = 300 - rhealth[id];
                }
            }
            else
            {
                rhealthwait[id]--;
                if (pPlayer.pev.health < maxHealth && Math.RandomLong(0, 200 + rhealth[id]) > 200)
                {
                    pPlayer.pev.health++;
                }
            }
        }

        if (rarmor[id] > 0)
        {
            int maxArmor = floatround(float(startarmor[id] + armor[id] + (speed[id] / 2)) * medalBonus);
            if (rarmorwait[id] == 0)
            {
                if (pPlayer.pev.armorvalue < maxArmor)
                {
                    pPlayer.pev.armorvalue++;
                    rarmorwait[id] = 300 - rarmor[id];
                }
            }
            else
            {
                rarmorwait[id]--;
                if (pPlayer.pev.armorvalue < maxArmor && Math.RandomLong(0, 200 + rarmor[id]) > 200)
                {
                    pPlayer.pev.armorvalue++;
                }
            }
        }
        
        if (rammo[id] > 0)
        {
            if (ammowait[id] <= 0)
            {
                CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
                if (pWeapon !is null)
                {
                    scxpm_give_ammo(id, pPlayer, pWeapon.m_iId);
                }
                else
                {
                    scxpm_randomammo(id, pPlayer);
                }
                ammowait[id] = 179 - (5 * rammo[id]) - (speed[id] / 18);
                if (ammowait[id] < 8) ammowait[id] = 8;
            }
            else
            {
                ammowait[id]--;
            }
        }
        
        CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
        if (pWeapon !is null && pWeapon.m_iId == WEAPON_MEDKIT)
        {
            int maxHealth = floatround(float(starthealth[id] + health[id] + halfspeed) * medalBonus);
            if (pPlayer.pev.health < 100)
            {
                if (Math.RandomLong(rhealth[id], 800 - int(pPlayer.pev.health)) > 299)
                    pPlayer.pev.health++;
            }
            else if (pPlayer.pev.health < maxHealth && Math.RandomLong(0, 1300 + rhealth[id]) > 1200)
                pPlayer.pev.health++;
        }
    }
}

// ========== TEAM POWER ==========

void scxpm_team_power()
{
    array<CBasePlayer@> players;
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ p = g_PlayerFuncs.FindPlayerByIndex(i);
        if (p !is null && p.IsAlive())
            players.insertLast(p);
    }
    
    for (uint a = 0; a < players.length(); a++)
    {
        CBasePlayer@ pSource = players[a];
        int id = pSource.entindex();
        
        if (dist[id] <= 0) continue;
        
        int halfspeed = speed[id] / 2;
        
        for (uint b = 0; b < players.length(); b++)
        {
            if (a == b) continue;
            CBasePlayer@ pTarget = players[b];
            
            float distance = (pSource.pev.origin - pTarget.pev.origin).Length();
            if (distance <= 650.0)
            {
                int targetId = pTarget.entindex();
                int maxHealth = scxpm_get_effective_health(targetId) + halfspeed;
                int maxArmor = scxpm_get_effective_armor(targetId) + halfspeed;
                
                if (Math.RandomLong(0, 4200 + dist[id]) > 4200)
                {
                    if (pTarget.pev.health < maxHealth)
                        pTarget.pev.health++;
                    if (pTarget.pev.armorvalue < maxArmor)
                        pTarget.pev.armorvalue++;
                }
                
                if (dist[id] >= 40 && Math.RandomLong(0, 1000 + dist[id]) > 1038)
                {
                    if (pSource.pev.health < maxHealth)
                        pSource.pev.health++;
                    if (pSource.pev.armorvalue < maxArmor)
                        pSource.pev.armorvalue++;
                }
            }
        }
    }
}

// ========== BLOCK ATTACK ==========

void scxpm_block_attack_check()
{
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer is null || !pPlayer.IsAlive()) continue;
        
        int id = pPlayer.entindex();
        
        if (dodge[id] > 0)
        {
            int chance = scxpm_get_block_chance(id);
            bool shouldActivate = Math.RandomLong(0, 100) < chance;
            
            if (shouldActivate != has_godmode[id])
            {
                has_godmode[id] = shouldActivate;
                if (shouldActivate)
                {
                    pPlayer.pev.takedamage = DAMAGE_NO;
                }
                else
                {
                    pPlayer.pev.takedamage = DAMAGE_YES;
                }
            }
        }
        else
        {
            if (has_godmode[id])
            {
                has_godmode[id] = false;
                pPlayer.pev.takedamage = DAMAGE_YES;
            }
        }
    }
}

// ========== XP LOGIC ==========

void scxpm_reexp()
{
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pPlayer is null) continue;
        
        int id = pPlayer.entindex();
        int currentFrags = int(pPlayer.pev.frags);
        int sessionFragGain = currentFrags - sessionFrags[id];
        
        if (sessionFragGain > 0)
        {
            totalFrags[id] += sessionFragGain;
            sessionFrags[id] = currentFrags;
            
            int medalsFromFrags = totalFrags[id] / FRAGS_PER_MEDAL;
            int currentMedalsFromFrags = medals[id] - 1;
            
            if (medalsFromFrags > currentMedalsFromFrags)
            {
                int newMedals = medalsFromFrags - currentMedalsFromFrags;
                for (int m = 0; m < newMedals; m++)
                {
                    if (medals[id] < MAX_MEDALS)
                    {
                        medals[id]++;
                        string name = string(pPlayer.pev.netname);
                        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Congratulations! You received a medal for " + FRAGS_PER_MEDAL + " total frags! (+2.2% bonus per medal)\n");
                        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, name + " received a medal for " + FRAGS_PER_MEDAL + " total frags!\n");
                        scxpm_savedata(id, true);
                    }
                    else
                    {
                        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] You have reached maximum medals (" + MAX_MEDALS + ")!\n");
                        break;
                    }
                }
            }
        }
        
        if (playerlevel[id] == MAX_LEVEL)
        {
            xp[id] = MAX_XP;
            continue;
        }
        
        float helpvar = (float(xp[id]) / 5.0 / g_fXPGainMultiplier) + 
                        float(pPlayer.pev.frags) - lastfrags[id];
        
        xp[id] = floatround(helpvar * 5.0 * g_fXPGainMultiplier);
        lastfrags[id] = pPlayer.pev.frags;
        
        if (neededxp[id] > 0)
        {
            while (xp[id] >= neededxp[id] && playerlevel[id] < MAX_LEVEL)
            {
                int prevxp = neededxp[id];
                playerlevel[id]++;
                scxpm_calcneedxp(id);
                skillpoints[id]++;
                
                string name = string(pPlayer.pev.netname);
                
                if (playerlevel[id] == MAX_LEVEL)
                {
                    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[SCXPM] Everyone say \"Congratulations!!!\" to " + name + ", who has reached Level 1800!\n");
                    scxpm_auto_max_skills(pPlayer); 
                }
                else
                {
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Congratulations, you are now Level " + playerlevel[id] + "! Next: " + neededxp[id] + " XP (+" + (neededxp[id] - prevxp) + ")\n");
                }
                
                scxpm_getrank(id);
                SCXPM_ShowSkillSelectionMenu(pPlayer);
                scxpm_savedata(id, true);
            }
        }
    }
}

// ========== GRAVITY ==========

void scxpm_gravity_on(CBasePlayer@ pPlayer, int id)
{
    if (pPlayer !is null && pPlayer.IsAlive() && gravity[id] > 0)
    {
        pPlayer.pev.gravity = scxpm_get_gravity(id);
    }
}

void scxpm_gravity_off(CBasePlayer@ pPlayer)
{
    if (pPlayer !is null && pPlayer.IsAlive())
    {
        pPlayer.pev.gravity = 1.0;
    }
}

// ========== MAIN THINK ==========

bool onecount = false;

void scxpm_sdac()
{
    if (!onecount)
    {
        onecount = true;
    }
    else
    {
        scxpm_reexp();
        scxpm_showdata();
        onecount = false;
    }
    scxpm_regen();
    scxpm_team_power();
    scxpm_block_attack_check();
}

// ========== COMMANDS ==========

void scxpm_playerslist_command(CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Check Console");
	g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] === PLAYER STATS ===\n");
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ p = g_PlayerFuncs.FindPlayerByIndex(i);
        if (p !is null && p.IsConnected())
        {
            int id = p.entindex();
            string name = string(p.pev.netname);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] " + name + " - Level: " + playerlevel[id] + " Medals: " + medals[id] + "\n");
        }
    }
}

void scxpm_version_command(CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    string allinfo = "Original Author: Silencer\n";
    allinfo += "AngelScript Rewrite: Diclonius Limeony\n";
    allinfo += "Version: " + SCXPM_VERSION + "\n";
    allinfo += "Experience Multiplier: " + g_fXPGainMultiplier + "\n";
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, allinfo + "\n");
}

// ========== PLAYER HOOKS ==========

void scxpm_newbiehelp(EHandle hPlayer)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
    if (pPlayer !is null && pPlayer.IsConnected())
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Type /menu to open SCXPM menu!\n");
    }
}

void scxpm_client_authorized(CBasePlayer@ pPlayer)
{
    if (pPlayer is null) return;
    int id = pPlayer.entindex();
    
    lastfrags[id] = pPlayer.pev.frags;
    sessionFrags[id] = int(pPlayer.pev.frags);
    
    scxpm_loaddata(id);
    
    if (playerlevel[id] <= 0)
    {
        playerlevel[id] = 1;
        scxpm_calcneedxp(id);
        scxpm_getrank(id);
        skillpoints[id] = 1;
        medals[id] = 1;
        health[id] = 0;
        armor[id] = 0;
        rhealth[id] = 0;
        rarmor[id] = 0;
        rammo[id] = 0;
        gravity[id] = 0;
        speed[id] = 0;
        dist[id] = 0;
        dodge[id] = 0;
        xp[id] = 0;
        totalFrags[id] = 0;
        sessionFrags[id] = 0;
        
        g_Scheduler.SetTimeout("scxpm_newbiehelp", 35.0, EHandle(pPlayer));
        g_Scheduler.SetTimeout("scxpm_newbiehelp", 70.0, EHandle(pPlayer));
        g_Scheduler.SetTimeout("scxpm_newbiehelp", 105.0, EHandle(pPlayer));
    }
    
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] SCXPM AngelScript Version " + SCXPM_VERSION + " by Diclonius Limeony\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SCXPM] Original plugin by Silencer\n");
}

void scxpm_client_spawn(CBasePlayer@ pPlayer)
{
    if (pPlayer is null || !pPlayer.IsAlive()) return;
    
    int id = pPlayer.entindex();
    
    if (firstSpawn[id])
    {
        starthealth[id] = int(pPlayer.pev.health);
        startarmor[id] = int(pPlayer.pev.armorvalue);
        firstSpawn[id] = false;
    }
    
    int newHealth = starthealth[id] + health[id] + medals[id];
    int newArmor = startarmor[id] + armor[id] + medals[id];
    
    pPlayer.pev.health = newHealth;
    pPlayer.pev.armorvalue = newArmor;
}

// ========== GRAVITY PRE-THINK ==========

HookReturnCode OnPlayerPreThink(CBasePlayer@ pPlayer)
{
    if (!SCXPM_Enabled || pPlayer is null) return HOOK_CONTINUE;
    
    int id = pPlayer.entindex();
    
    int deadflag = pPlayer.pev.deadflag;
    if (deadflag == 0 && lastDeadflag[id] != 0)
    {
        scxpm_client_spawn(pPlayer);
    }
    lastDeadflag[id] = deadflag;
    
    if (gravity[id] > 0)
    {
        if ((pPlayer.pev.button & IN_JUMP) != 0)
        {
            scxpm_gravity_on(pPlayer, id);
        }
        else if ((pPlayer.pev.oldbuttons & IN_JUMP) != 0)
        {
            scxpm_gravity_off(pPlayer);
        }
    }
    
    return HOOK_CONTINUE;
}

// ========== ADMIN COMMANDS ==========

CBasePlayer@ SCXPM_FindPlayer(const string& in szName, bool& out bMultiple = false)
{
    CBasePlayer@ pTarget = null;
    int iTargets = 0;
    
    for (int i = 1; i <= g_Engine.maxClients; i++)
    {
        CBasePlayer@ iPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        
        if (iPlayer !is null && iPlayer.IsConnected())
        {
            string szCheck = string(iPlayer.pev.netname);
            uint iCheck = szCheck.Find(szName, 0, String::CaseInsensitive);
            if (iCheck == 0)
            {
                iTargets++;
                @pTarget = iPlayer;
            }
        }
    }
    
    if (iTargets == 1)
        return pTarget;
    else if (iTargets >= 2)
        bMultiple = true;
    
    return null;
}

CClientCommand ADMIN_CMDHELP("xp_help", " - Shows all available admin commands.", @AdminCmd_Help, ConCommandFlag::AdminOnly);
void AdminCmd_Help(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pPlayer !is null)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Admin Commands:\n\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  scxpm_xpgain <value> - Set XP multiplier (current: " + g_fXPGainMultiplier + ")\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  addmedal <Name> - Give a medal to player\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  removemedal <Name> - Remove a medal from player\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  setlvl <Name> <Amount> - Set player level (1-1800)\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  godmode <Name> - Toggle God Mode on player\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  noclipmode <Name> - Toggle Noclip Mode on player\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  setmax <Name> - Set player to max level (1800) and max medals (15)\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  showfrags [Name] - Show player's total frags\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  xp_help - Show this help\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  forceload <Name> - Force load player data from vault\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  forceloadall - Force load best data from both slots for ALL players\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  forcesaveall - Force save ALL players data to vault\n");
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "  checkslots <Name> - Check player data in both slots\n");
    }
}

CClientCommand ADMIN_FORCELOADALL("forceloadall", " - Force load best data from both slots for ALL players", @AdminCmd_ForceLoadBest, ConCommandFlag::AdminOnly);

void AdminCmd_ForceLoadBest(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    int loadedCount = 0;
    int upgradedCount = 0;
    
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pTarget !is null && pTarget.IsConnected())
        {
            int id = pTarget.entindex();
            string szSteamID = g_EngineFuncs.GetPlayerAuthId(pTarget.edict());
            
            if (szSteamID.Length() < 2 || szSteamID == "STEAM_ID_LAN")
                continue;
            
            // Save current data for comparison
            int oldLevel = playerlevel[id];
            int oldMedals = medals[id];
            
            // Get best data from both slots
            string bestData = GetBestPlayerData(szSteamID);
            
            if (bestData.Length() > 0)
            {
                // Parse and apply best data
                array<string>@ config = bestData.Split('#');
                if (config.length() >= 14)
                {
                    int newLevel = atoi(config[12]);
                    int newMedals = atoi(config[1]);
                    
                    // Apply best data
                    ParseAndLoadPlayerData(id, bestData);
                    scxpm_calcneedxp(id);
                    scxpm_getrank(id);
                    
                    // Update memory
                    g_PlayerDatabase[szSteamID] = bestData;
                    UpdateLastSavedData(id);
                    
                    // Apply to player if alive
                    if (pTarget.IsAlive())
                    {
                        int newHealth = scxpm_get_effective_health(id);
                        int newArmor = scxpm_get_effective_armor(id);
                        pTarget.pev.health = newHealth;
                        pTarget.pev.armorvalue = newArmor;
                        pTarget.pev.gravity = scxpm_get_gravity(id);
                    }
                    
                    loadedCount++;
                    if (newLevel > oldLevel || newMedals > oldMedals)
                        upgradedCount++;
                    
                    g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin forced load of best data! Level: " + newLevel + "\n");
                }
            }
            else if (!g_PlayerDatabase.exists(szSteamID))
            {
                // No saved data found, initialize empty
                LoadEmptySkills(id);
                loadedCount++;
            }
        }
    }
    
    if (pPlayer !is null)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Force loaded best data for " + loadedCount + " players (" + upgradedCount + " upgraded)\n");
    }
    SCXPM_Log("Force loaded best data for " + loadedCount + " players (" + upgradedCount + " upgraded)\n");
}

CClientCommand ADMIN_FORCESAVEALL("forcesaveall", " - Force save ALL players data to vault", @AdminCmd_ForceSaveAll, ConCommandFlag::AdminOnly);
void AdminCmd_ForceSaveAll(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pPlayer !is null)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Force saving all players...\n");
    }
    
    for (int i = 1; i <= 32; i++)
    {
        CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pTarget !is null && pTarget.IsConnected())
        {
            int id = pTarget.entindex();
            scxpm_savedata(id, true);
        }
    }
    
    ForceSaveToFile();
    
    if (pPlayer !is null)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Force saved ALL players data to vault!\n");
    }
}

CClientCommand ADMIN_FORCELOAD("forceload", "<Name> - Force load player data from vault (best from both slots)", @AdminCmd_ForceLoad, ConCommandFlag::AdminOnly);
void AdminCmd_ForceLoad(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            string tname = string(pTarget.pev.netname);
            string szSteamID = g_EngineFuncs.GetPlayerAuthId(pTarget.edict());
            
            int currentFrags = int(pTarget.pev.frags);
            int sessionFragGain = currentFrags - sessionFrags[id];
            
            if (sessionFragGain > 0)
            {
                totalFrags[id] += sessionFragGain;
                sessionFrags[id] = currentFrags;
            }
            
            // Get best data from both slots
            string bestData = GetBestPlayerData(szSteamID);
            
            if (bestData.Length() > 0)
            {
                int oldLevel = playerlevel[id];
                
                ParseAndLoadPlayerData(id, bestData);
                scxpm_calcneedxp(id);
                scxpm_getrank(id);
                
                g_PlayerDatabase[szSteamID] = bestData;
                UpdateLastSavedData(id);
                loaddata[id] = true;
                
                if (pTarget.IsAlive())
                {
                    int newHealth = scxpm_get_effective_health(id);
                    int newArmor = scxpm_get_effective_armor(id);
                    pTarget.pev.health = newHealth;
                    pTarget.pev.armorvalue = newArmor;
                    pTarget.pev.gravity = scxpm_get_gravity(id);
                }
                
                sessionFrags[id] = int(pTarget.pev.frags);
                
                if (pPlayer !is null)
                {
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Force loaded best data for " + tname + " - Level: " + playerlevel[id] + " (was " + oldLevel + ")\n");
                }
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin forced load of best data! Your level is now " + playerlevel[id] + "\n");
                SCXPM_Log("Force loaded best data for " + tname + " (" + szSteamID + ") - Level: " + playerlevel[id] + "\n");
            }
            else
            {
                LoadEmptySkills(id);
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] No saved data found for " + tname + ", created new\n");
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1 && pPlayer !is null)
    {
        int id = pPlayer.entindex();
        string szName = string(pPlayer.pev.netname);
        string szSteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        
        int currentFrags = int(pPlayer.pev.frags);
        int sessionFragGain = currentFrags - sessionFrags[id];
        
        if (sessionFragGain > 0)
        {
            totalFrags[id] += sessionFragGain;
            sessionFrags[id] = currentFrags;
            scxpm_savedata(id, true);
        }
        
        string bestData = GetBestPlayerData(szSteamID);
        
        if (bestData.Length() > 0)
        {
            int oldLevel = playerlevel[id];
            
            ParseAndLoadPlayerData(id, bestData);
            scxpm_calcneedxp(id);
            scxpm_getrank(id);
            
            g_PlayerDatabase[szSteamID] = bestData;
            UpdateLastSavedData(id);
            loaddata[id] = true;
            
            if (pPlayer.IsAlive())
            {
                int newHealth = scxpm_get_effective_health(id);
                int newArmor = scxpm_get_effective_armor(id);
                pPlayer.pev.health = newHealth;
                pPlayer.pev.armorvalue = newArmor;
                pPlayer.pev.gravity = scxpm_get_gravity(id);
            }
            
            sessionFrags[id] = int(pPlayer.pev.frags);
            
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Your data has been force reloaded from best slot! Level: " + playerlevel[id] + " (was " + oldLevel + ")\n");
            SCXPM_Log("Force loaded best data for " + szName + " (" + szSteamID + ") - Level: " + playerlevel[id] + "\n");
        }
        else
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] No saved data found!\n");
        }
    }
    else
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: forceload <Name> - Force load best data from both slots\n");
    }
}

CClientCommand ADMIN_CHECKSLOTS("checkslots", "<Name> - Check player data in both slots", @AdminCmd_CheckSlots, ConCommandFlag::AdminOnly);

void AdminCmd_CheckSlots(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            string szSteamID = g_EngineFuncs.GetPlayerAuthId(pTarget.edict());
            string dataA = GetPlayerDataFromSlot(szSteamID, "A");
            string dataB = GetPlayerDataFromSlot(szSteamID, "B");
            
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] === Player: " + string(pTarget.pev.netname) + " ===\n");
            
            if (dataA.Length() > 0)
            {
                array<string>@ configA = dataA.Split('#');
                if (configA.length() >= 14)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Slot A - Level: " + configA[12] + ", XP: " + configA[0] + ", Medals: " + configA[1] + "\n");
            }
            else
            {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Slot A - NO DATA\n");
            }
            
            if (dataB.Length() > 0)
            {
                array<string>@ configB = dataB.Split('#');
                if (configB.length() >= 14)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Slot B - Level: " + configB[12] + ", XP: " + configB[0] + ", Medals: " + configB[1] + "\n");
            }
            else
            {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Slot B - NO DATA\n");
            }
            
            string bestData = GetBestPlayerData(szSteamID);
            if (bestData.Length() > 0)
            {
                array<string>@ configBest = bestData.Split('#');
                if (configBest.length() >= 14)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] best - Level: " + configBest[12] + ", XP: " + configBest[0] + ", Medals: " + configBest[1] + "\n");
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: checkslots <Name>\n");
    }
}

CClientCommand ADMIN_SHOWFRAGS("showfrags", "<Name> - Show player's total frags", @AdminCmd_ShowFrags, ConCommandFlag::AdminOnly);
void AdminCmd_ShowFrags(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            int medalsFromFrags = totalFrags[id] / FRAGS_PER_MEDAL;
            int nextMedalAt = ((totalFrags[id] / FRAGS_PER_MEDAL) + 1) * FRAGS_PER_MEDAL;
            int fragsNeeded = nextMedalAt - totalFrags[id];
            
            string tname = string(pTarget.pev.netname);
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTCONSOLE, "[SCXPM] === " + tname + " Stats ===\n");
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTCONSOLE, "[SCXPM] Total Frags: " + totalFrags[id] + "\n");
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTCONSOLE, "[SCXPM] Medals from frags: " + medalsFromFrags + "\n");
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTCONSOLE, "[SCXPM] Next medal at: " + nextMedalAt + " frags (need " + fragsNeeded + " more)\n");
            
            if (pPlayer !is null && pPlayer != pTarget)
            {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] " + tname + " total frags: " + totalFrags[id] + "\n");
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
        {
            int id = pPlayer.entindex();
            int medalsFromFrags = totalFrags[id] / FRAGS_PER_MEDAL;
            int nextMedalAt = ((totalFrags[id] / FRAGS_PER_MEDAL) + 1) * FRAGS_PER_MEDAL;
            int fragsNeeded = nextMedalAt - totalFrags[id];
            
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Your total frags: " + totalFrags[id] + "\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Medals from frags: " + medalsFromFrags + "\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Next medal at: " + nextMedalAt + " frags (need " + fragsNeeded + " more)\n");
        }
    }
}

CClientCommand ADMIN_XPGAIN("scxpm_xpgain", "<value> - Set XP gain multiplier (default: 1.0)", @AdminCmd_XPGain, ConCommandFlag::AdminOnly);
void AdminCmd_XPGain(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        float newValue = atof(pArgs[1]);
        if (newValue <= 0) newValue = 1.0;
        
        g_fXPGainMultiplier = newValue;
        
        if (pPlayer !is null)
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] XP gain multiplier set to: " + g_fXPGainMultiplier + "\n");
        }
        SCXPM_Log("XP gain multiplier set to: " + g_fXPGainMultiplier + "\n");
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: scxpm_xpgain <value>\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Current value: " + g_fXPGainMultiplier + "\n");
        }
    }
}

CClientCommand ADMIN_ADDMEDAL("addmedal", "<Name> - Add a medal to a player", @AdminCmd_AddMedal, ConCommandFlag::AdminOnly);
void AdminCmd_AddMedal(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            
            if (medals[id] < MAX_MEDALS)
            {
                medals[id]++;
                
                string aname = string(pPlayer.pev.netname);
                string tname = string(pTarget.pev.netname);
                
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Added 1 medal to " + tname + "! Total: " + medals[id] + "/" + MAX_MEDALS + "\n");
                
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin gave you a medal! (+2.2% bonus per medal)\n");
                g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "ADMIN " + aname + " gave a medal to " + tname + ".\n");
                scxpm_savedata(id, true);
            }
            else
            {
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player already has max medals (" + MAX_MEDALS + ")\n");
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: addmedal <Name>\n");
    }
}

CClientCommand ADMIN_REMOVEMEDAL("removemedal", "<Name> - Remove a medal from a player", @AdminCmd_RemoveMedal, ConCommandFlag::AdminOnly);
void AdminCmd_RemoveMedal(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            
            if (medals[id] > 1)
            {
                medals[id]--;
                
                string aname = string(pPlayer.pev.netname);
                string tname = string(pTarget.pev.netname);
                
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Removed 1 medal from " + tname + "! Total: " + medals[id] + "/" + MAX_MEDALS + "\n");
                
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin removed a medal from you!\n");
                g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "ADMIN " + aname + " removed a medal from " + tname + ".\n");
                scxpm_savedata(id, true);
            }
            else
            {
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player has no medals to remove! (Minimum 1 medal)\n");
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: removemedal <Name>\n");
    }
}

CClientCommand ADMIN_SETLVL("setlvl", "<Name> <Amount> - Set player level (1-1800)", @AdminCmd_SetLevel, ConCommandFlag::AdminOnly);
void AdminCmd_SetLevel(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 3)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            int newLevel = atoi(pArgs[2]);
            
            if (newLevel < 1) newLevel = 1;
            if (newLevel > MAX_LEVEL) newLevel = MAX_LEVEL;
            
            int oldLevel = playerlevel[id];
            int levelDiff = newLevel - oldLevel;
            
            if (levelDiff > 0)
            {
                skillpoints[id] += levelDiff;
            }
            else if (levelDiff < 0)
            {
                skillpoints[id] += levelDiff;
                if (skillpoints[id] < 0) skillpoints[id] = 0;
            }
            
            playerlevel[id] = newLevel;
            
            if (newLevel == MAX_LEVEL)
            {
                xp[id] = MAX_XP;
            }
            else if (newLevel > 0)
            {
                int helpvar = newLevel - 1;
                float m70 = float(helpvar) * 70.0;
                float mselfm3dot2 = float(helpvar) * float(helpvar) * 3.5;
                xp[id] = floatround(m70 + mselfm3dot2 + 30.0);
            }
            else
            {
                xp[id] = 0;
            }
            
            scxpm_calcneedxp(id);
            scxpm_getrank(id);
            
            string aname = string(pPlayer.pev.netname);
            string tname = string(pTarget.pev.netname);
            
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Set " + tname + " level to " + newLevel + "\n");
            
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin set your level to " + newLevel + "!\n");
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "ADMIN " + aname + " set " + tname + " level to " + newLevel + ".\n");
            
            if (pTarget.IsAlive())
            {
                int maxHealth = scxpm_get_effective_health(id);
                int maxArmor = scxpm_get_effective_armor(id);
                pTarget.pev.health = maxHealth;
                pTarget.pev.armorvalue = maxArmor;
                pTarget.pev.gravity = scxpm_get_gravity(id);
            }
            
            if (newLevel > oldLevel && newLevel < MAX_LEVEL)
            {
                SCXPM_ShowSkillSelectionMenu(pTarget);
            }
            
            scxpm_savedata(id, true);
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: setlvl <Name> <Amount>\n");
    }
}

CClientCommand ADMIN_GODMODE("godmode", "<Name> - Toggle God Mode on player", @AdminCmd_GodMode, ConCommandFlag::AdminOnly);
void AdminCmd_GodMode(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            
            if (!pTarget.IsAlive())
            {
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player is dead!\n");
                return;
            }
            
            if (has_godmode[id])
            {
                has_godmode[id] = false;
                pTarget.pev.takedamage = DAMAGE_YES;
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] God Mode disabled by admin!\n");
                if (pPlayer !is null && pPlayer != pTarget)
                {
                    string tname = string(pTarget.pev.netname);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Disabled God Mode on " + tname + "\n");
                }
            }
            else
            {
                has_godmode[id] = true;
                pTarget.pev.takedamage = DAMAGE_NO;
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] God Mode enabled by admin!\n");
                if (pPlayer !is null && pPlayer != pTarget)
                {
                    string tname = string(pTarget.pev.netname);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Enabled God Mode on " + tname + "\n");
                }
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: godmode <Name>\n");
    }
}

CClientCommand ADMIN_NOCLIPMODE("noclipmode", "<Name> - Toggle Noclip Mode on player", @AdminCmd_NoclipMode, ConCommandFlag::AdminOnly);
void AdminCmd_NoclipMode(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            
            if (!pTarget.IsAlive())
            {
                if (pPlayer !is null)
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player is dead!\n");
                return;
            }
            
            if (has_noclip[id])
            {
                has_noclip[id] = false;
                pTarget.pev.movetype = MOVETYPE_WALK;
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Noclip Mode disabled by admin!\n");
                if (pPlayer !is null && pPlayer != pTarget)
                {
                    string tname = string(pTarget.pev.netname);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Disabled Noclip Mode on " + tname + "\n");
                }
            }
            else
            {
                has_noclip[id] = true;
                pTarget.pev.movetype = MOVETYPE_NOCLIP;
                g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Noclip Mode enabled by admin!\n");
                if (pPlayer !is null && pPlayer != pTarget)
                {
                    string tname = string(pTarget.pev.netname);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Enabled Noclip Mode on " + tname + "\n");
                }
            }
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: noclipmode <Name>\n");
    }
}

CClientCommand ADMIN_SETMAX("setmax", "<Name> - Set player to max level (1800) and max medals (15)", @AdminCmd_SetMax, ConCommandFlag::AdminOnly);
void AdminCmd_SetMax(const CCommand@ pArgs)
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    if (pArgs.ArgC() >= 2)
    {
        bool bMultiple = false;
        CBasePlayer@ pTarget = SCXPM_FindPlayer(pArgs[1], bMultiple);
        
        if (bMultiple)
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Multiple players found. Be more specific.\n");
        }
        else if (pTarget !is null)
        {
            int id = pTarget.entindex();
            string aname = string(pPlayer.pev.netname);
            string tname = string(pTarget.pev.netname);
            
            if (playerlevel[id] != MAX_LEVEL)
            {
                int levelDiff = MAX_LEVEL - playerlevel[id];
                if (levelDiff > 0)
                {
                    skillpoints[id] += levelDiff;
                }
                playerlevel[id] = MAX_LEVEL;
                xp[id] = MAX_XP;
                scxpm_calcneedxp(id);
                scxpm_getrank(id);
                scxpm_auto_max_skills(pTarget);
            }
            
            if (medals[id] < MAX_MEDALS)
            {
                medals[id] = MAX_MEDALS;
            }
            
            g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, "[SCXPM] Admin set you to MAX LEVEL (1800) with MAX MEDALS (15)!\n");
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "ADMIN " + aname + " set " + tname + " to MAX LEVEL and MAX MEDALS!\n");
            
            if (pPlayer !is null && pPlayer != pTarget)
            {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Set " + tname + " to MAX LEVEL and MAX MEDALS.\n");
            }
            
            if (pTarget.IsAlive())
            {
                int maxHealth = scxpm_get_effective_health(id);
                int maxArmor = scxpm_get_effective_armor(id);
                pTarget.pev.health = maxHealth;
                pTarget.pev.armorvalue = maxArmor;
                pTarget.pev.gravity = scxpm_get_gravity(id);
            }
            
            scxpm_savedata(id, true);
        }
        else
        {
            if (pPlayer !is null)
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Player not found.\n");
        }
    }
    else if (pArgs.ArgC() == 1)
    {
        if (pPlayer !is null)
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[SCXPM] Usage: setmax <Name> - Set player to max level (1800) and max medals (15)\n");
    }
}

// ========== COMMAND HANDLER ==========

bool SCXPM_HandleCommand(CBasePlayer@ pPlayer, const string& in cmd)
{
    if (pPlayer is null) return false;
    
    if (cmd == "menu" || cmd == "scxpm")
    {
        SCXPM_ShowMainMenu(pPlayer);
        return true;
    }
    else if (cmd == "scxpminfo" || cmd == "version")
    {
        scxpm_version_command(pPlayer);
        return true;
    }
    
    return false;
}

// ========== MAP FUNCTIONS ==========

void MapActivate()
{
    if (!g_bDatabaseReady)
    {
        LoadGlobalDatabase();
        g_bDatabaseReady = true;
    }
}

void MapEnd()
{
    if (g_bDatabaseReady)
    {
        SCXPM_Log("Map ending, saving all player data...\n");
        ForceSaveAllPlayers();
        SCXPM_Log("Map ended, vaults saved\n");
    }
}

// ========== INITIALIZATION ==========

void InitAmmoIndexes()
{
    AMMO_9MM = g_PlayerFuncs.GetAmmoIndex("9mm");
    AMMO_357 = g_PlayerFuncs.GetAmmoIndex("357");
    AMMO_BUCKSHOT = g_PlayerFuncs.GetAmmoIndex("buckshot");
    AMMO_CROSSBOW = g_PlayerFuncs.GetAmmoIndex("bolts");
    AMMO_RPG = g_PlayerFuncs.GetAmmoIndex("rockets");
    AMMO_GAUSS = g_PlayerFuncs.GetAmmoIndex("uranium"); 
    AMMO_556 = g_PlayerFuncs.GetAmmoIndex("556");
    AMMO_762 = g_PlayerFuncs.GetAmmoIndex("m40a1");
    AMMO_ARGRENADES = g_PlayerFuncs.GetAmmoIndex("ARgrenades");
    AMMO_SPORECLIP = g_PlayerFuncs.GetAmmoIndex("sporeclip");
    
    SCXPM_Log("Ammo indexes initialized\n");
}

void SCXPM_Init()
{
    SCXPM_Log("Initialization started\n");
    
    InitAmmoIndexes();
    
    for (int i = 1; i <= 32; i++)
    {
        xp[i] = 0;
        neededxp[i] = 30;
        playerlevel[i] = 1;
        skillpoints[i] = 1;
        rank[i] = "Frightened Civilian";
        lastfrags[i] = 0;
        totalFrags[i] = 0;
        sessionFrags[i] = 0;
        rhealthwait[i] = 0;
        rarmorwait[i] = 0;
        ammowait[i] = 0;
        has_godmode[i] = false;
        has_noclip[i] = false;
        skillIncrement[i] = 1;
        lastSelectedSkill[i] = 0;
        hud_pos_x[i] = 0.65;
        hud_pos_y[i] = 0.04;
        lastDeadflag[i] = 1;
        starthealth[i] = 100;
        startarmor[i] = 0;
        loaddata[i] = false;
        firstSpawn[i] = true;
        
        health[i] = 0;
        armor[i] = 0;
        rhealth[i] = 0;
        rarmor[i] = 0;
        rammo[i] = 0;
        gravity[i] = 0;
        speed[i] = 0;
        dist[i] = 0;
        dodge[i] = 0;
        medals[i] = 1;
    }
    
    g_Scheduler.SetInterval("scxpm_sdac", 0.5);
    g_Scheduler.SetInterval("AutoSaveIfChanged", 15.0);
    g_Scheduler.SetInterval("AutoSaveFrags", 10.0);
    
    SCXPM_Log("SCXPM " + SCXPM_VERSION + " initialized\n");
}

// ========== HOOKS ==========

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
    scxpm_client_authorized(pPlayer);
    return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
    if (pPlayer !is null)
    {
        int id = pPlayer.entindex();
        
        int currentFrags = int(pPlayer.pev.frags);
        int sessionFragGain = currentFrags - sessionFrags[id];
        if (sessionFragGain > 0)
        {
            totalFrags[id] += sessionFragGain;
            sessionFrags[id] = currentFrags;
        }
        
        scxpm_savedata(id, true);
    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
    scxpm_client_spawn(pPlayer);
    return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ pArgs = pParams.GetArguments();
    
    if (pArgs.ArgC() >= 1)
    {
        string text = pArgs[0];
        text.ToLowercase();
        
        if (text.Length() > 0 && text[0] == '/')
            text = text.SubString(1);
        
        if (SCXPM_HandleCommand(pPlayer, text))
        {
            pParams.ShouldHide = true;
            return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}

// ========== PLUGIN ENTRY ==========

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Diclonius Limeony");
    g_Module.ScriptInfo.SetContactInfo("SCXPM " + SCXPM_VERSION);
    
    SCXPM_Init();
    
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
    g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @OnPlayerPreThink);
}
