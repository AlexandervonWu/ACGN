module alloy4fun_augmented_trash_ltl_inv10
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv10_oracle[] {
always Protected = Protected'
}

pred inv10_correct_0[] {
always Protected' = Protected
}

pred inv10_correct_1[] {
always all p: Protected | historically p in Protected and always p in Protected
}

