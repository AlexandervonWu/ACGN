module alloy4fun_augmented_trash_ltl_inv7
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv7_oracle[] {
eventually some Protected
}

pred inv7_correct_0[] {
eventually (some f : File |  f in Protected)
}

pred inv7_correct_1[] {
eventually some File & Protected
}

pred inv7_correct_2[] {
eventually some f:File | f not in Protected implies f in Protected
}

pred inv7_correct_3[] {
eventually some f:File | eventually f in Protected
}

