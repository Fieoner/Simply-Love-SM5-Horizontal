return Def.ActorFrame{
	InitCommand=function(self) self:x(26) end,

	Def.Quad{ InitCommand=function(self) self:diffuse(color("#000000")):zoomto(THEME:GetMetric("MusicWheel", "WheelWidth"), _screen.h/15) end },
	Def.Quad{ InitCommand=function(self) self:diffuse(color("#283239")):zoomto(THEME:GetMetric("MusicWheel", "WheelWidth"), _screen.h/15 - 1) end }
}