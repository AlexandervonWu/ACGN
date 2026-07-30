module alloy4fun_augmented_trash_rl_inv2
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2_oracle[] {
File in Trash
}

pred inv2_correct_0[] {
all f : File | f in Trash



File in Trash
}

pred inv2_correct_1[] {
all f: File | f in Trash
}

pred inv2_correct_2[] {
File = Trash
}

pred inv2_correct_3[] {
Trash = File
}

pred inv2_correct_4[] {
no File - Trash
}

pred inv2_correct_5[] {
all f:File | some t:Trash | f in t
}

pred inv2_correct_6[] {
all x: File | x in Trash
}

pred inv2_correct_7[] {
eventually File in Trash
}

pred inv2_correct_8[] {
all f:File | one t:Trash | f in t
}

pred inv2_correct_9[] {
not some f:File | f not in Trash
}

pred inv2_correct_10[] {
File & Trash = File
}

