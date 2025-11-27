#include <amxmodx>
#include <fakemeta>

#define VERSION "0.0.1"

new Trie:g_tModels

public plugin_init()
{
    register_plugin("KadiR Models", VERSION, "ConnorMcLeod")

    register_forward(FM_SetClientKeyValue, "SetClientKeyValue")

    g_tModels = TrieCreate()
    TrieSetString(g_tModels, "urban", "zombieurban")
    TrieSetString(g_tModels, "terror", "zombieurban")
    TrieSetString(g_tModels, "sas", "zombiesas")
    TrieSetString(g_tModels, "leet", "zombiesas")
    TrieSetString(g_tModels, "guerilla", "zombiegsg9")
    TrieSetString(g_tModels, "gsg9", "zombiegsg9")
    TrieSetString(g_tModels, "gign", "zombiegign")
    TrieSetString(g_tModels, "arctic", "zombiegign")
}

public plugin_end()
{
    TrieDestroy(g_tModels)
}

public plugin_precache()
{
    precache_model("models/player/zombieurban/zombieurban.mdl")
    precache_model("models/player/zombiesas/zombiesas.mdl")
    precache_model("models/player/zombiegsg9/zombiegsg9.mdl")
    precache_model("models/player/zombiegign/zombiegign.mdl")
}

public SetClientKeyValue(id, szInfoBuffer[], szKey[], szValue[])
{
    static const model[] = "model"
    if( equal(szKey, model) )
    {
        static szModel[12]
        TrieGetString(g_tModels, szValue, szModel, charsmax(szModel));
        set_user_info(id, model, szModel)
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
}
