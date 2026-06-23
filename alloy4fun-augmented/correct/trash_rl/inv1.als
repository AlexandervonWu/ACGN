module alloy4fun_augmented_trash_rl_inv1
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv1_oracle[] {
(no Trash)
}

pred inv1_correct_0[] {
(no Trash)
}

pred inv1_correct_1[] {
(no f: (one File) {
(f in Trash)
})
}

pred inv1_correct_2[] {
(all t: (one Trash) {
(t in none)
})
}

pred inv1_correct_3[] {
(Trash = none)
}

pred inv1_correct_4[] {
(all f: (one File) {
(!(f in Trash))
})
}

pred inv1_correct_5[] {
(Trash in none)
}

pred inv1_correct_6[] {
(all f: (one File) {
(no Trash)
})
}

pred inv1_correct_7[] {
(all f: (one File) {
(f !in Trash)
})
}

pred inv1_correct_8[] {
(always (no Trash))
}

