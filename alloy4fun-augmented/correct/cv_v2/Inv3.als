module alloy4fun_augmented_cv_v2_Inv3
open util/integer [] as integer
abstract sig Source {}
sig User extends Source {
profile: (set Work),
visible: (set Work)
}
sig Institution extends Source {}
sig Id {}
sig Work {
ids: (some Id),
source: (one Source)
}

pred Inv3_oracle[] {
(all w1,w2: (one Work),u: (one User) {
(((w1 != w2) && ((w1 + w2) in (u.profile)) && ((w1.source) = (w2.source))) => (no ((w1.ids) & (w2.ids))))
})
}

pred Inv3_correct_0[] {
(all u: (one User),s: (one Source) {
(all disj w1,w2: (one ((u.profile) & (source.s))) {
(no ((w1.ids) & (w2.ids)))
})
})
}

pred Inv3_correct_1[] {
(all s: (one Source),disj a,b: (one (source.s)) {
((some ((profile.a) & (profile.b))) => (no ((a.ids) & (b.ids))))
})
}

pred Inv3_correct_2[] {
(all s: (one Source),u: (one User) {
(((((source.s) & (u.profile)) <: ids).(~(((source.s) & (u.profile)) <: ids))) in iden)
})
}

pred Inv3_correct_3[] {
(all s: (one Source),u: (one User) {
(all disj w1,w2: (one ((u.profile) & (source.s))) {
(no ((w1.ids) & (w2.ids)))
})
})
}

pred Inv3_correct_4[] {
(all u1: (one User),disj w1,w2: (one (u1.profile)) {
(((w1.source) = (w2.source)) => (no ((w1.ids) & (w2.ids))))
})
}

pred Inv3_correct_5[] {
(all s: (one Source),u: (one User) {
(all disj w,w1: (one ((source.s) & (u.profile))) {
(no ((w.ids) & (w1.ids)))
})
})
}

