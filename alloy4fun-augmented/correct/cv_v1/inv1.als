module alloy4fun_augmented_cv_v1_inv1
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
all w:Work | visible.w in profile.w
}

pred inv1_correct_1[] {
all u:User | u.visible in u.profile
  	all w:Work | visible.w in profile.w
}

pred inv1_correct_2[] {
visible in profile
}

pred inv1_correct_3[] {
all w:Work,u:User | w in u.visible implies w in u.profile
}

pred inv1_correct_4[] {
visible = (visible & profile)
}

pred inv1_correct_5[] {
all u: User, w: Work | w in u.visible implies w in u.profile
}

pred inv1_correct_6[] {
all u:User | all w:Work | w in u.visible implies w in u.profile
}

pred inv1_correct_7[] {
all u:User, v:u.visible | v in u.profile
}

pred inv1_correct_8[] {
all u:User, w:u.visible | w in u.profile
}

