--[[
	Copyright (c) 2012 Carreras Nicolas

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]
--- Lua INI Parser.
-- It has never been that simple to use INI files with Lua.
--@author Dynodzzo
---Modified by ConstaChymic

local LIP = {};

--does the actual work of converting the data to a table
local function convertToTable (iterator)
	local data = {};
	local section;
	for line in iterator do
		local tempSection = line:match('^%[([^%[%]]*)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	return data;
end

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function LIP.load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
	local data = convertToTable(file:lines())
	file:close();
	return data;
end

--- Returns a table containing all the data from the INI file.
--- Same as load, but you just pass the file directly rather than the path.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function LIP.loadFile(file)
	local f = file:lines()
	local data = convertToTable(f)
	file:close()
	return data;
end

--- Returns a table containing all the data from the INI file.
--- Same as load, except takes an ini string rather than a file
--@param iniString The INI file as a string to load. [string]
--@return The table containing all data from the INI file. [table]
function LIP.loadString(iniString)
	assert(type(iniString) == 'string', 'Parameter "iniString" must be a string.');
	iniString = iniString:gsub("\r\n", "\n");
	return convertToTable(string.gmatch(iniString, "([^\n]+)"))
end

--- Converts the given table to an INI string
--@param data The table containing all the data to store. [table]
function LIP.buildString(data, isfile)
    assert(type(data) == 'table', 'Parameter "data" must be a table.');
    local rline = isfile and '\r\n' or '\n'
    local contents = '';
    for section, param in pairs(data) do
        contents = contents .. ('[%s]\n'):format(section);
        for key, value in pairs(param) do
            contents = contents .. ('%s=%s\n'):format(key, tostring(value));
        end
        contents = contents .. rline;
    end
    return contents;
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function LIP.save(fileName, data)
    assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
    local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
    file:write(LIP.buildString(data, true));
    file:close();
end

return LIP;
