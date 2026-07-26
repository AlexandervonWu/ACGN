module alloy4fun_augmented_trash_rl_inv4
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv4_oracle[] {
(no (Protected & Trash))
}

pred inv4_correct_0[] {
(Protected in (File - Trash))
}

pred inv4_correct_1[] {
(all f: (one File) {
((f in Protected) => (f !in Trash))
})
}

pred inv4_correct_2[] {
(all p: (one Protected) {
(p !in Trash)
})
}

pred inv4_correct_3[] {
(all f: (one Protected) {
(f !in Trash)
})
}

pred inv4_correct_4[] {
(!(some f: (one Protected) {
(f in Trash)
}))
}

pred inv4_correct_5[] {
(all w: (one File) {
((w in Protected) => (w !in Trash))
})
}

pred inv4_correct_6[] {
(all x: (one Protected) {
(x !in Trash)
})
}

pred inv4_correct_7[] {
(all f: (one Protected) {
(!(f in Trash))
})
}

pred inv4_correct_8[] {
(no f: (one File) {
((f in Protected) && (f in Trash))
})
}

pred inv4_correct_9[] {
((Protected & Trash) = none)
}

pred inv4_correct_10[] {
(no (Trash & Protected))
}

