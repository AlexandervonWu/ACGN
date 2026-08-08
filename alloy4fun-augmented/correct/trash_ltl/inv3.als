module alloy4fun_augmented_trash_ltl_inv3
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv3_oracle[] {
always some File
}

pred inv3_correct_0[] {
always some f:File | f in File
}

