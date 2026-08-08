module alloy4fun_augmented_trash_fol_inv4
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4_oracle[] {
no Protected & Trash
}

pred inv4_correct_0[] {
all f : Protected | f not in Trash
}

pred inv4_correct_1[] {
all f:File | f in Protected implies f not in Trash
}

pred inv4_correct_2[] {
not some f : File | f in Protected and f in Trash
}

pred inv4_correct_3[] {
all f : File {
always(f in Protected implies f not in Trash)
}
}

pred inv4_correct_4[] {
all p:Protected | p not in Trash
}

pred inv4_correct_5[] {
no Trash & Protected
}

pred inv4_correct_6[] {
all w : File | w in Protected implies w not in Trash
}

pred inv4_correct_7[] {
all p:Protected | all t:Trash | p!=t
}

pred inv4_correct_8[] {
all bruh : Protected | bruh not in Trash
}

pred inv4_correct_9[] {
all fp : Protected | fp not in Trash
}

pred inv4_correct_10[] {
all f:Trash | f not in Protected
}

pred inv4_correct_11[] {
all x : Protected | x not in Trash
}

pred inv4_correct_12[] {
not some f:Protected | f in Trash
}

pred inv4_correct_13[] {
all f : File | f in Protected => not f in Trash
}

pred inv4_correct_14[] {
all x : File | x in Protected implies x not in Trash
}

pred inv4_correct_15[] {
all f : Protected | not f in Trash
}

pred inv4_correct_16[] {
no p:Protected | p in Trash
}

pred inv4_correct_17[] {
all f : File |f in Trash implies f not in Protected
}

pred inv4_correct_18[] {
not some p:Protected | p in Trash
}

pred inv4_correct_19[] {
all f: Protected | no t: Trash | f in t
}

