module alloy4fun_augmented_trash_ltl_inv1
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv1_oracle[] {
no Trash + Protected
}

pred inv1_correct_0[] {
no Trash and no Protected
}

pred inv1_correct_1[] {
once (no Trash + Protected)
}

pred inv1_correct_2[] {
no Trash and no Protected
no Trash && no Protected
}

pred inv1_correct_3[] {
historically no (Trash+Protected)
}

pred inv1_correct_4[] {
historically (no Trash and no Protected  )
}

pred inv1_correct_5[] {
once no Trash and once no Protected
}

pred inv1_correct_6[] {
once (no Trash and no Protected)
}

pred inv1_correct_7[] {
all f : File | historically ((f not in (Trash+Protected)))
}

pred inv1_correct_8[] {
historically (once (no Trash and no Protected))
}

pred inv1_correct_9[] {
no (Trash+Protected)
no Trash and no Protected
}

pred inv1_correct_10[] {
historically no Trash and no Protected
}

pred inv1_correct_11[] {
historically (once (no Trash + Protected))
}

pred inv1_correct_12[] {
all f:File | f not in Trash and f not in Protected
}

pred inv1_correct_13[] {
no Protected
no Trash
}

pred inv1_correct_14[] {
historically (no Trash and no Protected) and
once (no Trash and no Protected)
}

