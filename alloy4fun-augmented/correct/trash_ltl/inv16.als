module alloy4fun_augmented_trash_ltl_inv16
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv16_oracle[] {
always (all f:Protected | historically f in Protected)
}

pred inv16_correct_0[] {
always all p:Protected | historically p in Protected
}

pred inv16_correct_1[] {
always (all f:File | f in Protected implies historically f in Protected)
}

pred inv16_correct_2[] {
always(all f : (File & Protected) | historically (f in Protected))
}

pred inv16_correct_3[] {
always all f : Protected | f in Protected implies historically f in Protected
}

pred inv16_correct_4[] {
always (all f:File | f in Protected implies  (historically some (f &   Protected)))
}

