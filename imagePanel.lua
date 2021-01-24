ImagePanel = {x = 10, y = 10, width = 300, background=''}


function ImagePanel:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ImagePanel:show(x,y,width, background)
  canvas:clear(0, 0, 1280, 720)
  self.background = background
	if (self.background ~= '') then
   local img = canvas:new(self.background)
	canvas:compose(20,0, img)
	canvas:flush()
   end
   self.x = x
   self.width = width
   self.y = y
end

function ImagePanel:showImage(image,title)
	local img = canvas:new(image)
	width, height = img:attrSize() 
	p = TextPanel:new()
	p:show(self.x + 10, (self.y + 10) + height, self.width, nil)
	p:writeText(title)
	canvas:compose(self.x + 10,self.y + 10, img )
	canvas:flush()
end


function ImagePanel:removeImage()

end

function ImagePanel:draw_images(path_img, x, y)
	img_1 = canvas:new(path_img)
	canvas:compose(x, y, img_1)
	canvas:flush() 
end