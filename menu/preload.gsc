loadarrays()
{
    
}

load_presets()
{
    self.presets = [];
    
    self.presets["X"] = 145;
    self.presets["Y"] = -114;
    
    self.presets["OUTLINE"] = get_preset("OUTLINE");
    self.presets["TITLE_OPT_BG"] = get_preset("TITLE_OPT_BG");
    self.presets["SCROLL_STITLE_BG"] = get_preset("SCROLL_STITLE_BG");
    self.presets["TEXT"] = get_preset("TEXT");
}

get_preset( preset )
{
    if( preset == "OUTLINE" )
        return (0,0,0);
    if( preset == "TITLE_OPT_BG" )
        return rgb(19,18,20);
    if( preset == "SCROLL_STITLE_BG" )
        return "rainbow"; //rgb(62,58,63); //
    if( preset == "TEXT" )
        return (1,1,1);
    if( preset == "X" )
        return 0;
    if( preset == "Y" )
        return 0;    
}
