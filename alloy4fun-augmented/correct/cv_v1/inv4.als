module alloy4fun_augmented_cv_v1_inv4
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

pred inv4_oracle[] {
all u : User, disj x,y : u.visible | x not in y.^(ids.~ids)
}

pred inv4_correct_0[] {
all u : User | all disj w1, w2 : u.visible | w1 not in w2.^(ids.~ids)
}

