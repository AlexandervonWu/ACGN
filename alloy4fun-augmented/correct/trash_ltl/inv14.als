module alloy4fun_augmented_trash_ltl_inv14
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv14_oracle[] {
always (all f:Trash&Protected | f not in Protected')
}

pred inv14_correct_0[] {
always(all f:Trash&Protected | after f not in Protected)
}

pred inv14_correct_1[] {
always no Protected & Trash & Protected'
}

pred inv14_correct_2[] {
always all f:File | f in Trash and f in Protected implies f in Trash and f not in Protected'
}

pred inv14_correct_3[] {
always all f : File | (f in Protected & Trash) implies (f not in Protected')
}

pred inv14_correct_4[] {
always all f : Protected & Trash | f not in Protected'
}

pred inv14_correct_5[] {
always all f:File | f in Trash and f in Protected implies f not in Protected'
}

pred inv14_correct_6[] {
always all p: Protected | p in Trash implies after p not in Protected
}

pred inv14_correct_7[] {
always (all f: Protected | f in Trash implies f not in Protected')
}

pred inv14_correct_8[] {
always (all f : Protected | f in Trash implies after f not in Protected)
}

pred inv14_correct_9[] {
always all f:Trash | f in Protected implies f not in Protected'
}

pred inv14_correct_10[] {
always all p: (Protected & Trash) | after p not in Protected
}

pred inv14_correct_11[] {
always all f : File | f in Trash & Protected implies f not in Protected'
}

pred inv14_correct_12[] {
always all pt : Protected & Trash | after pt not in Protected
}

pred inv14_correct_13[] {
always (all f:File | f in Trash and f in Protected implies after f not in Protected)
}

pred inv14_correct_14[] {
always (all f:Protected |  some (f & Trash) implies no (Protected' & f) )
}

pred inv14_correct_15[] {
always(all f : (Trash & Protected) | after no(f & Protected))
}

pred inv14_correct_16[] {
always (all f:File | f in Protected&Trash implies after (f not in Protected))
}

pred inv14_correct_17[] {
always all t: Trash & Protected | after t not in Protected
}

pred inv14_correct_18[] {
always all f:File | f in Protected and f in Trash implies f not in Protected'
}

