module alloy4fun_augmented_trash_rl_inv5
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5_oracle[] {
File = Trash + Protected
}

pred inv5_correct_0[] {
all f: File | f not in Protected implies f in Trash
}

pred inv5_correct_1[] {
(File - Protected) in Trash
}

pred inv5_correct_2[] {
Trash = File - (Protected - Trash)
}

pred inv5_correct_3[] {
File = Protected + Trash
}

pred inv5_correct_4[] {
all w : File | w not in Protected implies w in Trash
}

pred inv5_correct_5[] {
Trash + Protected = File
}

pred inv5_correct_6[] {
all np: File-Protected| np in Trash
}

pred inv5_correct_7[] {
all f: File - Protected |f in Trash
}

pred inv5_correct_8[] {
all f:File | not f in Protected => f in Trash
}

pred inv5_correct_9[] {
Protected + Trash = File
}

pred inv5_correct_10[] {
all file: File |
file not in Protected implies file in Trash
}

pred inv5_correct_11[] {
all v : File | v not in Protected implies v in Trash
}

pred inv5_correct_12[] {
all f: File | f not in Protected implies f in Trash




(File - Protected) in Trash
}

pred inv5_correct_13[] {
all f: File | f in Trash or f in Protected
}

pred inv5_correct_14[] {
all f : univ | f in File and f not in Protected implies f in Trash
}

pred inv5_correct_15[] {
no (File - Protected) - Trash
}

pred inv5_correct_16[] {
all f: File| f in Protected or f in Trash
}

