class 'PassiveZones'

--Note: Higher numbers can have a negative effect on performance.
local SphereLines1 = 300 --The number of lines the sphere has from top to bottom.
local SphereLines2 = 150 --The higher this number the better the sphere looks. 

function PassiveZones:__init()

	self.ShowZones = true --Set to false to disable visible zones
	self.VisDist   = 800 --The distance in meters from the edge of the zone that it becomes visible.
	self.ZoneColor = Color(0, 0, 255, 70) --The color of the sphere

	self.Zones = {

		{
			"RaceTrack",		 --Trigger Name
			{0,0,0,1}, 			 --Trigger angle
			{-7116,224,-4999}, --Center of Trigger
			800 	 	 			 --Trigger radius
		},

	}

	--Vars
	self.Triggers = {}
	self.TriggersData = {}
	self.DisableFiring = false
	self.WasInPassive = false

	--Events
	Events:Subscribe("ShapeTriggerEnter", self, self.TriggerEnter)
	Events:Subscribe("ShapeTriggerExit", self, self.TriggerExit)
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("GameRender", self, self.GameRender)
	Events:Subscribe("InputPoll", self, self.InputPoll)
end

function PassiveZones:TriggerEnter(args)
	if args.entity.__type == "LocalPlayer" then
		if args.trigger == self.Triggers[args.trigger:GetId()] then
			self.DisableFiring = true
			Timer.SetTimeout(500, function() self.DisableFiring = false end)-- Give InputPoll enough time to disable firing.

			Timer.SetTimeout(250, function() --Fix for double spawning bug.
				if LocalPlayer:GetValue("Passive") then
					self.WasInPassive = true
				else
					Network:Send("PassiveZone", true)
				end

				LocalPlayer:SetValue("ForcePassive", true)

				Chat:Print("You have entered a Passive Zone, Passive Mode has been forced on", Color.Red)
			end)

		end
	end
end

function PassiveZones:TriggerExit(args)
	if args.entity.__type == "LocalPlayer" then
		if args.trigger == self.Triggers[args.trigger:GetId()] then

			if self.WasInPassive then
				self.WasInPassive = false
				Chat:Print("You have exited a Passive Zone, Passive Mode has been unforced", Color.LawnGreen)
			else	
				Network:Send("PassiveZone", false)
				Chat:Print("You have exited a Passive Zone, Passive Mode has been disabled", Color.LawnGreen)
			end
			
			LocalPlayer:SetValue("ForcePassive", false)
			
		end
	end
end

function PassiveZones:ModuleLoad()
	local PassiveZonesNames = ""
	for k, data in ipairs(self.Zones) do

		local Dangle  = Angle( table.unpack(data[2]) )
		local Dpos    = Vector3( table.unpack(data[3]) )
		local Dsize   = Vector3(data[4],0,0)
		local Dradius = data[4]

		local trigger = ShapeTrigger.Create({
			angle = Dangle,
			position = Dpos,
			components = { { size = Dsize, type = 1 } },
			trigger_player = true,
			trigger_player_in_vehicle = true
		})

		self.Triggers[ trigger:GetId() ] = trigger
		self.TriggersData[ trigger:GetId() ] = {pos = Dpos, radius = Dradius }
		PassiveZonesNames = PassiveZonesNames .."".. data[1] .."\n"

	end

	self.Zones = nil

	Events:Fire("HelpAddItem", {
		name = "Passive Zones",
		text = 
			"Current Passive Zones:\n \n" ..
			PassiveZonesNames ..
			"\nPassive Zones by Dbeast247"
		}
	)
end

function PassiveZones:ModuleUnload()
	if IsValid(LocalPlayer) then
		LocalPlayer:SetValue("ForcePassive", false)
	end
	for id, trigger in pairs(self.Triggers) do
		if IsValid(trigger) then
			trigger:Remove()
		end
	end
	Events:Fire("HelpRemoveItem", {name = "Passive Zones"})
end

function PassiveZones:InputPoll()
	if self.DisableFiring then
		if Input:GetValue(Action.FireRight) ~= 0 or Input:GetValue(Action.FireLeft) ~= 0 then
			Input:SetValue(Action.VehicleFireRight, 0)
			Input:SetValue(Action.VehicleFireLeft, 0)
			Input:SetValue(Action.McFire, 0)
			Input:SetValue(Action.FireRight, 0)
			Input:SetValue(Action.FireLeft, 0)	
		end
	end
end

function Sphere()
	local vertices = {}
	local pitchInc = (180 / SphereLines1) * (0.01745329)
	local rotInc   = (360 / SphereLines2) * (0.01745329)
	local p, s, x, y, z, out

	for p = 0, SphereLines1 do
		out = math.sin(p * pitchInc)
		y = math.cos(p * pitchInc)

		for s = 0, SphereLines2 do
			x = out * math.sin(s * rotInc)
			z = out * math.cos(s * rotInc)

			table.insert(vertices, Vertex( Vector3(x, y, z) ) )
		end
	end

	return vertices
end

	local Model = Model.Create( Sphere() )
	Model:SetTopology(Topology.LineStrip)

function PassiveZones:GameRender()
	if not self.ShowZones then return end

	for id, data in pairs(self.TriggersData) do
		if Vector3.Distance( data.pos, LocalPlayer:GetPosition() ) <= data.radius + self.VisDist then

			Render:DrawLine( data.pos, data.pos + Vector3(0,data.radius,0), self.ZoneColor )
			local transform = Transform3():Translate(data.pos)
			Render:SetTransform( transform:Scale(data.radius) )
			Model:Draw()
			Model:SetColor(self.ZoneColor)
			Render:ResetTransform()

		end
	end
	collectgarbage()
end

PassiveZones = PassiveZones()
