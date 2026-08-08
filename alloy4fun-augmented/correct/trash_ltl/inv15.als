module alloy4fun_augmented_trash_ltl_inv15
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv15_oracle[] {
always (all f:File | eventually f in Trash)
}

pred inv15_correct_0[] {
always(all f : (File - Trash) | eventually f in Trash)
}

