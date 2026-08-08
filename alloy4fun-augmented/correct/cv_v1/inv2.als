module alloy4fun_augmented_cv_v1_inv2
sig User extends Source {
    profile : set Work,
    visible : set Work
}
sig Institution extends Source {}

sig Id {}
sig Work {
    ids : some Id,
    source : one Source
}

pred inv2_oracle[] {
all u : User | u.profile.source in Institution+u
}

pred inv2_correct_0[] {
all x : User | x.profile.source in Institution + x
}

pred inv2_correct_1[] {
all w:Work,u:User | w in u.profile implies u in w.source or w.source in Institution
}

pred inv2_correct_2[] {
all u:User | (u.profile).source in (u+Institution)
}

pred inv2_correct_3[] {
all u:User | all w:(u.profile) | (w.source) in (u + Institution)
}

pred inv2_correct_4[] {
all u:User, w:Work | w in u.profile implies (u in w.source or some i:Institution | i in w.source)
}

pred inv2_correct_5[] {
all u:User | all w:u.profile | w.source = u or w.source in Institution
}

pred inv2_correct_6[] {
all u : User | u.profile in (source.Institution + source.u)
}

pred inv2_correct_7[] {
all u : User | all w : u.profile | w.source in u or w.source in Institution
}

pred inv2_correct_8[] {
all u : User , w : u.profile | w.source = u || w.source in Institution
}

pred inv2_correct_9[] {
all u : User, w : Work | w in u.profile => w.source in Institution + u
}

pred inv2_correct_10[] {
all u : User | (u.profile) in (source.u + source.Institution)
}

pred inv2_correct_11[] {
(profile.source :> User) in iden
}

pred inv2_correct_12[] {
all w:Work,u:User | u->w in profile implies one (w.source:>u + w.source:>Institution)
}

pred inv2_correct_13[] {
all u:User, w:Work | w in u.profile implies (u in w.source or w.source in Institution)
}

pred inv2_correct_14[] {
(User <: profile.source :> User) in iden
}

pred inv2_correct_15[] {
all u : User | all w : Work | (w in u.profile) implies (w.source=u or w.source in Institution)
}

pred inv2_correct_16[] {
all w:Work,u:User | w in u.profile implies (u in w.source or w.source in Institution)
}

pred inv2_correct_17[] {
all u:User, s:Source, w:u.profile | (w.source in Institution) or (w.source = u)
}

