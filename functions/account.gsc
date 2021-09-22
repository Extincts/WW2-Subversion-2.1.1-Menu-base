completeAllChallenges( percentage = 1.0 )
{
    if( !self areYouSure() )
        return;
    wait .2;
    
    self lockMenu("lock", "open");
    
    //progressbar( min, max, mult, time )
    self thread progressbar( 0, 100, 1, 0.750);
     
    foreach ( challengeRef, challengeData in level.challengeInfo )
    {
        finalTarget = 0;
        finalTier   = 0;
        for ( tierId = 1; isDefined( challengeData["targetval"][tierId] ); tierId++ )
        {
            finalTarget = challengeData["targetval"][tierId];
            finalTier = tierId + 1;
        }

        if ( self IsItemUnlocked( challengeRef ) || percentage == 1.0 )
        {        
            self iprintlnBold(challengeRef);
            self setRankedPlayerData( common_scripts\utility::func_46AE(), "challengeProgress", challengeRef, finalTarget + 1 );
            self setRankedPlayerData( common_scripts\utility::func_46AE(), "challengeState", challengeRef, finalTier + 1 );
        }
        
        wait ( 0.05 );
    }
    
    self.unlockall_finished = true;

    self waittill("progress_done");
    self lockMenu("unlock", "open");
}