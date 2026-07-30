module alloy4fun_augmented_trash_rl_inv3
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3_oracle[] {
some Trash
}

pred inv3_correct_0[] {
some f: File | f in Trash
}

pred inv3_correct_1[] {
some f : File | f in Trash





some Trash
}

pred inv3_correct_2[] {
some (File & Trash)
}

pred inv3_correct_3[] {
some file: File |
file in Trash
}

pred inv3_correct_4[] {
some File -> Trash
}

pred inv3_correct_5[] {
some s : File | s in Trash
}

pred inv3_correct_6[] {
some Trash & File
}

pred inv3_correct_7[] {
some f:File | one t:Trash | f in t
}

pred inv3_correct_8[] {
some File
some Trash
}

pred inv3_correct_9[] {
some Trash <: File
}

