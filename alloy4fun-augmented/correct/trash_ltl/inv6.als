module alloy4fun_augmented_trash_ltl_inv6
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv6_oracle[] {
always Trash in Trash'
}

pred inv6_correct_0[] {
always all f:Trash | always f in Trash
}

pred inv6_correct_1[] {
always (some Trash implies (always Trash in Trash'))
}

pred inv6_correct_2[] {
always all f:File | (f in Trash) implies always f in Trash
}

pred inv6_correct_3[] {
always (all f:Trash| f in Trash')
}

pred inv6_correct_4[] {
always (all t: Trash | always t in Trash)
}

pred inv6_correct_5[] {
always all f: Trash | once f in Trash implies always f in Trash
}

pred inv6_correct_6[] {
always all f:File | f in Trash implies after always f in Trash
}

pred inv6_correct_7[] {
always all f:File |  f in Trash implies after f in Trash
}

pred inv6_correct_8[] {
always(all f : (File & Trash) | always (f in Trash))
}

pred inv6_correct_9[] {
always (all f : Trash | after f in Trash)
}

pred inv6_correct_10[] {
always (all t:Trash | after t in Trash)
}

pred inv6_correct_11[] {
always all f : Trash | eventually f in Trash implies always f in Trash
}

pred inv6_correct_12[] {
always all f : File | f in Trash implies f in Trash'
}

pred inv6_correct_13[] {
always (all f:Trash | f in Trash implies always f in Trash)
}

