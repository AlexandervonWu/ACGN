module alloy4fun_augmented_trash_rl_inv1
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
all files : univ | files in Trash implies no files
}

pred inv1_correct_1[] {
Trash = none
}

pred inv1_correct_2[] {
all files : Trash | files in Trash => no files
}

pred inv1_correct_3[] {
all f:File | f not in Trash
}

pred inv1_correct_4[] {
all f:File | not f in Trash
}

pred inv1_correct_5[] {
no f:File | f in Trash
}

pred inv1_correct_6[] {
Trash in none
}

pred inv1_correct_7[] {
not some f:File | f in Trash
}

pred inv1_correct_8[] {
all files : File | files in Trash => no files
}

pred inv1_correct_9[] {
all f:File, t:Trash | f not in t
}

pred inv1_correct_10[] {
all f: File | no Trash
}

pred inv1_correct_11[] {
all t:Trash | t in none
}

pred inv1_correct_12[] {
all t : Trash | t not in univ
}

pred inv1_correct_13[] {
all f: File | no f&Trash
}

pred inv1_correct_14[] {
all f : File | f not in Trash


no Trash
}

pred inv1_correct_15[] {
always no Trash
}

pred inv1_correct_16[] {
all t : univ | t not in Trash
}

pred inv1_correct_17[] {
all t : Trash | no f : File | f in t
}

