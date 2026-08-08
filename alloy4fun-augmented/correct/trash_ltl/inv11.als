module alloy4fun_augmented_trash_ltl_inv11
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv11_oracle[] {
always File-Protected in Protected'
}

pred inv11_correct_0[] {
always all f:File | f in File-Protected implies after f in Protected
}

pred inv11_correct_1[] {
always (all f:File-Protected | after f in Protected)
}

pred inv11_correct_2[] {
always all f : File | f not in Protected implies f in Protected'
}

pred inv11_correct_3[] {
always all f:File |  f not in Protected implies after f in Protected
}

pred inv11_correct_4[] {
always all f : File - Protected | f in Protected'
}

pred inv11_correct_5[] {
always (some (File - Protected) implies ((File - Protected) in Protected'))
}

pred inv11_correct_6[] {
always(all a : File - (File & Protected) |  after (a in Protected))
}

