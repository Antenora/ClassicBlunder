mob/Admin3/verb
    DebugCheckForSkillAdvancement()
        for(var/obj/Skills/s in src)
            if(s.advanceData)
                src << "[s] has advance data! It is type [s.advanceData.type]"