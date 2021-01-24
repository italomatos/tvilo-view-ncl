--  text panel component

TextPanel = {x = 10, y = 10, width = 600,texto = "",linha = 1, background=''}


function TextPanel:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function TextPanel:show(x,y,width, background)
  canvas:clear(self.x, self.y, 720, 480)
  self.background = background
	if (self.background ~= '') then
		local img = canvas:new(self.background)
		canvas:compose(20,20, img)
		canvas:flush()
    end
	self.x = x
	self.width = width
	self.y = y
end

function TextPanel:getHeight()
  dx, dy = canvas:measureText("")
  return dy * self.linha
end

function TextPanel:getText(width,text)
	valores = {}
	texto = ""
	i = 1
	palavras = text:split(" ")
	for i,v in ipairs(palavras) do 
		dx, dy = canvas:measureText(texto) 
		if ( dx < width + 350 ) then
			if (string.match(v,"\n") ~= nil) then
				retornos_1 = v:split("\n")
				for j=1, #retornos_1 do
					if (string.match(retornos_1[j],"\n") ~= nil) then
						valores[#valores + 1] = texto .. " "
						texto = ""
					else
						texto = texto .. retornos_1[j] .. " "
					end
					j = j + 1
				end
			else
				texto = texto ..  v .. " "
			end
		else
			if (string.match(v,"\n") ~= nil) then
				retornos_2 = v:split("\n")
				for j=1, #retornos_2 do
					if (string.match(retornos_2[j],"\n") ~= nil) then
						valores[#valores + 1] = texto .. " "
						texto = ""
					else
						valores[#valores + 1] = texto .. retornos_2[j] .. " "
						texto = ""
					end
					j = j + 1
				end
			else
				valores[#valores + 1] = texto .. v .. " "
				texto = ""
			end
		end
		i = i + 1
	end
	valores[#valores + 1] = texto
	return valores
end

function TextPanel:writeTitle(title)
   canvas:attrColor(0,0,0,0)
   canvas:attrFont("verdana", 32)
   self:writeContent(title)
   self.linha = self.linha + 2
end

function TextPanel:writeContent(text)
   dx, dy = canvas:measureText(text) 
   if (dx < self.width) then
	canvas:drawText(self.x, self.y + 20 + ((self.linha - 1)* dy), text)	
   else
	   vetor = self:getText(self.width, text)
	   i = 1
	   while(vetor[i]) do
		 canvas:drawText(self.x, self.y + 20 + ((self.linha - 1)* dy), vetor[i])	
		self.linha = self.linha + 1
		-- print(vetor[i]) 
		-- if (string.match(vetor[i],"\\n") ~= nil) then
		--	self.linha = self.linha + 1
		-- elseif (string.match(vetor[i],"\n") ~= nil) then
		--	self.linha = self.linha + 1
		-- end 
		i = i + 1
	   end
   end
   canvas:flush()
end

function TextPanel:writeText(text)
   canvas:attrColor(0,0,0,0)
   -- canvas:clear()
   canvas:attrFont("verdana", 32)
   self:writeContent(text)
end
function TextPanel:setHandler(_handler)
  -- event.register(_handler)
end
function TextPanel:draw_images(path_img, x, y)
	img_1 = canvas:new(path_img)
	canvas:compose(x, y, img_1)
	canvas:flush() 
end