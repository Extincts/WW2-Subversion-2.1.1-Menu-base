modelSpawner( origin, model, angles, time, scale )
{
    if(isDefined(time))
        wait time;
     
    obj = spawn( model, origin, angles );    
    if(isDefined( scale ))
        obj SetScale( scale );
    return obj;
}

returnBoolean( var )
{
    if(isDefined(var))
        return true;
    return false;
}