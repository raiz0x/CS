#include <amxmodx>
#include <amxmisc>
#include <engine>

#pragma tabsize 0

#define COK_FAZLA_SPREY_KULLANILDI 	"Bir Turda Herkes Toplam En Fazla 20 Adet Sprey Cizebilir. !!"
#define YAMUK_ALANA_SPREY_BASILDI	"Grafiti'yi DUZ duran bir duvara cizmelisin"
#define DUVARDAN_UZAKKEN_SPREY_BASILDI	"Grafiti Cizebilmek Icin Duvara Yaklasmalisiniz"

#define SPREY_SESi "EJD_SPR_BAS.wav"

#define PLUGIN "[ CSGO ] Grafiti Spray Plugini"
#define VERSION "1.0"
#define AUTHOR "Fatih ~ EjderYa"

new sprey_kullanildi[33]
new kimlik_ayarlayici;
new SpreyKimlikleri[21]

new spr_yuzu[52][30]

new const VerilenBilgi[] = "info_target";
new const gszspr_nesneClassname[] = "spr_ejd";

new Float:spreycinsi[33];
new Float:spreycinsi_yard = 0.0;

new sprey_aktifligi
new sprey_bekleme_suresi

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	
	register_event("ResetHUD", "yeni_tur", "b");
	sprey_aktifligi = register_cvar("sprey_aktifligi","1");
	sprey_bekleme_suresi = register_cvar("sprey_bekleme_suresi","30");
	
}
public yeni_tur(){
	
	
	
	
	new  players[32], inums;
	new Uid;
	get_players(players, inums, "ac")
	for(new i;i<inums;i++) {
		
		Uid = players[i]
		sprey_kullanildi[Uid] = -1
	}
	
	new katman
	for(new i;i<charsmax(SpreyKimlikleri)+1;i++) {
		
			katman = SpreyKimlikleri[i]
			
			if ( !(SpreyKimlikleri[katman] == 0 ) ){
			remove_entity(SpreyKimlikleri[katman]);
			SpreyKimlikleri[katman]  = 0 ;
	}
			
	}
	
}
public plugin_precache(){
	
	
	precache_sound(SPREY_SESi);
	spr_yuzu[0] = "sprites/Ejderya_0.spr";
	spr_yuzu[1] = "sprites/Ejderya_1.spr";
	spr_yuzu[2] = "sprites/Ejderya_2.spr";
	spr_yuzu[3] = "sprites/Ejderya_3.spr";
	spr_yuzu[4] = "sprites/Ejderya_4.spr";
	spr_yuzu[5] = "sprites/Ejderya_5.spr";
	spr_yuzu[6] = "sprites/Ejderya_6.spr";
	spr_yuzu[7] = "sprites/Ejderya_7.spr";
	spr_yuzu[8] = "sprites/Ejderya_8.spr";
	spr_yuzu[9] = "sprites/Ejderya_9.spr";
	spr_yuzu[10] = "sprites/Ejderya_10.spr";
	spr_yuzu[11] = "sprites/Ejderya_11.spr";
	spr_yuzu[12] = "sprites/Ejderya_12.spr";
	spr_yuzu[13] = "sprites/Ejderya_13.spr";
	spr_yuzu[14] = "sprites/Ejderya_14.spr";
	spr_yuzu[15] = "sprites/Ejderya_15.spr";
	spr_yuzu[16] = "sprites/Ejderya_16.spr";
	spr_yuzu[17] = "sprites/Ejderya_17.spr";
	spr_yuzu[18] = "sprites/Ejderya_18.spr";
	spr_yuzu[19] = "sprites/Ejderya_19.spr";
	spr_yuzu[20] = "sprites/Ejderya_20.spr";
	spr_yuzu[21] = "sprites/Ejderya_21.spr";
	spr_yuzu[22] = "sprites/Ejderya_22.spr";
	spr_yuzu[23] = "sprites/Ejderya_23.spr";
	spr_yuzu[24] = "sprites/Ejderya_24.spr";
	spr_yuzu[25] = "sprites/Ejderya_25.spr";
	spr_yuzu[26] = "sprites/Ejderya_26.spr";
	spr_yuzu[27] = "sprites/Ejderya_27.spr";
	spr_yuzu[28] = "sprites/Ejderya_28.spr";
	spr_yuzu[29] = "sprites/Ejderya_29.spr";
	spr_yuzu[30] = "sprites/Ejderya_30.spr";
	spr_yuzu[31] = "sprites/Ejderya_31.spr";
	spr_yuzu[32] = "sprites/Ejderya_32.spr";
	spr_yuzu[33] = "sprites/Ejderya_33.spr";
	spr_yuzu[34] = "sprites/Ejderya_34.spr";
	spr_yuzu[35] = "sprites/Ejderya_35.spr";
	spr_yuzu[36] = "sprites/Ejderya_36.spr";
	spr_yuzu[37] = "sprites/Ejderya_37.spr";
	spr_yuzu[38] = "sprites/Ejderya_38.spr";
	spr_yuzu[39] = "sprites/Ejderya_39.spr";
	spr_yuzu[40] = "sprites/Ejderya_40.spr";
	spr_yuzu[41] = "sprites/Ejderya_41.spr";
	spr_yuzu[42] = "sprites/Ejderya_42.spr";
	spr_yuzu[43] = "sprites/Ejderya_43.spr";
	spr_yuzu[44] = "sprites/Ejderya_44.spr";
	spr_yuzu[45] = "sprites/Ejderya_45.spr";
	spr_yuzu[46] = "sprites/Ejderya_46.spr";
	spr_yuzu[47] = "sprites/Ejderya_47.spr";
	spr_yuzu[48] = "sprites/Ejderya_48.spr";
	spr_yuzu[49] = "sprites/Ejderya_49.spr";
	spr_yuzu[50] = "sprites/Ejderya_50.spr";
	spr_yuzu[51] = "sprites/Ejderya_51.spr";




	new katman[60]
	new DosyaYolu[60]
	for(new i;i<charsmax(spr_yuzu)+1;i++) {
		
			katman = spr_yuzu[i]
			format(DosyaYolu,charsmax(DosyaYolu),"%s",katman)
			precache_model(DosyaYolu)
			
	}
}
public client_impulse (id, impulse){
	
	if (impulse == 201){
		if ( get_pcvar_num(sprey_aktifligi)  == 1) {
			if ( !(SpreyKimlikleri[20] == 0) ){
				client_print(id, print_center, COK_FAZLA_SPREY_KULLANILDI);
				return PLUGIN_HANDLED;
			}
			
			if ( !(sprey_kullanildi[id] <= 0 ) ){
				
				client_print(id, print_center, "Grafiti Cizebilmek Icin %d Saniye Kadar Beklemelisin",sprey_kullanildi[id]);
				return PLUGIN_HANDLED;
				
				
			}
			if ( spreycinsi[id] > 51.0 ){
				spreycinsi[id] = 0.0 ;
			}
			
			
			createspr_nesneAiming(id, floatround(spreycinsi[id])  );
			spreycinsi[id] += 1.0;
			spreycinsi_yard = spreycinsi[id];
			sprey_kullanildi[id] = get_pcvar_num( sprey_bekleme_suresi );
			sprey_kontrol(id)
			
			
			return PLUGIN_HANDLED;
		}
	}
	return 0;
}
public sprey_kontrol(id){
	
	if ( !(sprey_kullanildi[id] <= 0 ) ){
		
		sprey_kullanildi[id] -= 1
		set_task(1.0,"sprey_kontrol",id)
		
	}
	
	
}
createspr_nesneAiming(id, spr_tip){
	
	if ( is_user_alive(id) ){
		new merkez[3];
		new Float:vmerkez[3];
		new Float:Acilar[3];
		new Float:vNormal[3];
		
		//get the merkez of where the player is aiming
		get_user_origin(id, merkez, 3);
		IVecFVec(merkez, vmerkez);
		
		new bool:islem_tamam = izspr_nesneAngles(id, Acilar, vNormal, 1000.0);
		
		//if the iz was successfull
		if (islem_tamam)
		{
			//if the plane the iz hit is vertical
			if (vNormal[2] == 0.0)
			{
				//create the spr_nesne
				new bool:islem_tamam = createspr_nesne(spr_tip, vmerkez, Acilar, vNormal);
				
				//if spr_nesne created successfully
				if (islem_tamam)
				{
					emit_sound(id, CHAN_VOICE, SPREY_SESi  , 0.75, ATTN_NONE, 0, PITCH_NORM)
					
				}
			}
			else
			{
				client_print(id, print_center, YAMUK_ALANA_SPREY_BASILDI);
			}
		}
		else
		{
			client_print(id, print_center, DUVARDAN_UZAKKEN_SPREY_BASILDI);
		}
	}
}

