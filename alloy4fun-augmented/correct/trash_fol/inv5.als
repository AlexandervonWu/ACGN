module alloy4fun_augmented_trash_fol_inv5
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
File - Protected in Trash
}

pred inv5_correct_1[] {
all f:File | f not in Protected implies f in Trash
}

pred inv5_correct_2[] {
all f:(File - Protected) | f in Trash
}

pred inv5_correct_3[] {
all x: File | x not in Protected implies x in Trash
}

pred inv5_correct_4[] {
all f:File | f not in Trash implies f in Protected
}

pred inv5_correct_5[] {
all f : File | not f in Protected => f in Trash
}

pred inv5_correct_6[] {
all bruh : File | ((bruh not in Protected) implies (bruh in Trash))
}

pred inv5_correct_7[] {
all u: File - Protected | u in Trash
}

pred inv5_correct_8[] {
not some f : File | not f in Protected and not f in Trash
}

pred inv5_correct_9[] {
all f: File - Protected | one t : Trash | f in t
}

pred inv5_correct_10[] {
(File - (File & Protected)) in Trash
}

pred inv5_correct_11[] {
all f : File | f in Protected or f in Trash
}

pred inv5_correct_12[] {
File = Protected + Trash
}

pred inv5_correct_13[] {
all f : File {
always(f not in Protected implies f in Trash)
}
}

pred inv5_correct_14[] {
(File - Protected) & Trash = (File - Protected)
}

pred inv5_correct_15[] {
all f : File | f in Protected or (f in Trash and f not in Protected)
}

pred inv5_correct_16[] {
all w : File | w not in Protected implies w in Trash
}

