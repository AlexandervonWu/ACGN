module alloy4fun_augmented_trash_ltl_inv9
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv9_oracle[] {
always no Protected & Trash
}

pred inv9_correct_0[] {
always (all f: Protected | f not in Trash)
}

pred inv9_correct_1[] {
always all f:File | f in Protected implies f not in Trash
}

pred inv9_correct_2[] {
always Protected in File-Trash
}

pred inv9_correct_3[] {
always (all p:Protected | no p&Trash)
}

pred inv9_correct_4[] {
always (Trash-Protected) = Trash
}

pred inv9_correct_5[] {
always all p:Protected | p not in Trash
}

pred inv9_correct_6[] {
always no Trash & Protected
}

