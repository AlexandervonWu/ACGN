module alloy4fun_augmented_trash_fol_inv3
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
some f : File | f in Trash
}

pred inv3_correct_1[] {
some x : File | x in Trash
}

pred inv3_correct_2[] {
some bruh : File | bruh in Trash
}

pred inv3_correct_3[] {
some (File & Trash)
}

pred inv3_correct_4[] {
some f : File, t: Trash | f in t
}

pred inv3_correct_5[] {
(some file : File | file in Trash)
}

pred inv3_correct_6[] {
some w : File | w in Trash
}

pred inv3_correct_7[] {
some (Trash & File)
}

