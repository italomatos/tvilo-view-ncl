TextMenu = {x = 10, y = 10, width = 300,texto = "",linha = 1, background='', itens={} }

color={255,255,0}
size=20

function TextMenu:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Agora o TextMenu:show também vai receber uma cor, para assim melhorar a flexibilidade de uso em vários locais e formatos

function TextMenu:show(x,y,width, background, color, size)
	-- canvas:clear(self.x, self.y, 1280, 720)
	self.background = background
	if (self.background ~= '') then
   		local img = canvas:new(self.background)
		canvas:compose(20,0, img)
		canvas:flush()
   end
   self.color = color
   self.x = x
   self.width = width
   self.y = y
   self.size = size
   self:draw_itens(color)
     print("o size no show é: " .. self.size)

end

function TextMenu:draw_itens() 
  print("o size é na impressão: " .. self.size)
  contador = 1
  canvas:attrColor(color[1],color[2],color[3],0)
  canvas:attrFont("verdana", self.size)
  local y = self.y
  while(contador <= #self.itens) do
  	  current_item = ProcessLine(self.itens[contador])
      canvas:drawText(self.x, y, current_item)
      dx, dy = canvas:measureText(current_item)
      y = y + dy
    contador = contador + 1
  end
  canvas:flush()
end


function TextMenu:showTeste(x,y,width, background, color, size)
	-- canvas:clear(self.x, self.y, 1280, 720)
	self.background = background
	if (self.background ~= '') then
   		local img = canvas:new(self.background)
		canvas:compose(20,0, img)
		canvas:flush()
   end
   self.color = color
   self.x = x
   self.width = width
   self.y = y
   self.size = size
   self:draw_itensTeste()
     print("o size no show é: " .. self.size)

end


function TextMenu:setHandler(_handler)
  -- event.register(_handler)
end

function TextMenu:draw_itensTeste() 
  print("o size é na impressão: " .. self.size)
  contador = 1
  canvas:attrColor(color[1],color[2],color[3],0)
  canvas:attrFont("verdana", self.size)
  local y = self.y
  while(contador <= #self.itens) do
  	  current_item = ProcessLine(self.itens[contador])
      canvas:drawText(self.x, y, current_item)
      dx, dy = canvas:measureText(current_item)
      y = y + 50
    contador = contador + 1
  end
  canvas:flush()
end

function TextMenu:draw_images(path_img, x, y)
	img_1 = canvas:new(path_img)
	canvas:compose(x, y, img_1)
	canvas:flush() 
end


