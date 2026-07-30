module alloy4fun_augmented_trash_rl_inv4
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
no Trash & Protected
}

pred inv4_correct_1[] {
all x : Protected | x not in Trash
}

pred inv4_correct_2[] {
all p: Protected | p !in Trash
}

pred inv4_correct_3[] {
all f:Protected | f not in Trash
}

pred inv4_correct_4[] {
no f: Protected | f in Trash
}

pred inv4_correct_5[] {
all f:File | f in Protected => not f in Trash
}

pred inv4_correct_6[] {
no p: Protected| p in Trash
}

pred inv4_correct_7[] {
all p: Protected |
not (p in Trash)
}

pred inv4_correct_8[] {
not some f:Protected | f in Trash
}

pred inv4_correct_9[] {
Protected & Trash = none
}

pred inv4_correct_10[] {
all p : Protected | p not in Trash




no Protected & Trash
}

pred inv4_correct_11[] {
Protected - Trash = Protected
}

pred inv4_correct_12[] {
no f: File | f in Protected and f in Trash
}

pred inv4_correct_13[] {
all u : univ | u in Protected implies u not in Trash
}

pred inv4_correct_14[] {
all p : Protected |
p in Protected implies not (p in Trash)
}

pred inv4_correct_15[] {
no t: Trash | t in Protected
}

pred inv4_correct_16[] {
all f: File | f in Protected implies f not in Trash
}

pred inv4_correct_17[] {
all f: Protected | not f in Trash
}

pred inv4_correct_18[] {
all u : File | u in Protected implies u not in Trash
}

pred inv4_correct_19[] {
Protected in File-Trash
}

pred inv4_correct_20[] {
all pf: Protected | no pf&Trash
}

