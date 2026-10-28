-- TOFHub Killer Module - Violence District
-- Fokus: katalog dan panel kemampuan Killer yang tercantum di VD.lua(1).txt.
-- Tidak mengaktifkan spam skill, hidden attack remote, aimlock otomatis,
-- anti-blind hook, atau perubahan mekanik map secara paksa.

return function(Hub)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LP = Players.LocalPlayer

    local maskedPowers = {"Alex", "Brandon", "Cobra", "Rabbit", "Richter", "Tony"}
    local selectedPower = "Cobra"
    local statusText = "Siap — pilih power Masked."

    local function isLocalKiller()
        if not LP then return false end
        local team = LP.Team
        if team and string.find(string.lower(team.Name), "killer", 1, true) then
            return true
        end
        local char = LP.Character
        local values = char and char:FindFirstChild("Values")
        local killerName = values and values:FindFirstChild("KillerName")
        if killerName and killerName:IsA("StringValue") and killerName.Value ~= "" then
            return true
        end
        local attr = LP:GetAttribute("SelectedKiller")
        return type(attr) == "string" and attr ~= ""
    end

    local function getSelectedKiller()
        local char = LP and LP.Character
        local values = char and char:FindFirstChild("Values")
        local value = values and values:FindFirstChild("KillerName")
        if value and value:IsA("StringValue") and value.Value ~= "" then
            return value.Value
        end
        local attr = LP and LP:GetAttribute("SelectedKiller")
        if type(attr) == "string" and attr ~= "" then return attr end
        return "Belum terdeteksi"
    end

    local function findRemote(path)
        local current = ReplicatedStorage
        for segment in string.gmatch(path, "[^%.]+") do
            current = current and current:FindFirstChild(segment)
            if not current then return nil end
        end
        return current
    end

    local function setStatus(text)
        statusText = text
        if Hub.util and type(Hub.util.toast) == "function" then
            pcall(Hub.util.toast, text)
        else
            print("[TOFHub Killer] " .. text)
        end
    end

    local function activateMaskedPower()
        if not isLocalKiller() then
            setStatus("Power Masked hanya tersedia saat role lokal terdeteksi sebagai Killer.")
            return
        end
        local remote = findRemote("Remotes.Killers.Masked.Activatepower")
        if not remote or not remote:IsA("RemoteEvent") then
            setStatus("Remote kemampuan Masked tidak ditemukan; gunakan tombol skill asli dalam game.")
            return
        end
        local ok = pcall(function() remote:FireServer(selectedPower) end)
        setStatus(ok and ("Permintaan power Masked: " .. selectedPower) or "Gagal mengirim permintaan power.")
    end

    local function deactivateMaskedPower()
        if not isLocalKiller() then
            setStatus("Role lokal bukan Killer atau belum terdeteksi.")
            return
        end
        local remote = findRemote("Remotes.Killers.Masked.Deactivatepower")
        if not remote or not remote:IsA("RemoteEvent") then
            setStatus("Remote deactivate Masked tidak ditemukan; gunakan kontrol asli dalam game.")
            return
        end
        local ok = pcall(function() remote:FireServer() end)
        setStatus(ok and "Permintaan deactivate power Masked dikirim." or "Gagal menonaktifkan power.")
    end

    Hub.ui(function(UI)
        local p = UI.page("Killer", 3)
        p:Section("Killer Ability Status")
        p:Info(function()
            return "Role lokal: " .. (isLocalKiller() and "Killer" or "Bukan Killer / belum terdeteksi") ..
                "\nKiller terpilih: " .. getSelectedKiller() ..
                "\nStatus modul: " .. statusText
        end)

        p:Section("Masked — Select Power")
        p:Choice("Select Mask Power", "killer_masked_power", maskedPowers)
        -- Choice state is also read from Hub.Config when the UI stores the selection.
        p:Info(function()
            local cfg = Hub.Config
            local candidate = cfg and (cfg.killer_masked_power or cfg["killer_masked_power"])
            if type(candidate) == "string" then selectedPower = candidate end
            return "Power dipilih: " .. selectedPower .. "\nPilihan dari VD.lua: Alex, Brandon, Cobra, Rabbit, Richter, Tony."
        end)
        p:Button("Activate Power", activateMaskedPower)
        p:Button("Deactivate Power", deactivateMaskedPower)

        p:Section("Ability Reference — dari VD.lua")
        p:Info(function()
            return table.concat({
                "• Infinite Lunge — fitur lunge saat attack ditahan.",
                "• Leap (Hidden) — tercantum pada sumber; tidak disediakan sebagai tombol remote di modul ini.",
                "• M2 (Hidden) — tercantum pada sumber; tidak disediakan sebagai tombol remote di modul ini.",
                "• Anti Flashlight Blind — sumber memakai hook; tidak diaktifkan di modul ini.",
                "• Anti Loop Window / Auto Drop All Pallets — manipulasi map tidak diaktifkan di modul ini.",
                "• Killer Perks Info — informasi perk Killer.",
                "• Hook Counter — penghitung status hook.",
                "• Aim Lock (Legit) / Aimlock M2 Hidden — tidak dijalankan otomatis di modul ini."
            }, "\n")
        end)

        p:Section("Diagnostik")
        p:Button("Refresh Killer Status", function()
            setStatus("Role=" .. (isLocalKiller() and "Killer" or "Unknown/Non-Killer") ..
                " | Killer=" .. getSelectedKiller() .. " | Mask Power=" .. selectedPower)
        end)
        p:Info(function()
            return "Jika role atau nama Killer tidak terdeteksi, struktur game mungkin berbeda atau data belum direplikasi. " ..
                "Modul ini belum diuji langsung di Delta Executor."
        end)
    end)
end
