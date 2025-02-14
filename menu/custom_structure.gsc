menuOptions()
{
    player = self.selected_player;        
    menu = self getCurrentMenu();
    
    player_names = [];
    foreach( players in level.players )
        player_names[player_names.size] = players.name;

    switch( menu )
    {
        case "main":
        {
            self addMenu( "main", "Default Submenus" );
                self addOpt( "Basic Options", ::newMenu, "basicOpts" );
                self addOpt( "Account Options", ::newMenu, "accOpts" );
                self addOpt( "Menu Customization", ::newMenu, "customization" );     
                self addOpt( "Clients Menu", ::newMenu, "clients" );
        }
        /* BASIC OPTIONS */
        case "basicOpts":
        {
            self addMenu( "basicOpts", "Basic Options" );  
                self addToggle( "Godmode", isDefined( player.godmode ), ::godmode );
                self addToggle( "Noclip Bind [{+frag}]", isDefined( player.noclipBind ), ::noClipExt );
                self addToggle( "UFO Mode", false, ::ufoMode );
                self addToggle( "Third Person", isDefined( player.thirdPerson ), ::thirdPerson );
                self addToggle( "Invisibility", isDefined( player.Invisibility ), ::Invisibility );
                self addSliderString( "Infinite Ammo", "Continuous;Reload", undefined, ::infiniteAmmo );
        }

        case "accOpts":  
        {
            self addMenu( "accOpts", "Account Unlocks" );
                self addToggle( "Unlock All", isDefined(player.unlockall_finished), ::completeAllChallenges );
        }
        case "menuColours":
        {
            sections = strTok( "Outline;Title & Options BG;Scroll & Subtitle BG;Text",";" );
            huds     = strTok( "OUTLINE;TITLE_OPT_BG;SCROLL_STITLE_BG;TEXT", ";" );
            
            self addMenu( "menuColours", "Menu Colours" );
            
            for(e=0;e<sections.size;e++)
                self addOpt(sections[e], ::newMenu, sections[e]);
        
            for(e=0;e<sections.size;e++)
            {
                if(menu != sections[e])
                    continue;

                self addMenu(menu, sections[e]);
                self addSliderValue( "Red Slider", player.presets[ huds[e] ][0] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "R" );
                self addSliderValue( "Green Slider", player.presets[ huds[e] ][1] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "G" );
                self addSliderValue( "Blue Slider", player.presets[ huds[e] ][2] * 255, 0, 255, 1, ::RGB_Edit, huds[e], "B" );
                self addToggle("Smooth Rainbow", (player.presets[ huds[e] ] == "rainbow"), ::RGB_Edit, "rainbow", huds[e], "/" );
            }    
        } 
    }
    self clientOptions(); 
}

clientOptions()
{
    self addmenu( "clients", "Clients Menu" );
    foreach( player in level.players )
        self addopt(player getname(), ::newmenu, "client_" + player getentitynumber());
            
    foreach(player in level.players)
    {
        self addmenu("client_" + player getentitynumber(), player getName());
        for(e=0;e<level.status.size-1;e++)
            self addOpt("Give " + level.status[e], ::initializeSetup, e, player);
    }
}

menuMonitor()
{
    self endon("disconnect");
    self endon("end_menu");

    savedWeapon = "none";
    while( self.access != 0 )
    {
        if(!self.menu["isLocked"])
        {
            if(!self.menu["isOpen"])
            {
                if( self meleeButtonPressed() && self adsButtonPressed() )
                {
                    self menuOpen();
                    wait .2;
                }               
            }
            else 
            {
                if( self attackButtonPressed() || self adsButtonPressed() )
                {
                    self.menu[ self getCurrentMenu() + "_cursor" ] += self attackButtonPressed();
                    self.menu[ self getCurrentMenu() + "_cursor" ] -= self adsButtonPressed();
                    self scrollingSystem();
                    wait .2;
                }
                /*else if( self actionslotthreebuttonpressed() || self actionslotfourbuttonpressed() )
                {
                    if(isDefined(self.eMenu[ self getCursor() ].val) || IsDefined( self.eMenu[ self getCursor() ].ID_list ))
                    {
                        if( self actionslotthreebuttonpressed() )   self updateSlider( "L2" );
                        if( self actionslotfourbuttonpressed() )    self updateSlider( "R2" );
                        wait .1;
                    }
                }*/
                /*else if( self actionslottwobuttonpressed() && self.eMenu[ self getCursor() ].func != ::newMenu && self IsHost() && self.selected_player == self && level.players.size > 1 )
                {
                    self thread selectPlayer();
                    wait .2;
                }*/
                else if( self useButtonPressed() )
                {
                    player = self.selected_player;
                    menu = self.eMenu[self getCursor()];

                    if( player != self && self isHost() )
                    {
                        player.was_edited = true;
                        self iPrintLnBold( menu.opt + " Has Been Activated." );
                    }
                    
                    if( self.eMenu[ self getCursor() ].func == ::newMenu && self != player )
                        self iPrintLnBold( "Error: Cannot Access Menus While In A Selected Player." );
                    else if(isDefined(self.sliders[ self getCurrentMenu() + "_" + self getCursor() ]))
                    {
                        slider = self.sliders[ self getCurrentMenu() + "_" + self getCursor() ];
                        slider = (IsDefined( menu.ID_list ) ? menu.ID_list[slider] : slider);
                        player thread doOption( menu.func, slider, menu.p1, menu.p2, menu.p3, menu.p4, menu.p5 );
                    }
                    else 
                        player thread doOption( menu.func, menu.p1, menu.p2, menu.p3, menu.p4, menu.p5 );

                    wait .05;
                    if(IsDefined( menu.toggle ))
                        self setMenuText();
                    if( player != self )
                        self.menu["OPT"]["MENU_TITLE"] setText( self.menuTitle + " ("+ player getName() +")");    
                    wait .15;
                    if( isDefined(player.was_edited) && self isHost() )
                        player.was_edited = undefined;
                }
                else if( self meleeButtonPressed() )
                {
                    if( self.selected_player != self )
                    {
                        self.selected_player = self;
                        self setMenuText();
                        self refreshTitle();
                    }
                    else if( self getCurrentMenu() == "main" )
                        self menuClose();
                    else 
                        self newMenu();
                    wait .2;
                }
            }
        }
        wait .05;
    }
}

