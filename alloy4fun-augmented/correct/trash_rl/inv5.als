module alloy4fun_augmented_trash_rl_inv5
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv5_oracle[] {
((File - Protected) in Trash)
}

pred inv5_correct_0[] {
(no ((File - Protected) - Trash))
}

pred inv5_correct_1[] {
(all w: (one File) {
((w !in Protected) => (w in Trash))
})
}

pred inv5_correct_2[] {
((File - Protected) in Trash)
}

pred inv5_correct_3[] {
(all f: (one (File - Protected)) {
(f in Trash)
})
}

pred inv5_correct_4[] {
(Trash = (File - (Protected - Trash)))
}

pred inv5_correct_5[] {
(all f: (one File) {
((f !in Protected) => (f in Trash))
})
}

pred inv5_correct_6[] {
(File = (Trash + Protected))
}

pred inv5_correct_7[] {
(File = (Protected + Trash))
}

pred inv5_correct_8[] {
(all x: (one File) {
((x !in Protected) => (x in Trash))
})
}

