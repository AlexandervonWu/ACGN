module alloy4fun_augmented_trash_ltl_inv19
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv19_oracle[] {
always all f : Protected | f in Protected until f in Trash
}

pred inv19_correct_0[] {
always (all f:File | f in Protected implies f in Protected until f in Trash)
}

pred inv19_correct_1[] {
always all p : Protected | p in Protected until p in Trash
}

