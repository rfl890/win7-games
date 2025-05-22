local games = {
    ["Chess"] = {1, "Chess.exe"},
    ["FreeCell"] = {2, "FreeCell.exe", true},
    ["Hearts"] = {3, "Hearts.exe", true},
    ["Mahjong"] = {4, "Mahjong.exe"},
    ["Minesweeper"] = {5, "MineSweeper.exe"},
    ["Purble Place"] = {6, "PurblePlace.exe"},
    ["Solitaire"] = {7, "Solitaire.exe", true},
    ["SpiderSolitaire"] = {8, "SpiderSolitaire.exe", true}
}

local function string_to_byte_array(str)
    local out = {}
    for i = 1, #str do
        table.insert(out, string.byte(str, i))
    end
    return out
end

local function byte_array_to_string(array)
    local out = {}
    for _, byte in ipairs(array) do
        table.insert(out, string.char(byte))
    end
    return table.concat(out)
end

local function parse_patch_line(line)
    local executable_name = string.sub(line, 1, string.find(line, "+") - 1)
    local bytes = string.sub(line, string.find(line, ":") + 2, -1)

    local offset = tonumber(string.sub(line, string.find(line, "+") + 3, string.find(line, ":") - 1), 16)
    local original_byte = tonumber(string.sub(bytes, 3, string.find(bytes, "->") - 2), 16)
    local patch_byte = tonumber(string.sub(bytes, string.find(bytes, "->") + 5, -1), 16)

    return executable_name, offset, original_byte, patch_byte
end

local function patch_executable(executable_folder, executable_name, offset, original_byte, patch_byte)
    local input_executable_path = "games/" .. executable_folder .. "/" .. executable_name .. ".original"
    local output_executable_path = "games/" .. executable_folder .. "/" .. executable_name

    print("Creating patched executable " .. executable_name .. "...")

    local input_executable = io.open(input_executable_path, "rb")
    local input_executable_data = string_to_byte_array(input_executable:read("*a"))

    local output_executable = io.open(output_executable_path, "wb")

    print("Byte at offset 0x" ..
    string.format("0x%x", offset) ..
    " is " ..
    string.format("0x%x", input_executable_data[offset + 1]) ..
    ", expected value is " .. string.format("0x%x", original_byte))

    if (input_executable_data[offset + 1] ~= original_byte) then 
        print("FAILED TO PATCH: File may be corrupt.")
        os.exit(1)
    end

    input_executable_data[offset + 1] = patch_byte

    print("Writing byte " .. string.format("0x%x", patch_byte) .. " at offset " .. string.format("0x%x", offset) .. " to " .. output_executable_path)
    output_executable:write(byte_array_to_string(input_executable_data))    
end

local function list_dir(dir)
    local results = {}
    for result in io.popen("dir /B " .. dir):lines() do 
        table.insert(results, result)
    end 
    return results
end

local function get_lines(file)
    local results = {}
    for result in io.open(file, "rb"):lines() do 
        table.insert(results, result)
    end 
    return results
end


local function copy_locales(executable_name, output_folder)
    local locales = list_dir("locales")
    for i, locale in ipairs(locales) do
        io.write("Copying locale " .. locale .. " to " .. output_folder .. "..." .. " (" .. i .. "/" .. #locales .. ")" .. "        \r")
        os.execute("mkdir " .. "\"" .. output_folder .. "\\" .. locale .. "\"" .. " >nul 2>nul")
        os.execute("copy " .. "locales\\" .. locale .. "\\" .. executable_name .. ".mui" .. " " .. "\"" .. output_folder .. "\\" .. locale .. "\"" .. "  >nul 2>nul")
    end
    io.write("\n")
end

for executable_folder, executable_path in pairs(games) do
    patch_executable(executable_folder, parse_patch_line(get_lines("patches.txt")[executable_path[1]]))
    copy_locales(executable_path[2], "games\\" .. executable_folder)
    if executable_path[3] then 
        print("Copying CardGames.dll")
        os.execute("copy " .. "CardGames.dll" .. " " .. "\"" .. "games\\" .. executable_folder .. "\"" .. "  >nul 2>nul")
    end
end