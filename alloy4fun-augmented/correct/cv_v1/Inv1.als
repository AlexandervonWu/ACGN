module alloy4fun_augmented_cv_v1_Inv1
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
(all w: (one Work) {
((visible.w) in (profile.w))
})
}

pred Inv1_correct_1[] {
(all w: (one Work),u: (one User) {
((w in (u.visible)) => (w in (u.profile)))
})
}

pred Inv1_correct_2[] {
((all u: (one User) {
((u.visible) in (u.profile))
}) && (all w: (one Work) {
((visible.w) in (profile.w))
}))
}

pred Inv1_correct_3[] {
(visible = (visible & profile))
}

pred Inv1_correct_4[] {
(visible in profile)
}

pred Inv1_correct_5[] {
(all u: (one User) {
(all w: (one Work) {
((w in (u.visible)) => (w in (u.profile)))
})
})
}

pred Inv1_correct_6[] {
(all u: (one User),w: (one Work) {
((w in (u.visible)) => (w in (u.profile)))
})
}

