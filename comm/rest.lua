Rest = {host = "",port = "",method = 'GET',url = "",termina = 0,fim = nil,handler = "", connection, tam = "", dados=""}

function Rest:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  function o.handlerProxy(evt)
	o:requestHandler(evt)
  end
  event.register(o.handlerProxy)
  return o
end

function Rest:draw_busy()
	img = canvas:new('images/ampulheta.jpg')
	canvas:compose(577, 20, img)
	canvas:flush() 
end

function Rest:request(method, url, handler)
	listener = false
	-- log("Vamos requisitar!")
	self.dados = ""
	self.fim = nil
	self.termina = 0
	self.connection = nil
	self.tam = 0
	self.handler = handler
	self.method  = method
	self.host, self.port, self.url = self:extractURLInformation(url)
	print("HTTP REQUEST")
    print(self.method.." ".. self.url .." HTTP/1.0\r\nHost:"..self.host.."\r\n\r\n")
    print("FIM HTTP REQUEST")
    req = { class="tcp", type="connect", host=self.host,port=self.port }
	event.post("out",req)
end


function Rest:requestHandler(evt)
	if evt.class=="tcp" and evt.type=="connect" then
		-- log("Conexao estabelecida com sucesso!")
		self:draw_busy()
		self.connection = evt.connection
		req = { class="tcp", type="data", connection=self.connection, value=self.method.." "..self.url.." HTTP/1.0\r\nHost:"..self.host.."\r\n\r\n" }
		print("Request: " .. self.method.." "..self.url.." HTTP/1.0\r\nHost:"..self.host.."\r\n\r\n")
		event.post("out",req)
	elseif evt.class == "tcp" and evt.type == "disconnect" then
		print("Desconectado meu amigo!")
		-- log("Fomos desconectado!")
	elseif evt.class=="tcp" and evt.type == "data" then
		print("Vamos receber dados agora!")
		-- log("Vamos receber dados agora!")
		if (evt.error ~= nil) then
			print("Error " .. evt.error)
		else
			if ( self.fim == nil ) then
				print("Comecamos a receber os dados")
				self.ini, self.fim = string.find(evt.value, "\r\n\r\n")
				print("Inicio dos dados: " .. self.ini .. "Fim dos dados: "..self.fim)
				local cabecalho = string.sub(evt.value, 1, self.ini)
				print("Cabecalho Response")
				print(cabecalho)
				self.tam = string.match(cabecalho, "Length: [0-9]+")
				self.tam = tonumber(string.match(self.tam, "[0-9]+"))
				if (self.tam) then
					print("Tamanho do arquivo: " .. self.tam)
				else
					print("Tamanho muito doido!")
				end
			end
			-- log("Vamos receber os dados!")
			print("Vamos receber os dados!")
			self.dados = self.dados .. evt.value
			print(self.dados)
			print("fim de pacote")
			if (#self.dados >= self.tam) then
				print("dados:") 
				print(self.dados) 
				print("fim dos dados")
				local content = string.sub(self.dados,self.fim + 1,#self.dados)
				print("inicio: " .. self.fim .. "fim: " .. #self.dados) 
				-- event.unregister(self.handlerProxy)
				self.handler(content)
				self.handler = doNothing
				listener = true
				-- request = { class="tcp", type='disconnect', connection=conexao }
				-- event.post("out",request)
				-- createFile(content, "imagem.jpg", true)
				-- _myHandler("imagem.jpg")
			end
		end
	end
end

function doNothing(evt)
end
-- Method that extract host, port and url from url address.
function Rest:extractURLInformation(url)
	local _host = ""
	local _port = ""
	local _url  = ""
	for block in url:gmatch("//[a-z0-9.:]+/") do
		 _host = string.gsub(block, "/","")
    end
    if _host then
		 local posicao = string.find(_host, ":")
		 if posicao then
				 _port = string.sub(_host, posicao + 1, #_host)
				 _host = string.sub(_host, 1, posicao - 1)
		 else
			 _port = 80
		 end
    end
    index_ini, index_fim = string.find(url, _host)
    _url = string.sub(url, index_fim + 1, #url)
	return _host, _port, _url
end


