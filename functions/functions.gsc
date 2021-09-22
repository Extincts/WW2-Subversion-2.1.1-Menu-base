/*
*    Infinity Loader :: The Best GSC IDE!
*
*    Project : Subversion
*    Author : 
*    Game : Call of Duty: WWII
*    Description : An empty canvas for anything you want!
*    Date : 9/14/2021 8:47:25 PM
*
*/

TestOption()
{
    self iprintlnBold("^1Test ^3Option ^2Working^7!");
}

give_Weapon(weapon)
{
    self TakeWeapon(self GetCurrentWeapon());
    self TakeWeapon(self GetCurrentWeapon());
    self GiveWeapon(weapon);
    self SwitchToWeaponImmediate(weapon);
    self GiveMaxAmmo(weapon);
}