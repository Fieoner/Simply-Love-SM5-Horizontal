local textcolor = "#FFFFFF";
if SL.Global.ActiveColorIndex > 5 then
	textcolor = "#1E282F";
end

return LoadFont("Common Normal") .. {
	InitCommand=cmd(zoom, 0.65; diffuse,color(textcolor););
};