menuOpen()
{
    self.menu["isOpen"] = true;
    self menuOptions();
    self drawMenu();
    self drawText();
    self setMenuText(); 
    self updateScrollbar();
}

menuClose()
{
    self destroyAll(self.menu["UI"]); 
    self destroyAll(self.menu["OPT"]);
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);
    self.menu["isOpen"] = false;
}

drawMenu()
{
    if(!isDefined(self.menu["UI"]))
        self.menu["UI"] = [];
    if(!isDefined(self.menu["UI_TOG"]))
        self.menu["UI_TOG"] = [];    
    if(!isDefined(self.menu["UI_SLIDE"]))
        self.menu["UI_SLIDE"] = [];
    if(!isDefined(self.menu["UI_STRING"]))
        self.menu["UI_STRING"] = [];    
        
    self.menu["UI"]["TITLE_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 260, 23, self.presets["TITLE_OPT_BG"], "white", 1, 1);
    self.menu["UI"]["SUBT_BG"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 83, 260, 23, self.presets["SCROLL_STITLE_BG"], "white", 1, 1);
    
    self.menu["UI"]["OPT_BG"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"], self.presets["Y"] - 70, 260, 182, self.presets["TITLE_OPT_BG"], "white", 1, 1);    
    self.menu["UI"]["OUTLINE"] = self createRectangle("TOPLEFT", "CENTER", self.presets["X"] - 1.6, self.presets["Y"] - 121.5, 263, 234, self.presets["OUTLINE"], "white", 0, 1);
    self.menu["UI"]["SCROLLER"] = self createRectangle("LEFT", "CENTER", self.presets["X"], self.presets["Y"] - 108, 250, 20, self.presets["SCROLL_STITLE_BG"], "white", 2, 1);
    
    self.menu["UI"]["SIDE_SCR_BG"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 260, self.presets["Y"] - 70, 9, 182, self.presets["SCROLL_STITLE_BG"], "white", 2, 1);
    
    self.menu["UI"]["SIDE_SCR"] = self createRectangle("TOPRIGHT", "CENTER", self.presets["X"] + 257, self.presets["Y"] - 62, 4, 40, self.presets["TITLE_OPT_BG"], "white", 3, 1);
    self resizeMenu();
}

drawText()
{
    if(!isDefined(self.menu["OPT"]))
        self.menu["OPT"] = [];
    
    self.menu["OPT"]["MENU_NAME"] = self createText("hudsmall", .8, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 108, 3, 1, level.menuName, self.presets["TEXT"]);  
    self.menu["OPT"]["MENU_TITLE"] = self createText("objective", .9, "CENTER", "CENTER", self.presets["X"] + 130, self.presets["Y"] - 83, 3, 1, self.menuTitle, self.presets["TEXT"]);

    for(e=0;e<10;e++)
        self.menu["OPT"][e] = self createText("objective", .7, "LEFT", "CENTER", self.presets["X"] + 5, self.presets["Y"] - 60 + (e*18), 3, 1, "", self.presets["TEXT"]);
}

refreshTitle()
{
    self.menu["OPT"]["MENU_TITLE"] setText(self.menuTitle);
}
    
scrollingSystem()
{
    if(self getCursor() >= self.eMenu.size || self getCursor() < 0 || self getCursor() == 9)
    {
        if(self getCursor() <= 0)
            self.menu[ self getCurrentMenu() + "_cursor" ] = self.eMenu.size -1;
        else if(self getCursor() >= self.eMenu.size)
            self.menu[ self getCurrentMenu() + "_cursor" ] = 0;
    }
    
    self setMenuText();
    self updateScrollbar();
}

updateScrollbar()
{
    curs = (self getCursor() >= 10) ? 9 : self getCursor();  
    self.menu["UI"]["SCROLLER"].y = (self.menu["OPT"][curs].y);
    
    size       = (self.eMenu.size >= 10) ? 10 : self.eMenu.size;
    height     = int(18*size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    position_Y = (self.eMenu.size-1) / ((height - 15) - math);
    
    if( self.eMenu.size > 10 )
        self.menu["UI"]["SIDE_SCR"].y = self.presets["Y"] - 62 + (self getCursor() / position_Y); 
    else self.menu["UI"]["SIDE_SCR"].y = self.presets["Y"] - 62;  
} 

setMenuText()
{
    self endon("disconnect");
    self menuOptions(); // updates toggles etc.
    self resizeMenu();

    ary = (self getCursor() >= 10) ? (self getCursor() - 9) : 0;  
    self destroyAll(self.menu["UI_TOG"]);
    self destroyAll(self.menu["UI_SLIDE"]);
    
    for(e=0;e<10;e++)
    {
        self.menu["OPT"][e].x = self.presets["X"] + 5; 
        
        if(isDefined(self.eMenu[ ary + e ].opt))
        {
            self.menu["OPT"][e] setText( self.eMenu[ ary + e ].opt );
        }
        else 
            self.menu["OPT"][e] setText("");
            
        if(IsDefined( self.eMenu[ ary + e ].toggle ))
        {
            self.menu["OPT"][e].x += 20; 
            self.menu["UI_TOG"][e] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x - 20, self.menu["OPT"][e].y, 14, 14, (0,0,0), "white", 4, 1); //BG
            self.menu["UI_TOG"][e + 10] = self createRectangle("CENTER", "CENTER", self.menu["UI_TOG"][e].x + 7, self.menu["UI_TOG"][e].y, 12, 12, (self.eMenu[ ary + e ].toggle) ? self.presets["SCROLL_STITLE_BG"] : self.presets["TITLE_OPT_BG"], "white", 5, 1); //INNER
        }
        if(IsDefined( self.eMenu[ ary + e ].val ))
        {
            self.menu["UI_SLIDE"][e] = self createRectangle("RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 108, 14, (0,0,0), "white", 4, 1); //BG
            self.menu["UI_SLIDE"][e + 10] = self createRectangle("LEFT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["UI_SLIDE"][e].y, 12, 12, self.presets["SCROLL_STITLE_BG"], "white", 5, 1); //INNER
            if( self getCursor() == ( ary + e ) )
                self.menu["UI_SLIDE"]["VAL"] = self createText("objective", .7, "RIGHT", "CENTER", self.menu["OPT"][e].x + 126, self.menu["OPT"][e].y, 5, 1, self.sliders[ self getCurrentMenu() + "_" + self getCursor() ] + "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
        if( IsDefined( self.eMenu[ (ary + e) ].ID_list ) )
        {
            if(!isDefined( self.sliders[ self getCurrentMenu() + "_" + (ary + e)] ))
                self.sliders[ self getCurrentMenu() + "_" + (ary + e) ] = 0;
                
            self.menu["UI_SLIDE"]["STRING_"+e] = self createText("objective", .7, "RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 6, 1, "", self.presets["TEXT"]);
            self updateSlider( "", e, ary + e );
        }
        if( self.eMenu[ ary + e ].func == ::newMenu && IsDefined( self.eMenu[ ary + e ].func ) )
            self.menu["UI_SLIDE"]["SUBMENU"+e] = self createText("default", .7, "RIGHT", "CENTER", self.menu["OPT"][e].x + 240, self.menu["OPT"][e].y, 6, 1, ">", self.presets["TEXT"]);
    }
}
    
resizeMenu()
{
    size   = (self.eMenu.size >= 10) ? 10 : self.eMenu.size;
    height = int(18*size);
    math   = (self.eMenu.size > 10) ? ((180 / self.eMenu.size) * size) : (height - 15);
    
    self.menu["UI"]["SIDE_SCR"] SetShader( "white", 4, int(math));
    self.menu["UI"]["SIDE_SCR_BG"] SetShader( "white", 9, height + 2);
    self.menu["UI"]["OPT_BG"] SetShader( "white", 260, height + 2 );
    self.menu["UI"]["OUTLINE"] SetShader( "white", 263, height + 54 );
}