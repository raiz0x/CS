#include <amxmodx>
#include <fakemeta>

public plugin_init()
{
    register_forward(FM_UpdateClientData, "fw_updateClientData")
}

public fw_updateClientData(id)
{
    // Scoreboard key being pressed?
    if (!(pev(id, pev_button) & IN_SCORE) && !(pev(id, pev_oldbuttons) & IN_SCORE))
        return;
        
    new ping = random_num(5,28) // make sure it's not negative or above 4095
    new ping1
    new ping2
    new offset1
    new offset2
    new sending

    for(new player = 1; player < get_maxplayers(); player++)
    {
        if(!is_user_connected(id))
            continue;
    
        for(new offset1 = 0; offset1 < 4; offset1++)
        {
            if ((ping - offset1) % 4 == 0)
            {
                ping1 = (ping - offset1) / 4
                break;
            }
        }

        for(new offset2 = 0; offset2 < 2; offset2++)
        {
            if ((ping - offset2) % 2 == 0)
            {
                ping2 = (ping - offset2) / 4
                break;
            }
        }

        switch(sending)
        {
            case 0:
            {
                message_begin(MSG_ONE_UNRELIABLE, SVC_PINGS, _, id)
                write_byte((offset1 * 64) + (1 + 2 * (player - 1)))
                write_short(ping1)

                sending++
            }
            case 1:
            {
                write_byte((offset2 * 128) + (2 + 4 * (player - 1)))
                write_short(ping2)

                sending++
            }
            case 2:
            {
                write_byte((4 + 8 * (player - 1)))
                write_short(ping)
                write_byte(0)
                message_end()

                sending = 0
            }
        }
    }
    
    if(sending)
    {
        write_byte(0)
        message_end()
    }
}