bool:createspr_nesne(spr_tip, Float:vmerkez[3], Float:Acilar[3], Float:vNormal[3]){
	new spr_nesne = create_entity(VerilenBilgi);
	
	new bool:bFailed = false;
	
	
	if (is_valid_ent(spr_nesne) && !bFailed )
	{
		
		vmerkez[0] += (vNormal[0] * 0.5);
		vmerkez[1] += (vNormal[1] * 0.5);
		vmerkez[2] += (vNormal[2] * 0.5);
		
		
		entity_set_string(spr_nesne, EV_SZ_classname, gszspr_nesneClassname );
		entity_set_model(spr_nesne, spr_yuzu[random_num(0,51)]);
		entity_set_vector(spr_nesne, EV_VEC_angles, Acilar ) ;
		entity_set_float(spr_nesne, EV_FL_scale, 0.23);
		entity_set_origin(spr_nesne, vmerkez);
		entity_set_int(spr_nesne, EV_INT_groupinfo, spr_tip);
		entity_set_float(spr_nesne, EV_FL_frame, spreycinsi_yard );
		
		kimlik_ayarlayici = spr_nesne;
		kimlik_hesapla();
		
		
	}
	
	return true;
}
public kimlik_hesapla(){
	
	
	new katman
	for(new i;i<charsmax(SpreyKimlikleri)+1;i++) {
		
			katman = SpreyKimlikleri[i]
			
			if ( SpreyKimlikleri[katman] == 0 ){
				SpreyKimlikleri[katman] = kimlik_ayarlayici;
				return PLUGIN_HANDLED;
			}
			
	}
	
	return PLUGIN_HANDLED;
	
}
bool:izspr_nesneAngles(id, Float:Acilar[3], Float:vNormal[3], Float:fmesafe)
{
//get players merkez and add on their view offset
new Float:vPlayermerkez[3];
new Float:vViewOfs[3];
entity_get_vector(id, EV_VEC_origin, vPlayermerkez);
entity_get_vector(id, EV_VEC_view_ofs, vViewOfs);

vPlayermerkez[0] += vViewOfs[0];
vPlayermerkez[1] += vViewOfs[1];
vPlayermerkez[2] += vViewOfs[2];

//calculate the end point for iz using the players view angle
new Float:Oyuncu_nisan[3];
entity_get_vector(id, EV_VEC_v_angle, Acilar);

Oyuncu_nisan[0] = vPlayermerkez[0] + floatcos(Acilar[1], degrees ) * fmesafe;	
Oyuncu_nisan[1] = vPlayermerkez[1] + floatsin(Acilar[1], degrees) * fmesafe;
Oyuncu_nisan[2] = vPlayermerkez[2] + floatsin(-Acilar[0], degrees) * fmesafe;




new iz = trace_normal(id, vPlayermerkez, Oyuncu_nisan, vNormal);


vector_to_angle(vNormal, Acilar);



Acilar[1] += 180.0;




if (Acilar[1] >= 360.0) Acilar[1] -= 360.0;

return bool:iz;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1055\\ f0\\ fs16 \n\\ par }
*/
