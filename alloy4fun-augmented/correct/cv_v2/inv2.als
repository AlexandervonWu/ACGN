module alloy4fun_augmented_cv_v2_inv2
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
all u : User, w : u.profile | w.source = u || w.source in Institution
}

pred inv2_correct_1[] {
always (all u : User, p : u.profile | p.source in u+Institution)
}

pred inv2_correct_2[] {
profile.source in iden + User->Institution
}

pred inv2_correct_3[] {
all u: User | u.profile.source in u + Institution
}

pred inv2_correct_4[] {
all u:User |all w:Work | w in u.profile implies (w.source in u or w.source in Institution)
}

pred inv2_correct_5[] {
all u : User , s : u.profile | some (s.source & u) or some (s.source & Institution)
}

pred inv2_correct_6[] {
all u : User, w : u.profile | w.source = u || some (w.source) & Institution
}

pred inv2_correct_7[] {
all u:User | no ((u.profile.source) - Institution - u)
}

pred inv2_correct_8[] {
all u:User, p:u.profile | p.source in u + Institution
}

