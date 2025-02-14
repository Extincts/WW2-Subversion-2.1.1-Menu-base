createText(font, fontScale, align, relative, x, y, sort, alpha, text, color, isLevel)
{
    if(isDefined(isLevel))
        textElem = level createServerFontString(font, fontScale);
    else 
        textElem = self createFontString(font, fontScale);

    textElem setPoint(align, relative, x, y);
    textElem.hideWhenInMenu = true;
    textElem.archived = false;
    if( self.hud_amount >= 19 ) 
        textElem.archived = true;

    textElem.sort           = sort;
    textElem.alpha          = alpha;
    if(color != "rainbow")
        textElem.color = color;
    else
    {
        textElem.color = level.rainbowColour;
        textElem thread doRainbow();
    }

    self addToStringArray(text);
    textElem thread watchForOverFlow(text);
    textElem thread watchDeletion( self ); 

    self.hud_amount++;  
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, server)
{
    boxElem                = (isDefined(server) ? createServerIcon(shader, width, height) : createIcon(shader, width, height));
    boxElem.hideWhenInMenu = true;
    boxElem.sort           = sort;
    boxElem.foreground     = true;
    boxElem.alpha          = alpha;

    if(color != "rainbow")
        boxElem.color = color;
    else
    {
        boxElem.color = level.rainbowColour;
        boxElem thread doRainbow();
    } 

    boxElem setPoint(align, relative, x, y);

    boxElem thread watchDeletion( self );
    self.hud_amount++;
    return boxElem;
}

isInArray( array, text )
{
    for(e=0;e<array.size;e++)
        if( array[e] == text )
            return true;
    return false;        
}

removeFromArray( array, text )
{
    new = [];
    foreach( index in array )
    {
        if( index != text )
            new[new.size] = index;
    }      
    return new; 
}

setSafeText(text)
{
    self notify("stop_TextMonitor");
    self addToStringArray(text);
    self thread watchForOverFlow(text);
}

addToStringArray(text)
{
    if(!isInArray(level.strings,text))
    {
        level.strings[level.strings.size] = text;
        level notify("CHECK_OVERFLOW");
    }
}

watchForOverFlow(text)
{
    self endon("stop_TextMonitor");

    while(isDefined(self))
    {
        if(isDefined(text.size))
            self setText(text);
        else
        {
            self setText(undefined);
            self.label = text;
        }
        level waittill("FIX_OVERFLOW");
    }
}

getName()
{
    name = self.name;
    if(name[0] != "[")
        return name;
    for(a = name.size - 1; a >= 0; a--)
        if(name[a] == "]")
            break;
    return(getSubStr(name, a + 1));
}

destroyAll(array)
{
    if(!isDefined(array))
        return;
    keys = getArrayKeys(array);
    for(a=0;a<keys.size;a++)
        if(isDefined(array[ keys[ a ] ][ 0 ]))
            for(e=0;e<array[ keys[ a ] ].size;e++)
                array[ keys[ a ] ][ e ] destroy();
    else
        array[ keys[ a ] ] destroy();
}

hudFade(alpha, time)
{
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
}

hudMoveX(x, time)
{
    self moveOverTime(time);
    self.x = x;
    wait time;
}

hudMoveY(y, time)
{
    self moveOverTime(time);
    self.y = y;
    wait time;
}

rgb(r, g, b)
{
    return (r/255, g/255, b/255);
}

watchDeletion( player )
{
    player endon("disconnect");
    self waittill("death");
    if( player.hud_amount > 0 )
        player.hud_amount--;
}

