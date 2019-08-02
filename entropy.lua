function calc_potential(list)
	local s = 0
	local n = #list
	for i = 1,n do
		for j = i+1,n do
			local w = 1
			
			--w = 1/(i*j)
			--w = 1/(1+math.abs(i-j))
			--w = 1+math.abs(i-j)
			w = 1/(i+j)

			s = s + w*dyad(list[i],list[j])
		end
	end
	return s
end

function dyad(a,b)
	f = math.abs(math.floor(a-b))



	local v = entr[f]
	if(v) then
		--local ff = f - 1200
		return entr[f] + math.abs(60*60/(f*f)) --+ math.abs(60*60/(ff*ff)) 
	else
		if(f == 0) then
			return 100000
		end
		print("range!!")
		return math.abs(f)
	end
end


function farey(n,h)
	--local benedetti = 2^h
	list = {}

	a,b,c,d = 0, 1, 1, n
	--table.insert(list, {b,a})
	while (c <= n) do
		k = math.floor((n+b)/d)
		a, b, c, d = c, d, (k*c-a), (k*d-b)

		if(a*b < h) then
			table.insert(list, {b,a})
		end
		--print(b .. "/" .. a, a*b)
	end
	print(#list)
	return list
end

function ratio2c(p,q)
	return 1200*math.log(p/q)/math.log(2)
end

function gaussian(x)
	local s = 10--9
	return math.exp((-x*x)/(2*s*s))
end

function do_entropy()
	--print(math.log(1))
	seq = farey(300,10000)

	entr = {}
	local n = 1
	for i = 0,3600,1 do
		local s = 0
		local q = {}
		for j,v in ipairs(seq) do
			local d = ratio2c(v[1],v[2])
			local l = 0
			if(math.abs(i-d) < 80) then
				l = gaussian(i-d)/math.sqrt(v[1]*v[2])
			end
			s = s + l
			q[j] = l
		end
		local e = 0
		for j,v in ipairs(q) do
			local p = v/s
			if(p>0) then
				e = e - p*math.log(p)
			end
		end
		--print(e)
		--print(e)
		entr[n] = e
		n = n + 1

	end

	maxe = 0
	mine = 50
	for i,v in ipairs(entr) do
		maxe = math.max(v,maxe)
		mine = math.min(v,mine)
	end
	--print(mine,maxe)
end

function graph()
	love.graphics.setColor(.3,.3,.3)

	local scale = maxe-mine
	for i,v in ipairs(entr) do
		if(i>1) then
			local x1 = 800*i/(#entr) + 5
			local y1 = 600*(1 - (v-mine)/scale) + 10
			local x2 = 800*(i-1)/(#entr) + 5
			local y2 = 600*(1 - (entr[i-1]-mine)/scale) + 10
			love.graphics.line(x1,y1,x2,y2)
		end
	end
end