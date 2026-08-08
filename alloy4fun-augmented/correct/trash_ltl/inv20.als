module alloy4fun_augmented_trash_ltl_inv20
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv20_oracle[] {
always (all f:Trash | not (f not in Trash triggered f in Protected))
}

pred inv20_correct_0[] {
always (all f :  Trash | f in Trash since f not in Protected)
}

pred inv20_correct_1[] {
always (all f:Trash | f in Trash  since  no (f & Protected) )
}

pred inv20_correct_2[] {
always all t : Trash | (t in Trash) since (t not in Protected)
}

pred inv20_correct_3[] {
always all p : Trash | p in Trash since p not in Protected
}

pred inv20_correct_4[] {
always (all f:File | f in Trash implies f in Trash since f not in Protected)
}

