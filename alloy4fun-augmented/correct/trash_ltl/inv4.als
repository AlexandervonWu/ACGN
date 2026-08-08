module alloy4fun_augmented_trash_ltl_inv4
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv4_oracle[] {
eventually some Trash
}

pred inv4_correct_0[] {
eventually (some f:File| f in Trash)
}

pred inv4_correct_1[] {
eventually some f:File | f not in Trash implies  f in Trash
}

pred inv4_correct_2[] {
eventually some (File & Trash)
}

