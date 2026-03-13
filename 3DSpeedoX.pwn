/*

		3D SpeedoMeter v1.2 by Straydet

	    Idea Original - (Ace Abhishek)

	    Desarrollador (Straydet) - Desarrollo de Mejoras, Comandos, Stocks y demás.
	    
	    
	    Nota: Este velocimetro contiene una configuración para cambiar el color del velocimetro.
	    Puede modificar o ajustar cualquier parte del sistema si lo necesita, añadir más colores o ampliar las funciones.
	    En caso de encontrar un bug/error puede notificarlo asi también como sugerencias para el sistema.
	    Si quiere modificar/editar debe al menos conocer el lenguaje 'Pawn', ya que puede causar errores/bugs por no saber lo que hace.

*/

#include <a_samp>
#include <zcmd>

#define COLOR_LIGHTGREEN 0x24FF0AB9
#define SPEEDUPDATE 250 // < 100 puede causar lag > 500 se ve lento

// Colores
#define COLOR_RED       0xFF0000FF
#define COLOR_GREEN     0x00FF00FF
#define COLOR_CYAN      0x00FFFFFF
#define COLOR_PINK      0xFF69B4FF
#define COLOR_PURPLE    0x800080FF

new PlayerSpeed[MAX_PLAYERS];
new PlayerSpeedObject[MAX_PLAYERS];
new PlayerSpeedColor[MAX_PLAYERS];

public OnFilterScriptInit()
{
    print("\n----------------------------------");
    print(" 3D Speedometer + Color Menu");
    print("        Version 1.2		");
    print("----------------------------------\n");

    SetTimer("UpdateAllSpeedos", SPEEDUPDATE, true);
}

public OnPlayerConnect(playerid)
{
    PlayerSpeed[playerid] = 1;
    PlayerSpeedObject[playerid] = -1;
    PlayerSpeedColor[playerid] = COLOR_GREEN; // Color por defecto
    return 1;
}

stock GetPlayerSpeedInt(playerid)
{
    new Float:svx, Float:svy, Float:svz;
    GetVehicleVelocity(GetPlayerVehicleID(playerid), svx, svy, svz);
    new Float:s1 = floatsqroot(((svx*svx) + (svy*svy) + (svz*svz))) * 100;
    return floatround(s1, floatround_round);
}

forward UpdateAllSpeedos();
public UpdateAllSpeedos()
{
    for(new i=0; i<MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerSpeed[i] == 1 && IsPlayerInAnyVehicle(i))
        {
            UpdateSpeedo(i);
        }
    }
    return 1;
}

forward UpdateSpeedo(playerid);
public UpdateSpeedo(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 0;
    new msg[32];
    new spd = GetPlayerSpeedInt(playerid);

    format(msg, sizeof(msg), "{%06x}%i{FFFFFF} km/h", PlayerSpeedColor[playerid] >>> 8, spd);

    SetPlayerObjectMaterialText(playerid, PlayerSpeedObject[playerid], msg, 0, 90, "Arial", 44, 1, -16711936, 0, 2);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(PlayerSpeed[playerid] == 0) return 1;

    if(newstate == PLAYER_STATE_DRIVER)
    {
        PlayerSpeedObject[playerid] = CreatePlayerObject(playerid, 19477, 0.0, 0.0, -1000.0, 0.0, 0.0, 300.0, 100.0);
        SetPlayerObjectMaterial(playerid, PlayerSpeedObject[playerid], 0, 8487, "ballyswater", "waterclear256", 0x00000000);

        new vehid = GetPlayerVehicleID(playerid);
        AttachSpeedBoard(playerid, vehid);

        UpdateSpeedo(playerid);
    }
    else if(newstate != PLAYER_STATE_DRIVER)
    {
        if(PlayerSpeedObject[playerid] != -1)
        {
            DestroyPlayerObject(playerid, PlayerSpeedObject[playerid]);
            PlayerSpeedObject[playerid] = -1;
        }
    }
    return 1;
}


CMD:speedo(playerid, params[])
{
    if(PlayerSpeed[playerid] == 1)
    {
        SendClientMessage(playerid, COLOR_LIGHTGREEN, "* [Server]: Speedometer {FFFFFF}(OFF)");
        PlayerSpeed[playerid] = 0;
        if(PlayerSpeedObject[playerid] != -1) DestroyPlayerObject(playerid, PlayerSpeedObject[playerid]);
    }
    else
    {
        SendClientMessage(playerid, COLOR_LIGHTGREEN, "* [Server]: Speedometer {FFFFFF}(ON)");
        PlayerSpeed[playerid] = 1;
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new vehid = GetPlayerVehicleID(playerid);
            PlayerSpeedObject[playerid] = CreatePlayerObject(playerid, 19477, 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0, 100.0);
            SetPlayerObjectMaterial(playerid, PlayerSpeedObject[playerid], 0, 8487, "ballyswater", "waterclear256", 0x00000000);
            AttachSpeedBoard(playerid, vehid);
        }
    }
    return 1;
}


CMD:speedcolor(playerid, params[])
{
    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST,
        "Selecciona color del velocímetro",
        "{FF0000}Rojo\n{00FF00}Verde\n{00FFFF}Cyan\n{FF69B4}Rosado\n{800080}Morado",
        "Seleccionar", "Cancelar");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 1000 && response)
    {
        switch(listitem)
        {
            case 0: PlayerSpeedColor[playerid] = COLOR_RED;
            case 1: PlayerSpeedColor[playerid] = COLOR_GREEN;
            case 2: PlayerSpeedColor[playerid] = COLOR_CYAN;
            case 3: PlayerSpeedColor[playerid] = COLOR_PINK;
            case 4: PlayerSpeedColor[playerid] = COLOR_PURPLE;
        }
        SendClientMessage(playerid, PlayerSpeedColor[playerid],
            "* [Server]: Color del velocímetro actualizado.");
    }
    return 1;
}

forward AttachSpeedBoard(playerid, vehid);
public AttachSpeedBoard(playerid, vehid)
{
    new Float:X, Float:Y, Float:Z;
    GetVehicleModelInfo(GetVehicleModel(vehid), VEHICLE_MODEL_INFO_SIZE, X, Y, Z);
    new Float:sx, Float:sy, Float:sz;
    GetVehicleModelInfo(GetVehicleModel(vehid), VEHICLE_MODEL_INFO_FRONTSEAT, sx, sy, sz);

    if(IsAMotorBike(vehid) || IsABike(vehid))
    {
        AttachPlayerObjectToVehicle(playerid, PlayerSpeedObject[playerid], vehid, sx-2.5*X, sy, sz+0.2, 0.0, 0.0, -80.0);
    }
    else
    {
        AttachPlayerObjectToVehicle(playerid, PlayerSpeedObject[playerid], vehid, sx-1.2*X, sy, sz+0.2, 0.0, 0.0, -80.0);
    }
    return 1;
}

stock IsABike(carid)
{
    switch(GetVehicleModel(carid))
    {
        case 509, 481, 510: return 1;
    }
    return 0;
}

stock IsAMotorBike(carid)
{
    switch(GetVehicleModel(carid))
    {
        case 509, 510, 462, 448, 581, 522, 461, 521, 523, 463, 586, 468, 471: return 1;
    }
    return 0;
}

