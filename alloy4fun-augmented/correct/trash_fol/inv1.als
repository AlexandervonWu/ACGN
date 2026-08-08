module alloy4fun_augmented_trash_fol_inv1
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1_oracle[] {
no Trash
}

pred inv1_correct_0[] {
all t:Trash | t not in File
}

pred inv1_correct_1[] {
all f:File | f not in Trash
}

pred inv1_correct_2[] {
not some f : File | f in Trash
}

pred inv1_correct_3[] {
all x : File | x not in Trash
}

pred inv1_correct_4[] {
no f: File | f in Trash
}

pred inv1_correct_5[] {
all f:File, t:Trash | f not in t
}

pred inv1_correct_6[] {
(all file : File | file not in Trash)
}

pred inv1_correct_7[] {
Trash = none
}

pred inv1_correct_8[] {
all t : univ | t not in Trash
}

pred inv1_correct_9[] {
all f:File | not f in Trash
}

pred inv1_correct_10[] {
all w : File | w not in Trash
}

pred inv1_correct_11[] {
all t : File | t not in Trash
}

pred inv1_correct_12[] {
all t : Trash | t = none
}

pred inv1_correct_13[] {
all t : Trash | no t
}

pred inv1_correct_14[] {
File & Trash = none
}

pred inv1_correct_15[] {
no Trash
all f:File | f not in Trash
}

pred inv1_correct_16[] {
all bruh : File | bruh not in Trash
}

pred inv1_correct_17[] {
Trash in none
}

