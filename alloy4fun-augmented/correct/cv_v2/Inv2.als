module alloy4fun_augmented_cv_v2_Inv2
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

pred Inv2_oracle[] {
(all u: (one User),w: (one Work) {
((w in (u.profile)) => ((u in (w.source)) || (some i: (one Institution) {
(i in (w.source))
})))
})
}

pred Inv2_correct_0[] {
(all u: (one User),s: (one (u.profile)) {
((some ((s.source) & u)) || (some ((s.source) & Institution)))
})
}

pred Inv2_correct_1[] {
(all u: (one User) {
(all w: (one Work) {
((w in (u.profile)) => (((w.source) in u) || ((w.source) in Institution)))
})
})
}

pred Inv2_correct_2[] {
(all u: (one User),p: (one (u.profile)) {
((p.source) in (u + Institution))
})
}

pred Inv2_correct_3[] {
(all u: (one User),w: (one (u.profile)) {
(((w.source) = u) || ((w.source) in Institution))
})
}

pred Inv2_correct_4[] {
(all u: (one User) {
(((u.profile).source) in (u + Institution))
})
}

pred Inv2_correct_5[] {
(all u: (one User) {
(((u.profile).source) in (Institution + u))
})
}

pred Inv2_correct_6[] {
(always (all u: (one User),p: (one (u.profile)) {
((p.source) in (u + Institution))
}))
}

pred Inv2_correct_7[] {
(all u: (one User) {
(no ((((u.profile).source) - Institution) - u))
})
}

pred Inv2_correct_8[] {
((profile.source) in (iden + (User->Institution)))
}

pred Inv2_correct_9[] {
(all u: (one User),w: (one (u.profile)) {
(((w.source) = u) || (some ((w.source) & Institution)))
})
}

