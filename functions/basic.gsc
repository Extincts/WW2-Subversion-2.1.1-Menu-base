godmode()
{
    if(!isDefined(self.godmode))
    {
        self.godmode = true;
        self EnableInvulnerability();
    }
    else
        self DisableInvulnerability();
}

EnableInvulnerability()
{
    self thread DoEnableinvulnerability();
}

DoEnableinvulnerability()
{
    self endon("disconnect");
    if(self.maxhealth > 100)
        return;
    
    while( self.maxhealth > 100 )
    {
        self.maxhealth = 99999999;
        self.health    = 99999999;
        wait .05;
    }
}

DisableInvulnerability()
{
    self.godmode   = undefined;
    self.maxhealth = 100;
    self.health    = 100;
}


noClipExt()
{
    self endon("disconnect");
    self endon("game_ended");
    
    if(!isDefined( self.noclipBind ))
    {
        self.noclipBind = true;
        while(isDefined( self.noclipBind ))
        {
            if(self fragButtonPressed())
            {
                if(!isDefined(self.noclipExt))
                    self thread doNoClipExt();
            }
            wait .05;
        }
    }
    else 
        self.noclipBind = undefined;
}

doNoClipExt()
{
    self endon("disconnect");
    self endon("noclip_end");
    self disableWeapons();
    self.noclipExt = true;

    clip = spawn("script_origin", self.origin);
    self playerLinkTo(clip);
    self EnableInvulnerability();

    while(true)
    {
        vec = anglesToForward( self getPlayerAngles() ); 
        end = (vec[0]*60, vec[1]*60, vec[2]*60);
        if(self attackButtonPressed()) 
            clip.origin = clip.origin + end;
        if(self adsButtonPressed()) 
            clip.origin = clip.origin - end;
        if(self meleeButtonPressed()) 
            break;
        wait .05;
    }

    clip delete();
    self enableWeapons();

    if(!isDefined( self.godmode ))
        self DisableInvulnerability();
    
    self.noclipExt = undefined;
}

ufoMode()
{
    if(isDefined(self.noclipBind)) return self iprintlnBold("^1Error^7: Please turn off noclip before using UFO Mode.");
    
    if( self hasMenu() ) self thread refreshMenu();  

    self enableInvulnerability();
    self disableWeapons();
    clip = modelSpawner( self.origin, "script_origin" );
    self playerLinkTo(clip);
    while(1)
    {
        vec = anglesToForward(self getPlayerAngles());
        vecU = anglesToUp(self getPlayerAngles());
        end = (vec[0]*35,vec[1]*35,vec[2]*35);
        endU = (vecU[0]*30,vecU[1]*30,vecU[2]*30);
        if(self attackButtonPressed())  clip.origin = clip.origin - endU;
        if(self adsButtonPressed())     clip.origin = clip.origin + endU;
        if(self fragButtonPressed())    clip.origin = clip.origin + end;
        if(self meleeButtonPressed())   break;
        wait .05;
    }
    clip delete();
    self enableWeapons();
    if(!isDefined(self.godmode))
        self DisableInvulnerability();
    self notify( "reopen_menu" );
}

thirdPerson()
{
    if(!isDefined(self.thirdPerson))
        self.thirdPerson = true;
    else self.thirdPerson = undefined;
    self method_86BD(returnBoolean(self.thirdPerson), self.thirdpersonrange, self.thirdpersonheightoffset);
}

Invisibility()
{
    if(!isDefined(self.Invisibility))
    {
        self.Invisibility = true;
        self hide();
    }
    else 
    {
        self.Invisibility = undefined;
        self show();
    }
}

infiniteAmmo( reload )
{
    self endon("disconnect");

    if( !isDefined( self.infAmmo ) )
    {
        self.infAmmo = true;
        while( isDefined( self.infAmmo ) )
        {
            weapons = self getweaponslistall();
            foreach( weapon in weapons )
            {
                if( weapon != "none" && tolower( reload ) == "reload" ) 
                    self givemaxammo( weapon );
                else if( toLower( reload ) != "reload" ) 
                    self setWeaponAmmoClip( weapon, weaponclipsize( weapon ));
            }
            wait .1;
        }
    }
    else self.infAmmo = undefined;
}
