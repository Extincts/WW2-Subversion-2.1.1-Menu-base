#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    if(getDvarInt("4017", 0))
        return;
        
    level loadarrays();
    level thread createRainbowColor();
    
    level.strings  = [];
    level.status   = strTok("None;VIP;Admin;Co-Host;Host", ";");
    level.menuName = "Sub Version 2.1.1";

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{    
    if(self isHost())
    {
        self thread overflowfix();
        self thread initializeSetup( 4, self );
    }
}

overflowfix()
{
    level.overflow       = newHudElem();
    level.overflow.alpha = 0;
    level.overflow setText( "marker" );

    for(;;)
    {
        level waittill("CHECK_OVERFLOW");
        if(level.strings.size >= 45)
        {
            level.overflow ClearAllTextAfterHudElem();
            level.strings = [];
            level notify("FIX_OVERFLOW");
        }
    }
}

