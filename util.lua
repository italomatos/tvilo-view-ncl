-- created by Italo Matos
function array_push(a, element)
  a[#a + 1] = element
  return a
end

function array_pop(a)

	table.remove(a)
--	x = table.remove(a,#a - 1)
--	return x
end

function array_push_at(a, index, element)
  a[index] = element
  return a
end

function array_has(a, element)
  cont = 1
  while(cont <= #a) do
    if (a[cont] == element) then
      return true
    end
    cont = cont + 1
  end
  
  return false
end

function readContentFile(fileName)
	file, err = io.open(fileName, "r")
	if file == nil then
		print("Error ao abrir o arquivo" .. "" .. err)
		return ""
	else
		content = ""
		for line in file:lines() do
			content = content .. line
		end
		file:close()
		return content	
	end
end

function createFile(content, fileName, binaryFile)
    binaryFile = binaryFile or false
    local mode = ""
    if binaryFile then
       mode = "w+b"
    else
       mode = "w+"
    end
    file, err = io.open(fileName, mode)
    if file == nil then
    	print("Erro ao abrir arquivo "..fileName.."\n".. err)
    	return false
    else
    	print("Arquivo", fileName, "criado com sucesso")
        file:write(content)
        file:close()
        return true
    end
end

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

-- function getText(width,text)
--        valores = {}
--        texto = ""
--        i = 1
--		ant = ""
--        palavras = text:split(" ")
--        for i,v in ipairs(palavras) do 
--                dx, dy = canvas:measureText(texto) 
--                if ( ant ~= "\r" and dx < width ) then
--						ant = texto[#texto -1]
--                        texto = texto ..  v .. " "
--                else
--						ant = texto[#texto -1]
--                        valores[#valores + 1] = texto .. v .. " "
--                        texto = ""
--                end
--                i = i + 1
--        end
--        valores[#valores + 1] = texto
--        return valores
--end
function getText(width,text)
	valores = {}
	texto = ""
	i = 1
	ant = ""
	palavras = text:split(" ")
	for i,v in ipairs(palavras) do
		dx, dy = canvas:measureText(texto)
        if ( ant ~= "\r" and dx < width ) then
	        ant = texto[#texto -1]
			texto = texto ..  v .. " "
		else
			ant = texto[#texto -1]
			valores[#valores + 1] = texto .. v .. " "
			texto = ""
		end
		i = i + 1
	end
	valores[#valores + 1] = texto
	return valores
end
-- x = "italo matos cavalcante"
-- palavras = x:split(" ")
-- for i,v in ipairs(palavras) do print(i,v) end