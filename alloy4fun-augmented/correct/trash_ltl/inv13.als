module alloy4fun_augmented_trash_ltl_inv13
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv13_oracle[] {
always (all f:Trash | once f not in Trash)
}

pred inv13_correct_0[] {
all f:File | f in Trash implies once f in File-Trash
}

pred inv13_correct_1[] {
always all t: Trash | once t not in Trash
}

pred inv13_correct_2[] {
all f : File | (f in Trash) implies (once (f not in Trash))
}

pred inv13_correct_3[] {
all f : (File&Trash) | once f not in Trash
}

pred inv13_correct_4[] {
all f:File | f in Trash since f not in Trash
}

pred inv13_correct_5[] {
all t: Trash | once t not in Trash
}

pred inv13_correct_6[] {
all f : File | eventually f in Trash => once f not in Trash
}

pred inv13_correct_7[] {
always all f: File | f in Trash implies once f not in Trash
}

pred inv13_correct_8[] {
all f : Trash | once f not in Trash
}

pred inv13_correct_9[] {
all f: File | always (f in Trash implies once f not in Trash)
}

pred inv13_correct_10[] {
once all f:File | f in Trash implies f not in Trash
}

pred inv13_correct_11[] {
all f:File |  (f in Trash) implies historically once (f not in Trash)
}

pred inv13_correct_12[] {
always all f: File | always (f in Trash implies once f not in Trash)
}

pred inv13_correct_13[] {
all f:File |  (f in Trash) implies historically  (f not in Trash)
}

pred inv13_correct_14[] {
all t : Trash | once t in File - Trash
}

