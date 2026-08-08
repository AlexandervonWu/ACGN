module alloy4fun_augmented_cv_v2_inv3
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

pred inv3_oracle[] {
all u : User, disj x,y : u.profile | x.source = y.source implies no (x.ids & y.ids)
}

pred inv3_correct_0[] {
all s: Source, u: User| ((source.s & u.profile)<:ids).~((source.s & u.profile)<:ids) in iden
}

pred inv3_correct_1[] {
all s: Source, u: User | all disj w1, w2: (u.profile & source.s) | no w1.ids & w2.ids
}

pred inv3_correct_2[] {
all w1, w2 : Work, u : User {
    (w1 != w2 and ((w1 + w2) in u.profile) and w1.source = w2.source) implies no (w1.ids & w2.ids)
  }
}

pred inv3_correct_3[] {
all s: Source, u: User | all disj w, w1: ((source.s) & u.profile) | no (w.ids & w1.ids)
}

pred inv3_correct_4[] {
all u1 : User , disj w1,w2 :u1.profile | w1.source = w2.source implies no (w1.ids & w2.ids)
}

pred inv3_correct_5[] {
all u : User, disj w1, w2 : u.profile {
    (w1.source = w2.source) implies no (w1.ids & w2.ids)
  }
}

pred inv3_correct_6[] {
all u: User, s: Source | all disj  w1,w2 : u.profile & source.s | no w1.ids & w2.ids
}

