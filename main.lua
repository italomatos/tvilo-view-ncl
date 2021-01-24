require 'loggerp'
require 'util'
require 'comm/tcp'
require 'comm/rest'
require 'panel'
require 'Entities2AccentedChars'
require 'menu'
require 'imagePanel'
require 'parse_xml'
require 'ask'

listener = true

local p = TextPanel:new()

local titulo_conteudo=""
local posicao_alternativa = 1
local ultima_alternativa = 0
local primeira_alternativa = 0	
local indice_atual = 0
aula = {titulo="", descricao="", conteudos={}, nav={}}
slide = {tipo="", conteudo="", titulo=""}
conexao = Rest:new()

local indice_navegacao = {} 
-- AQUI
local current_type = 'MENU'
local menu_counter = 1


function writeText(x,y,text)
	-- img = canvas:new('tarja.png')
	--    canvas:compose(20, 380, img)
	canvas:attrColor(255,255,255,0)
	-- canvas:clear()
	canvas:attrFont("verdana",32)
	canvas:drawText(x, y, text)
	canvas:flush()
end

function showMenu()
	-- depurador("Vamos abrir o XML!",320,20,1)
	current_type = 'MENU'
	content = readContentFile("config.xml")
	
	-- depurador("Conseguimos ler o XML!",320,40,1)
	
	if content ~= "" then
	-- 	depurador("Existe um arquivo XML",320,60,1)
		resultHandler(content)
	else
	-- 	depurador("O XML vai ser pegue do servidor!",320,60,1)
	    -- conexao:request('GET', 'http://trainingmaker.sidp.com.br/aulas.xml',resultHandler)
	end 
end

function init()
	showMenu()
	-- p:show(85, 60, 440, "")

	-- draw_options()
end

function resultHandler(dados)
	-- depurador("Coletando XML:",320,80,1)
    _xml = collect(dados)
    -- depurador("Desenhando MENU:",320,120,1)
    canvas:flush()
	draw_menu()
    -- draw_control()
end


local mtxt = {id=7, ant_id=1, prox_id=8, conteudo=6, titulo=10, conteudo_extra=3}
local mimg = {id=7, ant_id=1, prox_id=8, conteudo=2, titulo=10, conteudo_extra=3}
local mques = {id=7, ant_id=1, prox_id=8,conteudo=2, titulo=2, conteudo_extra=3}
local malt = {correta=2, rotulo=6, prox_id=5}


