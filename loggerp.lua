function depurador(text, x, y, time_sec)
   -- limpar()
   canvas:attrColor(0,0,0,0)
   canvas:attrFont("tiresias", 18)
   canvas:drawText(x, y, text)
   canvas:attrColor(255,255,255,0)
   canvas:flush()
   os.execute("sleep ".. time_sec .."")
end

function limpar()
    canvas:clear(50, 400, 1200, 400)
    canvas:flush()
end