AskMenu = {ask="", correct_item=0, options={},x = 700, y = 200, width = 300,texto = "",linha = 1, background='', menu="",panel=""}

function AskMenu:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function AskMenu:show(ask,x, y, width, background)
  self.ask = ask
  self.menu = TextMenu:new()
  self.menu.itens = self.options
  self.background = background
  self.x = x
  self.width = width
  self.y = y
  self.panel = TextPanel:new()
  color={0,0,0}
  self.panel:show(x,y,width, "")
  self.menu:showTeste(self.x + 130,self.panel:getHeight() + y + 95, self.width, self.background, color, 24)
  self.panel:writeTitle(self.ask)
end


function AskMenu:draw_images(path_img, x, y)
	img_1 = canvas:new(path_img)
	canvas:compose(x, y, img_1)
	canvas:flush() 
end