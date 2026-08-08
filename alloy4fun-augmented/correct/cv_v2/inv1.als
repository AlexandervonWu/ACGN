module alloy4fun_augmented_cv_v2_inv1
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

pred inv1_oracle[] {
all u : User | u.visible in u.profile
}

pred inv1_correct_0[] {
visible in profile
}

pred inv1_correct_1[] {
all u:User, v : u.visible | v in u.profile
}

pred inv1_correct_2[] {
visible = (visible & profile)
}

pred inv1_correct_3[] {
all w : Work, u : User | w in u.visible implies w in u.profile
}

pred inv1_correct_4[] {
always (all u : User, v : u.visible | v in u.profile)
}

