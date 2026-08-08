module alloy4fun_augmented_cv_v2_inv4
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
all u : User, disj x,y : u.visible | x not in y.^((u.profile <: ids).~(u.profile <: ids))
}

pred inv4_correct_0[] {
all u: User, disj w1, w2 : u.visible | no w1->w2 & ^((u.profile<:ids).~(u.profile<:ids))
}

pred inv4_correct_1[] {
all u: User | ((u.visible->u.visible) & ^((u.profile<:ids).~(u.profile<:ids))) in iden
}

pred inv4_correct_2[] {
all u: User, w1, w2 : u.visible | (w1->w2) & ^((u.profile<:ids).~(u.profile<:ids)) in iden
}

pred inv4_correct_3[] {
all u: User | u.visible<:^((u.profile<:ids).~(u.profile<:ids)):>u.visible in iden
}

pred inv4_correct_4[] {
all u:User | all  w :u.profile | lone ((w.^((ids.~ids) :> u.profile)) & u.visible)
}

pred inv4_correct_5[] {
all u: User | (u.visible->u.visible) & *((u.profile<:ids).~(u.profile<:ids)) in iden
}

pred inv4_correct_6[] {
all u: User | u.visible<:^((u.profile<:ids).~(u.profile<:ids)).~(u.visible<:^((u.profile<:ids).~(u.profile<:ids))) in iden
}

