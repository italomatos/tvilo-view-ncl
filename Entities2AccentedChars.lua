-- lua-5.0.exe
-- Entities2AccentedLetters.lua
--
-- Convert HTML entities to corresponding accented letters.
--
-- Take one parameter: the file to convert, used as input and output.
-- Note that the file is processed as binary file, to preserve its EOLs
-- whatever the system default is.
--
-- by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
-- v. 1.0 -- 2004/06/05 -- Initial code based on ChangeFile.lua

local filenameIn  = (arg and arg[1]) or "index.html"	-- If absent, use default file

local eol
local fileHandle

local entities =
{
     ["192"] = 'À',
    ["193"] = 'Á',
    ["194"] = 'Â',
    ["195"] = 'Ã',
    ["196"] = 'Ä',
    ["199"] = 'Ç',
    ["200"] = 'È',
    ["201"] = 'É',
    ["202"] = 'Ê',
    ["205"] = 'Í',
    ["211"] = 'Ó',
    ["212"] = 'Ô',
    ["213"] = 'Õ',
    ["224"] = 'à',
    ["225"] = 'á',
    ["226"] = 'â',
    ["227"] = 'ã',
    ["228"] = 'ä',
    ["231"] = 'ç',
    ["233"] = 'é',
    ["234"] = 'ê',
    ["237"] = 'í',
    ["243"] = 'ó',
    ["244"] = 'ô',
    ["245"] = 'õ',
    ["250"] = 'ú',   
    
	--Lista de códigos HTML para caracteres acentuados
	--e especiais, tendo formato &NOME; 
	aacute = 'á',
	agrave = 'à',
	acirc = 'â',
	auml = 'ä',
	eacute = 'é',
	egrave = 'è',
	ecirc = 'ê',
	euml = 'ë',
	icirc = 'î',
	iuml = 'ï',
	ocirc = 'ô',
	ouml = 'ö',
	ugrave = 'ù',
	ucirc = 'û',
	yuml = 'ÿ',
	Aacute = 'Á',
	Agrave = 'À',
	Acirc = 'Â',
	Auml = 'Ä',
	Eacute = 'É',
	Egrave = 'È',
	Ecirc = 'Ê',
	Euml = 'Ë',
	Icirc = 'Î',
	Iuml = 'Ï',
	Ocirc = 'Ô',
	Ouml = 'Ö',
	Ugrave = 'Ù',
	Ucirc = 'Û',
	ccedil = 'ç',
	Ccedil = 'Ç',
	Yuml = 'Ÿ',
	laquo = '«',
	raquo = '»',
	copy = '©',
	reg = '®',
	aelig = 'æ',
	AElig = 'Æ',
	OElig = 'Œ', -- Not understood by all browsers
	oelig = 'œ', -- Not understood by all browsers
}

function ReplaceEntity(entity)
	return entities[string.sub(entity, 3, -2)] or entity
end

-- Process one given line.
function ProcessLine(line)
	if line == nil then
		return nil
	end
  line = string.gsub(line, "&#%d+;", ReplaceEntity)
	--line = string.gsub(line, "&%a+;", ReplaceEntity)
	return line
end

-- Get the end of line used in the given string and return it.
-- Check only the first one, as we assume the string is consistent.
function GetEol(str)
	local eol1, eol2, eol, b
	b, _, eol1 = string.find(str, "([\r\n])")
	if b == nil then
		return nil	-- no EOL in this string
	end
	-- Care is taken in case the first line finishes with two EOLs
	eol2 = string.sub(str, b+1, b+1)
	if eol1 == '\r' then
		if eol2 == '\n' then
			-- Windows style
			eol = '\r\n'
		else
			-- Mac style
			eol = '\r'
		end
	else -- eol1 == '\n'
		-- Unix style
		eol = '\n'
	end
	return eol
end

function ConvertFile(filename)
	-- Read the whole file at once, to avoid clash with write
	-- Binary read, to preserve original EOLs, even if not in current system's style
	fileHandle = io.open(filename, "rb")
	if fileHandle == nil then
		return false, "open rb " .. filename
	end
	local file = fileHandle:read("*a")
	if file == nil then
		return false, "read " .. filename
	end
	fileHandle:close()

	-- Get the EOL kind for this file
	eol = GetEol(file)
	if eol == nil then
		-- Avoid to process the file, it can be binary or non-standard
		return false, "no EOL"
	end

	-- Prepare to write in the same file
	fileHandle = io.open(filename, "wb")
	if fileHandle == nil then
		return false, "open wb " .. filename
	end

	-- Loop on the lines and process them
	string.gsub(file, "(.-)" .. eol, ProcessLine)

	fileHandle:close()
	return true, nil
end

local result, op = ConvertFile(filenameIn)
if not result then
	print("Error in operation: " .. (op or 'nil'))
else
	print"Done!"
end