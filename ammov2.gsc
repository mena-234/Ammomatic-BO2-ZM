#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_perks;

init()
{
    level thread onPlayerConnect();
    thread ammo_purchase();
}

onPlayerConnect()
{
    level endon("end_game");
    self endon("disconnect");
    self thread onPlayerSpawned();
}

onPlayerSpawned()
{
    level endon("end_game");
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
    }
}

ammo_purchase()
{
    if (getDvar("mapname") == "zm_prison") // Mob of the Dead
    {
        create_ammo_box((3379, 9938, 1734)); // Roft
        create_ammo_box((720, 6557, 230)); //Jugg
        create_ammo_box((-1096, -3258, -8420)); // Briedge 
    }
    else if (getDvar("mapname") == "zm_highrise") // Die Rise
    {
        create_ammo_box((2843, 32, 1320)); //Power
        create_ammo_box((2364, 762, 3150)); //Roft
        create_ammo_box((1540, 1332, 3060)); // Mainroom  
    }
    else if (getDvar("mapname") == "zm_buried") // Buried
    {
        create_ammo_box((5066, 706, 40));  // Maze
        create_ammo_box((-1122, 829, 25));  // Leroy
        create_ammo_box((6388, 926, -90)); // Pap 
    }
    else if (getDvar("mapname") == "zm_nuked") // Nuketown
    {
        create_ammo_box((-901, 240, -20));
        create_ammo_box((719, 647, -20));    
    }
    else if (getDvar("mapname") == "zm_transit") // Transit
    {
        create_ammo_box((993, 267, -1)); // Town
        create_ammo_box((8332, -4693, 300));  // Farm
        create_ammo_box((-5652, 5175, -5));  // Bus Depot
    }
    else if (getDvar("mapname") == "zm_tomb") // Origins
    {
        create_ammo_box((-157, 13, -725)); // Bottom Pap
        create_ammo_box((11249, -8773, -390)); //Crazy place
        create_ammo_box((-2814, 362, 250));  //Gen 5
    }
}

create_ammo_box(origin)
{
    trigger = spawn("script_model", origin);
    trigger setmodel("zombie_ammocan");
    playfxontag(level._effect["powerup_on"], trigger, "tag_origin");
    trigger makeusable();
    trigger setcursorhint("HINT_NOICON");

    trigger thread animate_model();
    trigger thread handle_ammo_purchase(trigger);
}

handle_ammo_purchase(trigger)
{
    for (;;)
    {
        trigger waittill("trigger", player);
        player thread update_hintstring(trigger);

        if (player usebuttonpressed())
        {
            cost = 500 + (level.round_number * 1000);

            if (player.score >= cost)
            {
                if (isDefined(player.last_ammo_purchase_time) && (gettime() - player.last_ammo_purchase_time) < 300000)
                {
                    player iPrintLnBold("^1You can buy ammo again in ^6" + ((300000 - (gettime() - player.last_ammo_purchase_time)) / 1000) + " ^1seconds.");
                }
                else
                {
                    player.last_ammo_purchase_time = gettime();
                    player thread ammo_give(player);
                    player.score -= cost;
                    player iPrintLnBold("^6Player ^5" + player.name + " ^6bought MAX AMMO!");
                }
            }
            else
            {
                player iPrintLnBold("^1Not enough points! ^4Ammo costs ^3" + cost + " ^1points.");
            }
        }
    }
}

animate_model()
{
    self endon("disconnect");
    self endon("end_game");

    while (1)
    {
        self rotateyaw(360, 5); 
        wait (5);
    }
}

update_hintstring(trigger)
{
    self endon("disconnect");
    self endon("end_game");
    while (1)
    {
        cost = 500 + (level.round_number * 1000);
        trigger sethintstring("^1Hold ^3&&1^7 ^5to buy Ammo ^2[Cost: " + cost + "]");
        wait(0.5); 
    }
}

ammo_give(player)
{
    level thread full_ammo_powerup(self, player);
    player thread powerup_vo("full_ammo");
    self IPrintLnBold("^1MAX AMMO");
}
