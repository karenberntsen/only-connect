r1 = {}

--[[ NOTE TO SELF: order of heiroglyphs is
Reeds, Lion, Twisted,
Viper, Water, Eye.
]]

musicNoteImageDotPng = love.graphics.newImage("assets/musicRound.png")

selection = 0 -- 0 = selecting..., 1=reeds, 2=lion etc.
selected = {false,false,false,false,false,false} -- which questions are done?
tweening = 0 -- animations until certainly pressed
numberOfClues = 0 -- 1=5pts, 2=3pts...
timerPos = 0 -- what clue is the timer hovering over?
revealedAnswer = false -- as the name suggests, is the answer revealed?
locs = {{150*scale,150*scale},{300*scale,150*scale},{500*scale,150*scale},{150*scale,300*scale},{300*scale,300*scale},{500*scale,300*scale}} -- where clues glide from
timer = 45 -- TIMER, duh.
alert = false -- tells the host that there's only THREE SECONDS LEFT WHAT

function r1.load()
	--[[ As you might have noticed, a new library has appeared!
		*pokemon encounter music plays*
		See tween.lua for more details.
	]]
	selected = {false,false,false,false,false,false}
	r = newTween(119,183,1,0)
	g = newTween(197,214,1,0)
	b = newTween(215,237,1,0)
	s = newTween(0,0.25,0.1) -- this opens it up from the top
	pX = newTween(locs[1][1],15,1)
	pY = newTween(locs[1][2],230,1) --just so updateTween() doesn't panic
	answerTween = newTween(0,0,1)
	whatTeam()
end

