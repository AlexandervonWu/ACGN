module alloy4fun_augmented_trash_fol_inv2
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
}

pred inv2_correct_1[] {
all x : File | x in Trash
}

pred inv2_correct_2[] {
all b:File | b in Trash
}

pred inv2_correct_3[] {
File = Trash
}

pred inv2_correct_4[] {
Trash = File
}

pred inv2_correct_5[] {
no f:File | f not in Trash
}

pred inv2_correct_6[] {
all file: File | File in Trash
}

pred inv2_correct_7[] {
no File-Trash
}

pred inv2_correct_8[] {
all w : File | w in Trash
}

pred inv2_correct_9[] {
all f:File | one t:Trash | f in t
}

pred inv2_correct_10[] {
all f:File | some t:Trash | f in t
}

pred inv2_correct_11[] {
all bruh : File | bruh in Trash
}

pred inv2_correct_12[] {
(all file : File | file in Trash)
}

