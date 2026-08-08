module alloy4fun_augmented_cv_v1_inv3
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
all s:Source, u:User, disj w1, w2 : (u.profile & source.s) | no w1.ids & w2.ids
}

pred inv3_correct_1[] {
all w1, w2 : Work | all u : User | w1 != w2 and (w1 + w2) in u.profile and (w1.source = w2.source) implies no w1.ids & w2.ids
}

pred inv3_correct_2[] {
all s: Source, u: User| ((source.s & u.profile)<:ids).~((source.s & u.profile)<:ids) in iden
}

pred inv3_correct_3[] {
all s:Source, u:User, i : Id | lone (u.profile & source.s & ids.i)
}

pred inv3_correct_4[] {
all s:Source, u:User | (u.profile & source.s) <: ids in Work lone -> Id
}

pred inv3_correct_5[] {
all u:User,s:Source,i:Id | lone (u.profile & source.s & ids.i)
}

pred inv3_correct_6[] {
all w1, w2 : Work, u : User {
    ((w1 != w2) and ((w1 + w2) in u.profile) and (w1.source = w2.source)) implies no w1.ids & w2.ids
  }
}

pred inv3_correct_7[] {
all u: User, disj w1, w2: u.profile | w1.source = w2.source => no w1.ids & w2.ids
}

pred inv3_correct_8[] {
all s:Source, u:User | all disj w1, w2 : (u.profile & source.s) | no w1.ids & w2.ids
}

pred inv3_correct_9[] {
all u: User | all disj w1, w2: u.profile | w1.source = w2.source => no (w1.ids & w2.ids)
}

