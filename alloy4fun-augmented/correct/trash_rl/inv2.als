module alloy4fun_augmented_trash_rl_inv2
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv2_oracle[] {
(File in Trash)
}

pred inv2_correct_0[] {
(all x: (one File) {
(x in Trash)
})
}

pred inv2_correct_1[] {
(all f: (one File) {
(f in Trash)
})
}

pred inv2_correct_2[] {
(File = Trash)
}

pred inv2_correct_3[] {
(Trash = File)
}

pred inv2_correct_4[] {
(no (File - Trash))
}