function parseAulaXmlToObject(aulaXml)
	aula = {titulo="", descricao="", conteudos={}}
	contador = 1
	contador_quest = 1
    while(contador <= #aulaXml[15]) do
    	print("Tipo do conteudo: " .. aulaXml[15][contador]["xarg"]["type"])
        tipo = aulaXml[15][contador]["xarg"]["type"]
		if (tipo == "Texto") then
			aula.conteudos = array_push(aula.conteudos, {conteudo_extra=aulaXml[15][contador][mtxt["conteudo_extra"]][1],id=aulaXml[15][contador][mtxt["id"]][1],ant_id=aulaXml[15][contador][mtxt["ant_id"]][1],prox_id=aulaXml[15][contador][mtxt["prox_id"]][1],tipo="Texto", conteudo=ProcessLine(aulaXml[15][contador][mtxt["conteudo"]][1]), titulo=ProcessLine(aulaXml[15][contador][mtxt["titulo"]][1])})
		elseif (tipo == "Figura") then
			aula.conteudos = array_push(aula.conteudos, {conteudo_extra=aulaXml[15][contador][mtxt["conteudo_extra"]][1],id=aulaXml[15][contador][mimg["id"]][1],ant_id=aulaXml[15][contador][mimg["ant_id"]][1],prox_id=aulaXml[15][contador][mimg["prox_id"]][1],tipo="Figura", conteudo=aulaXml[15][contador][mimg["conteudo"]][1], titulo=ProcessLine(aulaXml[15][contador][mimg["titulo"]][1])})
		elseif (tipo == "Questionario") then
			conteudo_question = {conteudo_extra=aulaXml[15][contador][mtxt["conteudo_extra"]][1], id=aulaXml[15][contador][mques["id"]][1],ant_id=aulaXml[15][contador][mques["ant_id"]][1],prox_id=aulaXml[15][contador][mques["prox_id"]][1],tipo="Questionario", conteudo=ProcessLine(aulaXml[15][contador][mques["conteudo"]][1]), titulo=ProcessLine(aulaXml[15][contador][mques["titulo"]][1]), alternativas={}}
			-- Alternativas
			for x=1, #aulaXml[15][contador][15] do
				conteudo_question.alternativas = array_push(conteudo_question.alternativas, {prox_id=aulaXml[15][contador][15][x][malt["prox_id"]][1],rotulo= aulaXml[15][contador][15][x][malt["rotulo"]][1], correta={aulaXml[15][contador][15][x][malt["correta"]][1]}}) 
			end
			aula.conteudos = array_push(aula.conteudos, conteudo_question)
			print("Numero de alternativas: " .. #conteudo_question.alternativas)
		end
		contador = contador + 1
	end
	return aula
end


function get_index_root_node(aulaXml) 
	contador = 1
	while(contador <= #aulaXml[15]) do
		if (aulaXml[15][contador][9][1] == "true") then
			return contador
		end
		contador = contador + 1
	end
	return 0
end


function find_by_id(contents, id)
	for x=1, #contents do
	    if (contents[x].id == id) then
            return contents[x],x
	    end
	end
	return nil,nil
end

function handler(evt)
    local valid_keys = {"1","2","3","4","5","6","7","8","9","0"}
	if evt.class == "ncl" and evt.type == "presentation" and evt.action=="start" and listener == true then
        -- canvas:flush()
		-- os.execute("sleep 1")
    	init()
    elseif current_type ~= 'AJUDA' and current_type ~= 'MENSAGEM' and current_type ~= 'MENU' and  evt.class=='key' and evt.type=='press' and (evt.key ~= 'CURSOR_UP') and (evt.key ~= 'CURSOR_DOWN') then -- and (evt.key ~= 'CURSOR_LEFT') and (evt.key ~= 'CURSOR_RIGHT') 
		-- AQUI
		posicao_alternativa = 1
		primeira_alternativa = 0
		ultima_alternativa = 0
		
		if evt.key == "CURSOR_UP" and posicao_alternativa == 1 then
			primeira_alternativa = 1
		end
		if evt.key == "CURSOR_UP" and posicao_alternativa ~= 1 then
			posicao_alternativa = posicao_alternativa - 1
		end
		if evt.key == "CURSOR_DOWN" and posicao_alternativa ~= 1 then
			posicao_alternativa = posicao_alternativa + 1
		end
		if evt.key == "CURSOR_DOWN" and posicao_alternativa == #aula.conteudos[indice_atual].alternativas then
			ultima_alternativa = 1	
		end
        if aula.conteudos[indice_atual].tipo == "Questionario" and evt.key ~= "CURSOR_LEFT" and array_has(valid_keys, evt.key) and tonumber(evt.key) <= #aula.conteudos[indice_atual].alternativas then
			canvas:clear(0, 0, 1280, 720)
			print(aula.conteudos[indice_atual].alternativas[tonumber(evt.key)].prox_id)     
		    prox_slide, tmp_indice_atual = find_by_id(aula.conteudos,aula.conteudos[indice_atual].alternativas[tonumber(evt.key)].prox_id)
			if prox_slide then
				array_push(indice_navegacao,aula.conteudos[indice_atual].id)
				showSlide(prox_slide)
				indice_atual = tmp_indice_atual
				showPagination(aula.conteudos,indice_atual)
			end
			
			--canvas:clear()
		elseif( evt.key == 'YELLOW' ) then
			draw_Mensagem()
        elseif (evt.key == 'GREEN') then
            canvas:clear(0, 0, 1280, 720)
			showMenu()
		elseif (evt.key == 'RED') then
		
		elseif ( evt.key == 'BLUE' ) then
			draw_Ajuda()
        elseif (indice_atual > 0) then
        	-- depurador("Escrever paginação: ",320,260,1)
        	showPagination(aula.conteudos,indice_atual)
            if ( evt.key == "CURSOR_RIGHT") then
                prox_slide, tmp_indice_atual = find_by_id(aula.conteudos, aula.conteudos[indice_atual].prox_id)
                if prox_slide then
                	array_push(indice_navegacao,aula.conteudos[indice_atual].id)
                	-- depurador("prox_slide não é nulo!", 320, 20, 1)
                    indice_atual = tmp_indice_atual
                	-- depurador("Tamanho da pilha atual: " .. #indice_navegacao, 320, 20, 1)
					canvas:clear(0, 0, 1280, 720)
                    showSlide(prox_slide)
                    showPagination(aula.conteudos,indice_atual)
                end
            elseif(evt.key == "CURSOR_LEFT") then
            	if (#indice_navegacao > 0) then 
	            	ant_id = indice_navegacao[#indice_navegacao]
	            	array_pop(indice_navegacao)
	                ant_slide, tmp_indice_atual = find_by_id(aula.conteudos, ant_id)
	                if ant_slide then
	                    indice_atual = tmp_indice_atual
	                    canvas:clear(0, 0, 1280, 720)
	                    showSlide(ant_slide)
	                    showPagination(aula.conteudos,indice_atual)
	                end
                end
            end
        end
	elseif current_type == 'AJUDA' and current_type ~= 'MENSAGEM' and current_type ~= 'MENU' and  evt.class=='key' and evt.type=='press' and (evt.key ~= 'CURSOR_UP') and (evt.key ~= 'CURSOR_DOWN') then -- and (evt.key ~= 'CURSOR_LEFT') and (evt.key ~= 'CURSOR_RIGHT') 
		-- canvas:clear(0,0,1280,720)
		print(evt.key .. " numero apertado")
		if ( evt.key == "1" ) then
			draw_Ajuda()
		elseif( evt.key == "2") then
			draw_AjudaQRCode()
		elseif ( evt.key == 'GREEN') then
			canvas:clear(0,0,1280,720)
			showMenu()
		elseif (evt.key == 'YELLOW') then
			draw_Mensagem()
		end
	elseif current_type ~= 'AJUDA' and current_type == 'MENSAGEM' and current_type ~= 'MENU' and  evt.class=='key' and evt.type=='press' and (evt.key ~= 'CURSOR_UP') and (evt.key ~= 'CURSOR_DOWN') then -- and (evt.key ~= 'CURSOR_LEFT') and (evt.key ~= 'CURSOR_RIGHT') 
		if(evt.key == "GREEN") then
			canvas:clear(0,0,1280,720)
			showMenu()
		elseif (evt.key == "BLUE") then
			draw_Ajuda()
		end
	end
end

function showSlide(slide)
	-- AQUI 
	current_type = 'SLIDE'
    if (slide.tipo == "Texto") then
        p = TextPanel:new()
        p:show(455, 80, 210, "")
		temp = titulo_conteudo .. " - " .. slide.titulo
		--Não usaremos por enquanto o p:writeTitle, já que ele amarra a localização do próprio com a localização do conteúdo, o que por hora
		--com o novo layout será diferente
        writeText(440, 25, temp)
        p:writeText(slide.conteudo)
    elseif (slide.tipo == "Figura") then
        print("url: " .. slide.conteudo)
        nome_arquivo = string.match(slide.conteudo,  "[^/]/[^/]+\.[a-z]+")
		if (string.match(slide.conteudo, "^http://") ~= nil) then
                print("vamos ler imagem de um servidor")
                -- depurador("Requisitando a Imagem!", 320, 20, 1)
                conexao:request("GET", slide.conteudo, showImageFile)
                -- Rest.getFile(slide.conteudo, showImageFile)
                print("arquivo: " .. string.sub(nome_arquivo, 3, #nome_arquivo))
        else
                print("vamos ler imagem local")
                showLocalImage(slide.conteudo)
        end
        writeText(440, 25, titulo_conteudo)
    elseif (slide.tipo == "Questionario") then
		opcoes = {}
        for x=1, #slide.alternativas do
                opcoes = array_push(opcoes, slide.alternativas[x].rotulo)
        end
        q = AskMenu:new()
        q.options = opcoes
        q:show( slide.conteudo,455, 80, 230, "" ) 
        
        axis_y_pos = 0
        axis_y = 0
        --for x=1, #slide.alternativas do
        	--if (posicao_alternativa == x) then
        		--canvas:attrColor(100,100,100,0)
        	--else
        		--canvas:attrColor(255,255,255,255)
        	--end
        	--axis_y = 146 + axis_y_pos
        	--canvas:attrFont("verdana", 26)
        	--canvas:drawText(370, axis_y, slide.alternativas[x].rotulo)
        --end
        
        -- mostra texto de informação de navegabilidade
        -- atribui cor da dica: amarelo
	 	canvas:attrColor(255,255,0,0)
	 	-- atribui tipo e tamanho da fonte
	 	canvas:attrFont("verdana", 32)
        -- escreve o texto de informação de navegabilidade
        --canvas:drawText(585, 375, "Aperte o botão do seu controle remoto")
        --canvas:drawText(585, 400, "que corresponde à sua resposta.")
        canvas:flush()
        
        -- inicializa variável de posicionamento da imagem do botão no eixo y
        axis_y_pos = 0
        axis_y = 0
        -- Insere as imagens dos botões das alternativas:
        for aux=1, #slide.alternativas do
        	axis_y = 225 + axis_y_pos
        	q:draw_images("Elementos/opcao".. aux .. ".png", 530, axis_y)
        	axis_y_pos = axis_y_pos + 50
        end
        writeText(440, 25, titulo_conteudo)

    end
    if (slide.conteudo_extra ~= nil and slide.conteudo_extra ~= "") then
    	--print("Tem qr code: " .. slide.conteudo_extra) 
    	draw_qrcode(slide.conteudo_extra)
    end
end

-- função para mostrar a paginação e o navegador de páginas --
function showPagination(content_slide, index_slide)
	page_n = TextPanel:new()
	-- atribui cor da paginação branca
    canvas:attrColor(255,255,255,0)
    -- canvas:clear()
    -- atribui tipo e tamanho da fonte
    canvas:attrFont("verdana", 32)
    -- se o índice atual for igual ao máximo de slides , mostra a navegação para o slide anterior
    -- depurador("Tipo: ".. content_slide[index_slide].tipo .. "", 320, 220, 1)
    if (content_slide[index_slide].tipo ~= "Questionario") then
	    -- se o próximo id da aula for zero, mostra a navegão para o slide anterior
	    ant_id = indice_navegacao[#indice_navegacao]
	    if (tonumber(aula.conteudos[index_slide].prox_id) == 0) then
	    	-- depurador("Anterior", 320, 180, 1)
	    	page_n:draw_images("Elementos/SetaEsq.png",875,575)
	    	-- canvas:drawText(400, 390, "< ANT")
	        
	     -- se o índice atual for igual a hum, inicia a paginação, mostrando a navegação para o slide posterior
	    elseif (indice_atual == 1) then
	    	-- depurador("Posterior", 320, 180, 1)
	    	page_n:draw_images("Elementos/SetaDir.png",875,575)
	        -- canvas:drawText(450, 390, "PROX >")
	    
	    -- se o índice atual for diferente da quantidade máxima de índices do slide, mostra a navegação para o slide anterior e próximo
	    elseif (indice_atual ~= #aula.conteudos) then
	    	-- depurador("Ambos", 320, 60, 1)
	    	page_n:draw_images("Elementos/SetaEsq.png",875,575)
	    	canvas:drawText(910, 569, " | ")
	    	page_n:draw_images("Elementos/SetaDir.png",945,575)
	    	-- canvas:drawText(400, 390, "< ANT|PROX >")
	    end
    end
    -- depurador("Final paginação", 320, 200, 1)
    canvas:flush()
end

function showLocalImage(name)
    p = ImagePanel:new()
    p:show(455, 80, 240, "")
    p:showImage(name, aula.conteudos[indice_atual].titulo)
end

function showImageFile(data)
    -- depurador("Parabens vamos renderizar a imagem!", 320, 20, 1)
    createFile(data, "imagem.png", true)
    showLocalImage("imagem.png")
end

function menu_handler(evt)
	print("Menu Handler esta escutando.")
	options = {'1','2','3','4','5','6','7','8','9'}
	-- AQUI
	if current_type ~= 'AJUDA' and current_type ~= 'MENSAGEM' and current_type == 'MENU' and evt.class=='key' and evt.type=='press' and listener == true and (evt.key ~= 'CURSOR_LEFT') and (evt.key ~= 'CURSOR_RIGHT') then
		if (evt.key == 'BLUE') then
			draw_Ajuda()
		elseif( evt.key == 'YELLOW') then
			draw_Mensagem()
		end
		if (evt.key == 'CURSOR_UP') then
			update_menu('UP',menu_counter)
		end
		if (evt.key == 'CURSOR_DOWN') then
			update_menu('DOWN',menu_counter)
		end
		if array_has(options, evt.key) then
			canvas:clear(0, 0, 1280, 720)
			selected_item = tonumber(evt.key)
			if ( selected_item > 0 and selected_item <= #_xml[2]) then
		      	-- após selecionar a opção do menu através do controle, a aula é aberta
		        -- depurador("Opção Selecionada! Coletando conteúdo do XML",320,20, 1)
		        titulo_conteudo = ProcessLine(_xml[2][selected_item][10][1])
				indice_navegacao = {}		        
				aula = parseAulaXmlToObject(_xml[2][selected_item])
		        indice_atual = get_index_root_node(_xml[2][selected_item])
		        -- depurador("Coleta concluídas! Mostrando conteúdo:",320,40, 1)
		        -- depurador(aula.conteudos[indice_atual].titulo)
		        showSlide(aula.conteudos[indice_atual])
			end
		end		
	end
end

function draw_qrcode(conteudo)
	canvas:attrFont("verdana", 26)
	canvas:attrColor(255,255,255,0)
	canvas:drawText(135,320, "Saiba Mais:")
	local img_1 = canvas:new(conteudo)
	canvas:compose(110, 360, img_1)
	canvas:flush() 
end

function draw_Ajuda()
	print("chamou o draw_Ajuda() ")
	canvas:clear(0,0,1280,720)
	current_type = 'AJUDA'
	local img_1 = canvas:new("Elementos/FundoEscuro.png")
	local img_2 = canvas:new("Elementos/AjudaNavegacao.png")
	canvas:compose(0,0,img_1)
	canvas:compose(441,67,img_2)
    m = TextMenu:new()
    m.itens = {}
    m:setHandler(menu_handler)
	m.itens = array_push(m.itens, ProcessLine("1) Navegação"))
	m.itens = array_push(m.itens, "2) Usando o Celular(QRCODE)")
	color={255,255,255}
	canvas:attrColor(255,255,255,0)
	canvas:attrFont("verdana", 26)
	canvas:drawText(165, 325, "Menu")
    m:show(10, 365, 285, "", color, 20 )
	writeText(440, 25, ProcessLine("Navegação"))
	canvas:flush()
end

function draw_AjudaQRCode()
	canvas:clear(0,0,1280,720)
	current_type = 'AJUDA'
	local img_1 = canvas:new("Elementos/FundoEscuro.png")
	local img_2 = canvas:new("Elementos/AjudaQRcode.png")
	canvas:compose(0,0,img_1)
	canvas:compose(441,67,img_2)
    m = TextMenu:new()
    m.itens = {}
    m:setHandler(menu_handler)
	m.itens = array_push(m.itens, ProcessLine("1) Navegação"))
	m.itens = array_push(m.itens, "2) Usando o Celular(QRCODE)")
	color={255,255,255}
	canvas:attrColor(255,255,255,0)
	canvas:attrFont("verdana", 26)
	canvas:drawText(165, 325, "Menu")
    m:show(10, 365, 285, "", color, 20 )
	writeText(440, 25, ProcessLine("Usando Celular(QRCODE)"))
	canvas:flush()
end

function draw_Mensagem()
	canvas:clear(0,0,1280,720)
	current_type = 'MENSAGEM'
	local img_1 = canvas:new("Elementos/FundoMensagem.png")
	canvas:compose(0,0,img_1)
	writeText(440, 25, ProcessLine("Mensagem"))
	canvas:flush()
end

-- draw_menu: Cria uma variável do tipo TextMenu, determina que esta variável seja manipulada pelo menu_handler e 
-- insere na variável um vetor de itens do elemento _xml para serem exibidos no menu. 
function draw_menu() 
    m = TextMenu:new()
    m.itens = {}
    m:setHandler(menu_handler)
    contador = 1
    while(contador <= #_xml[2]) do 
    	m.itens = array_push(m.itens,contador .. ") ".. ProcessLine(_xml[2][contador][10][1]))
    contador = contador + 1
    menu_counter = menu_counter + 1
    end
	color={255,255,255}
	canvas:attrColor(255,255,255,0)
	canvas:attrFont("verdana", 26)
	canvas:drawText(165, 325, "Menu")
    m:show(10, 365, 285, "", color, 20 )  
    -- m:draw_images("Elementos/Controle.png",330,50)
end

function draw_control()
	ini_image = TextMenu:new()
	ini_image.itens = {}
	ini_image:setHandler(menu_handler)
	ini_image:draw_images("Elementos/Controle.png", 635, 40)
end

-- depurador("Iniciando handler",320,320,1)
-- depurador("Iniciando handler",320,320,1)
event.register(handler)
-- Registro da função para escutar as teclas do menu.
-- depurador("Iniciando menu_handler",320,340,1)
event.register(menu_handler)