function r1.draw()
	if selection==0 then
		-- draw the boxes, heiroglyphs etc.
		highlighting(1)
		love.graphics.draw(rd,100*scale+xshift,150*scale,0,0.25*scale,0.25*scale)
		highlighting(2)
		love.graphics.draw(rd,300*scale+xshift,150*scale,0,0.25*scale,0.25*scale)
		highlighting(3)
		love.graphics.draw(rd,500*scale+xshift,150*scale,0,0.25*scale,0.25*scale)
		highlighting(4)
		love.graphics.draw(rd,100*scale+xshift,300*scale,0,0.25*scale,0.25*scale)
		highlighting(5)
		love.graphics.draw(rd,300*scale+xshift,300*scale,0,0.25*scale,0.25*scale)
		highlighting(6)
		love.graphics.draw(rd,500*scale+xshift,300*scale,0,0.25*scale,0.25*scale)
		-- then after all of the squares are drawn
		love.graphics.setColor(255,255,255)
		love.graphics.draw(heiroglyphs["reeds"],100*scale+xshift,150*scale,0,scale,scale)
		love.graphics.draw(heiroglyphs["lion"],300*scale+xshift,150*scale,0,scale,scale)
		love.graphics.draw(heiroglyphs["twisted"],500*scale+xshift,150*scale,0,scale,scale)
		love.graphics.draw(heiroglyphs["viper"],100*scale+xshift,300*scale,0,scale,scale)
		love.graphics.draw(heiroglyphs["water"],300*scale+xshift,300*scale,0,scale,scale)
		love.graphics.draw(heiroglyphs["eye"],500*scale+xshift,300*scale,0,scale,scale)
	else
		-- a question has been selected!
		for i=1,numberOfClues do
			love.graphics.setColor(colours("background"))
			if #(questionsR1[selection][i])<=25 then -- word wrap, shrink the clue if it's too long.
				love.graphics.setFont(fonttt)
			elseif #(questionsR1[selection][i])<=45 then
				love.graphics.setFont(fontt)
			else
				love.graphics.setFont(font)
			end
			if i == 1 then -- a special case for the first clue as it glides in, so the val()s of the tweens need to be taken into account
				if i == numberOfClues then
					love.graphics.draw(rd,val(pX)*scale+xshift,val(pY)*scale,0,0.25*scale,val(s)*scale)
				else
					love.graphics.draw(rd,15*scale+xshift,230*scale,0,0.25*scale,0.25*scale)
				end
				if pictureR1 == selection then --for picture rounds, don't print the clue unless the answer's appeared, and drawTheImage1()
					drawTheImage1(i)
					if revealedAnswer then
						love.graphics.setColor(0,0,0)
						love.graphics.printf(questionsR1[selection][i],25*scale+xshift,260*scale,180*scale,"center")
					end
				elseif musicR1 == selection then
					-- same rules apply
					if revealedAnswer then
						love.graphics.setColor(255,255,255,100)
					else
						love.graphics.setColor(255,255,255)
					end
					love.graphics.draw(musicNoteImageDotPng,(val(pX)+5)*scale+xshift,val(pY)*scale,0,scale,scale) -- draw that clef thing (treble clef, I know)
					if revealedAnswer then
						love.graphics.setColor(0,0,0)
						love.graphics.printf(questionsR1[selection][i],25*scale+xshift,240*scale,180*scale,"center")
					end
				else
					love.graphics.setColor(0,0,0)
					love.graphics.printf(questionsR1[selection][i],(val(pX)+10)*scale+xshift,(val(pY)+9)*scale,180*scale,"center")
				end
				if i == timerPos then
					-- THIS DRAWS THE TIMER
					love.graphics.setFont(fonttt)
					timerLength = ((45-timer)/45)*190
					love.graphics.setColor(colours("selected"))
					love.graphics.rectangle("fill",(val(pX)+5+(190*(i-1)))*scale+xshift,(val(pY)-50)*scale,timerLength*scale,40*scale)
					love.graphics.setColor(colours("unselected"))
					love.graphics.rectangle("fill",(val(pX)+5+(190*(i-1))+timerLength)*scale+xshift,(val(pY)-50)*scale,(190-timerLength)*scale,40*scale)
					love.graphics.setColor(255,255,255)
					love.graphics.print(points[1].." Points",(val(pX)+35)*scale+xshift,(val(pY)-50)*scale)
				end
			else
				-- now for clues 2-4
				-- (it's the same as above, essentially)
				if i == numberOfClues then
					love.graphics.draw(rd,(15+(190*(i-1)))*scale+xshift,230*scale,0,0.25*scale,val(s)*scale)
				else
					love.graphics.draw(rd,(15+(190*(i-1)))*scale+xshift,230*scale,0,0.25*scale,0.25*scale)
				end
				if i == timerPos then
					love.graphics.setFont(fonttt)
					timerLength = ((45-timer)/45)*190
					love.graphics.setColor(colours("selected"))
					love.graphics.rectangle("fill",(20+(190*(i-1)))*scale+xshift,180*scale,timerLength*scale,40*scale)
					love.graphics.setColor(colours("unselected"))
					love.graphics.rectangle("fill",(20+(190*(i-1))+timerLength)*scale+xshift,180*scale,(190-timerLength)*scale,40*scale)
					love.graphics.setColor(255,255,255)
					if timerPos<4 then
						love.graphics.print(points[timerPos].." Points",(50+(190*(i-1)))*scale+xshift,180*scale)
					else
						love.graphics.print(points[timerPos].." Point",(55+(190*(i-1)))*scale+xshift,180*scale)
					end
				end
				if #(questionsR1[selection][i])<=25 then -- WORD WRAP
					love.graphics.setFont(fonttt)
				elseif #(questionsR1[selection][i])<=45 then
					love.graphics.setFont(fontt)
				else
					love.graphics.setFont(font)
				end
				if pictureR1 == selection then
					drawTheImage1(i)
					if revealedAnswer then
						love.graphics.setColor(0,0,0)
						love.graphics.printf(questionsR1[selection][i],(25+(190*(i-1)))*scale+xshift,260*scale,180*scale,"center")
					end
				elseif musicR1 == selection then
					if revealedAnswer then
						love.graphics.setColor(255,255,255,100)
					else
						love.graphics.setColor(255,255,255)
					end
					if i == numberOfClues then
						love.graphics.draw(musicNoteImageDotPng,(15+(190*(i-1)))*scale+xshift,230*scale,0,1*scale,(val(s)*4)*scale)
					else
						love.graphics.draw(musicNoteImageDotPng,(15+(190*(i-1)))*scale+xshift,230*scale,0,scale,scale)
					end
					if revealedAnswer then
						love.graphics.setColor(0,0,0)
						love.graphics.printf(questionsR1[selection][i],(25+(190*(i-1)))*scale+xshift,240*scale,180*scale,"center")
					end
				else
					love.graphics.setColor(0,0,0)
					love.graphics.printf(questionsR1[selection][i],(25+(190*(i-1)))*scale+xshift,240*scale,180*scale,"center")
				end
			end
		end
		love.graphics.setFont(fonttt)
		if revealedAnswer then
			love.graphics.setColor(colours("blue"))
			love.graphics.draw(rd,5*scale+xshift,380*scale,0,0.98*scale,val(answerTween)*scale)
			love.graphics.setColor(255,255,255)
			love.graphics.printf(groupsR1[selection],30*scale+xshift,385*scale,730*scale,"center")
		end
	end
end

function drawTheImage1(n) -- guess what this does!
	if revealedAnswer then
		love.graphics.setColor(255,255,255,100)
	else
		love.graphics.setColor(255,255,255,255)
	end
	if n ~= 1 then
		if n == numberOfClues then
			love.graphics.draw(picturesR1[n],(42+(190*(n-1)))*scale+xshift,250*scale,0,0.8*scale,val(s)*3.2*scale)
		else
			love.graphics.draw(picturesR1[n],(42+(190*(n-1)))*scale+xshift,250*scale,0,0.8*scale,0.8*scale)
		end
	else
		love.graphics.draw(picturesR1[n],(val(pX)+32+(190*(n-1)))*scale+xshift,(val(pY)+20)*scale,0,0.8*scale,0.8*scale)
	end
end

function highlighting(p) -- fill it in (the heiroglyphs at the main screen)
	if selected[p] then
		love.graphics.setColor(colours("selected"))
	else
		love.graphics.setColor(colours("unselected"))
	end
	if tweening == p then
		love.graphics.setColor(val(r),val(g),val(b))
	end
end

function r1.update(dt)
	if not revealedAnswer then timerPos = numberOfClues end
	-- update ALL THE TWEENS
	if tweening ~= 0 then
		updateTween(r,dt)
		updateTween(g,dt)
		updateTween(b,dt)
	end
	if selection ~= 0 then
		updateTween(pX,dt)
		updateTween(pY,dt)
		-- deal with the timer
		if highlightingBg==0 and not revealedAnswer then
			timer = timer - dt
			if timer < 3 and (not alert) then
				print("Three seconds left")
				alert = true
			elseif timer < 0 then
				love.audio.play(worse)
				if currentTeam == 1 then highlightingBg=2 else highlightingBg=1 end
				numberOfClues = 4
				swapped = true
			end
		end
	end
	if revealedAnswer then
		updateTween(answerTween,dt)
	end
	updateTween(s,dt)
end

function r1.keypressed(key)
	-- Accept standard keypresses, space to move on etc.
	if selection ~= 0 then
		if key=="space" then
			if numberOfClues<4 and highlightingBg == 0 then
				numberOfClues=numberOfClues+1
				s = newTween(0,0.25,0.1)
				if selection == musicR1 then
					audioR1[numberOfClues-1]:stop()
					audioR1[numberOfClues]:play()
				end
				slide()
			elseif revealedAnswer then
				selection = 0
				tweening = 0
				numberOfClues = 0
				revealedAnswer = false
				allSel = true
				highlightingBg = 0
				if currentTeam == 1 then currentTeam=2 else currentTeam=1 end
				for i=1,6 do
					if not selected[i] then allSel = false end
				end
				if allSel then return true end
			end -- if the answer's not revealed then do nothing space. We want a buzz in.
		end
		-- buzz!
		if key==teamakey and highlightingBg==0 and currentTeam == 1 and (not revealedAnswer) then
			highlightingBg = 1
			if musicR1 == selection then audioR1[numberOfClues]:stop() end
			buzzIn(1)
		end
		-- buzz!
		if key==teambkey and highlightingBg==0 and currentTeam == 2 and (not revealedAnswer)then
			highlightingBg = 2
			if musicR1 == selection then audioR1[numberOfClues]:stop() end
			buzzIn(2)
		end
		-- they got it right!
		if key=="up" and highlightingBg~=0 then
			if highlightingBg == 1 then
				-- team 1 gets points!
				teama = teama + points[numberOfClues]
			else
				-- team 2 gets points!
				teamb = teamb + points[numberOfClues]
			end
			debugScorePrint()
			if musicR1 == selection then
				audioR1[numberOfClues]:stop() 
			end
			-- reveal it all!
			numberOfClues = 4
			revealedAnswer = true
			answerTween = newTween(0,0.1,0.1)
			highlightingBg = 0
			swapped = false
			slide()
		end
		-- they got it wrong...
		if key=="down" and highlightingBg~=0 then
			if not swapped then
				if highlightingBg==2 then highlightingBg=1 else highlightingBg=2 end
				if musicR1 == selection and numberOfClues < 4 then audioR1[4]:play() end
				numberOfClues = 4
				swapped = true
			else
				--trigger answer
				numberOfClues = 4
				revealedAnswer = true
				answerTween = newTween(0,0.1,0.1)
				highlightingBg = 0
				swapped = false
				if musicR1 == selection then
					audioR1[numberOfClues]:stop() 
				end
				slide()
			end
		end
	end
end

--reset for the next round
function commenceRound1(n)
	selected[n]=true
	selection=n
	numberOfClues=1
	s = newTween(0,0.25,0.1)
	pX = newTween(locs[n][1],15,0.2)
	pY = newTween(locs[n][2],230,0.2)
	timer = 45
	swoosh()
	alert = false
	if musicR1 == n then
		audioR1[1]:play()
	end
end


function playTheChosenSound(r)
	-- when selected, chime or slide (sfx)
	if r == musicR1 then
		love.audio.play(musicRoundGo)
	else
		slide()
	end
end

function r1.mousepressed(x,y,b)
	-- bounding boxes time! yaaaaaaaay.
	if selection == 0 then
		if x>=100*scale+xshift and x<300*scale+xshift and y>=100*scale and y<300*scale and (not selected[1]) then
			if tweening == 1 then
				commenceRound1(1)
				--go go go!
			else
				tweening = 1 -- tween tween tween!
				playTheChosenSound(1)
			end
		end
		if x>=300*scale+xshift and x<500*scale+xshift and y>=100*scale and y<300*scale and (not selected[2]) then
			if tweening == 2 then
				commenceRound1(2)
				--go go go!
			else
				tweening = 2 -- tween tween tween!
				playTheChosenSound(2)
			end
		end
		if x>=500*scale+xshift and x<700*scale+xshift and y>=150*scale and y<300*scale and (not selected[3]) then
			if tweening == 3 then
				commenceRound1(3)
				--go go go!
			else
				tweening = 3 -- tween tween tween!
				playTheChosenSound(3)
			end
		end
		if x>=100*scale+xshift and x<300*scale+xshift and y>=300*scale and y<450*scale and (not selected[4]) then
			if tweening == 4 then
				commenceRound1(4)
				--go go go!
			else
				tweening = 4 -- tween tween tween!
				playTheChosenSound(4)
			end
		end
		if x>=300*scale+xshift and x<500*scale+xshift and y>=300*scale and y<450*scale and (not selected[5]) then
			if tweening == 5 then
				commenceRound1(5)
				--go go go!
			else
				tweening = 5 -- tween tween tween!
				playTheChosenSound(5)
			end
		end
		if x>=500*scale+xshift and x<700*scale+xshift and y>=300*scale and y<450*scale and (not selected[6]) then
			if tweening == 6 then
				commenceRound1(6)
				--go go go!
			else
				tweening = 6 -- tween tween tween!
				playTheChosenSound(6)
			end
		end
	end
end