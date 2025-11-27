#include <amxmodx>
#include <engine>

public client_PreThink(id)
{
    if(!is_user_alive(id)) 
        return

    static Float:fallspeed;fallspeed = 100.0 * -1.0,button;button = get_user_button(id)
    if(button & IN_USE) 
    {
        static Float:velocity[3]
        entity_get_vector(id, EV_VEC_velocity, velocity)
        if (velocity[2] < 0.0) 
        {
            entity_set_int(id, EV_INT_sequence, 3)
            entity_set_int(id, EV_INT_gaitsequence, 1)
            entity_set_float(id, EV_FL_frame, 1.0)
            entity_set_float(id, EV_FL_framerate, 1.0)

            velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
            entity_set_vector(id, EV_VEC_velocity, velocity)
        }
    }
}
