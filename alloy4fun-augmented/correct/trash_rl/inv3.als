module alloy4fun_augmented_trash_rl_inv3
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv3_oracle[] {
(some Trash)
}

pred inv3_correct_0[] {
(some (File & Trash))
}

pred inv3_correct_1[] {
(some Trash)
}

pred inv3_correct_2[] {
(some x: (one File) {
(x in Trash)
})
}

pred inv3_correct_3[] {
(some f: (one File) {
(f in Trash)
})
}

pred inv3_correct_4[] {
(some (Trash <: File))
}

pred inv3_correct_5[] {
(some (File->Trash))
}

