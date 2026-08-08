module alloy4fun_augmented_trash_ltl_inv18
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv18_oracle[] {
always all f : Protected | f in Trash releases f in Protected
}

pred inv18_correct_0[] {
always (all f:File | f in Protected implies (f in Trash) releases (f in Protected))
}

pred inv18_correct_1[] {
always all f : Protected | f not in Protected' implies f in Trash
}

pred inv18_correct_2[] {
always all p: Protected | after p not in Protected implies p in Trash
}

pred inv18_correct_3[] {
always (all f:Protected | after f not in Protected implies f in Trash)
}

pred inv18_correct_4[] {
always all p:Protected | p not in Protected' implies p in Trash
}

