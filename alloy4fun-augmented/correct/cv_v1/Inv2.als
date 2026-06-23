module alloy4fun_augmented_cv_v1_Inv2
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
(all u: (one User) {
(((u.profile).source) in (Institution + u))
})
}

pred Inv2_correct_1[] {
(all w: (one Work),u: (one User) {
(((w in (u.profile)) => (u in (w.source))) || ((w.source) in Institution))
})
}

pred Inv2_correct_2[] {
(all u: (one User) {
(((u.profile).source) in (u + Institution))
})
}

pred Inv2_correct_3[] {
(all u: (one User) {
(all w: (one (u.profile)) {
(((w.source) in u) || ((w.source) in Institution))
})
})
}

pred Inv2_correct_4[] {
(all x: (one User) {
(((x.profile).source) in (Institution + x))
})
}

pred Inv2_correct_5[] {
(all u: (one User) {
(all w: (one (u.profile)) {
(((w.source) = u) || ((w.source) in Institution))
})
})
}

pred Inv2_correct_6[] {
(all u: (one User),w: (one Work) {
((w in (u.profile)) => ((u in (w.source)) || ((w.source) in Institution)))
})
}

pred Inv2_correct_7[] {
(all u: (one User) {
(all w: (one (u.profile)) {
((w.source) in (u + Institution))
})
})
}

pred Inv2_correct_8[] {
(all u: (one User),w: (one Work) {
((w in (u.profile)) => ((u in (w.source)) || (some i: (one Institution) {
(i in (w.source))
})))
})
}

pred Inv2_correct_9[] {
(all u: (one User) {
((u.profile) in ((source.Institution) + (source.u)))
})
}

pred Inv2_correct_10[] {
(all w: (one Work),u: (one User) {
((w in (u.profile)) => ((u in (w.source)) || ((w.source) in Institution)))
})
}

pred Inv2_correct_11[] {
(all u: (one User),w: (one (u.profile)) {
(((w.source) = u) || ((w.source) in Institution))
})
}

pred Inv2_correct_12[] {
(all u: (one User) {
(all work: (one (u.profile)) {
((work.source) in (u + Institution))
})
})
}

pred Inv2_correct_13[] {
(all w: (one Work),u: (one User) {
(((u->w) in profile) => (one (((w.source) :> u) + ((w.source) :> Institution))))
})
}

pred Inv2_correct_14[] {
(all u: (one User) {
((u.profile) in ((source.u) + (source.Institution)))
})
}

