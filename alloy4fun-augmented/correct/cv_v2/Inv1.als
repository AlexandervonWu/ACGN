module alloy4fun_augmented_cv_v2_Inv1
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

pred Inv1_oracle[] {
(all u: (one User) {
((u.visible) in (u.profile))
})
}

pred Inv1_correct_0[] {
(all u: (one User),v: (one (u.visible)) {
(v in (u.profile))
})
}

pred Inv1_correct_1[] {
(visible in profile)
}

pred Inv1_correct_2[] {
(always (all u: (one User),v: (one (u.visible)) {
(v in (u.profile))
}))
}

pred Inv1_correct_3[] {
(all w: (one Work),u: (one User) {
((w in (u.visible)) => (w in (u.profile)))
})
}

pred Inv1_correct_4[] {
(visible = (visible & profile))
}