createRainbowColor()
{
    x = 0; y = 0;
    r = 0; g = 0; b = 0;
    level.rainbowColour = (0, 0, 0);
    
    while(true)
    {
        if (y >= 0 && y < 255) {
            r = 255;
            g = 0;
            b = x;
        }
        else if (y >= 255 && y < 510) {
            r = 255 - x;
            g = 0;
            b = 255;
        }
        else if (y >= 510 && y < 765) {
            r = 0;
            g = x;
            b = 255;
        }
        else if (y >= 765 && y < 1020) {
            r = 0;
            g = 255;
            b = 255 - x;
        }
        else if (y >= 1020 && y < 1275) {
            r = x;
            g = 255;
            b = 0;
        }
        else if (y >= 1275 && y < 1530) {
            r = 255;
            g = 255 - x;
            b = 0;
        }

        x += 0.5; //increase this value to switch colors faster
        if (x >= 255)
            x = 0;

        y += 0.5; //increase this value to switch colors faster
        if (y > 1530)
            y = 0;

        level.rainbowColour = rgb(r, g, b);
        wait .05;
    }
}

hudMoveXY(time,x,y)
{
    self moveOverTime(time);
    self.y = y;
    self.x = x;
}

refreshMenuToggles()
{
    foreach( player in level.players )
        if( player hasMenu() && player isMenuOpen() )
            player setMenuText();
}

refreshMenu( skip )
{
    if( !self hasMenu() )
        return false;
        
    if(self isMenuOpen())
    { 
        current  = self getCurrentMenu();
        previous = self.previousMenu;
        for(e = previous.size; e > 0; e--)
        {
            self newMenu();
            wait .05;
            waittillframeend;
        }
        self menuClose(); 
        self.menu["isLocked"] = true;
    }
    
    if(!IsDefined( skip ))
    {
        self waittill( "reopen_menu" );
        wait .1;
    }
    else wait .05;
    
    self menuOpen();
    if(IsDefined( previous ))
    {
        foreach( menu in previous )
        {
            if( menu != "main" )
                self newMenu( menu );
        }
        self newMenu( current );
        self.menu["isLocked"] = false;
    }
}

hasMenu()
{
    if( IsDefined( self.access ) && self.access != "None" )
        return true;
    return false;    
}

lockMenu( which, type )
{
    if(toLower(which) == "lock")
    {
        if(self isMenuOpen() && toLower(type) != "open")
        {
            current  = self getCurrentMenu();
            previous = self.previousMenu;
            for(e = previous.size; e > 0; e--)
                self newMenu();
            self menuClose(); 
        }
        self.menu["isLocked"] = true;
    }
    else 
    {
        if(!self isMenuOpen() && toLower(type) == "open")
            self menuOpen();
        else     
            self setMenuText();    
        self.menu["isLocked"] = false;
        self notify("menu_unlocked");
    }
}

hudFadeDestroy(alpha, time)
{
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
    self destroy();
}

doRainbow()
{
    while(IsDefined( self ))
    {
        self fadeOverTime(.05); 
        self.color = level.rainbowColour;
        wait .05;
    }
}

doOption(function, p1, p2, p3, p4, p5, p6)
{
    if(!isdefined(function))
        return;
    
    if(isdefined(p6))
        self thread [[function]](p1,p2,p3,p4,p5,p6);
    else if(isdefined(p5))
        self thread [[function]](p1,p2,p3,p4,p5);
    else if(isdefined(p4))
        self thread [[function]](p1,p2,p3,p4);
    else if(isdefined(p3))
        self thread [[function]](p1,p2,p3);
    else if(isdefined(p2))
        self thread [[function]](p1,p2);
    else if(isdefined(p1))
        self thread [[function]](p1);
    else
        self thread [[function]]();
}
    
sponge_text( string )
{
    sponge = "";
    for(e=0;e<string.size;e++)
        sponge += ( (e % 2) ? toUpper( string[e] ) : toLower( string[e] ) );
    return sponge;
}

toUpper( string )
{
    if( !isDefined( string ) || string.size <= 0 )
        return "";
    alphabet = strTok("A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z;0;1;2;3;4;5;6;7;8;9; ;-;_", ";");
    final    = "";
    for(e=0;e<string.size;e++)
        for(a=0;a<alphabet.size;a++)
            if(IsSubStr(toLower(string[e]), toLower(alphabet[a])))         
                final += alphabet[a];
    return final;            
}