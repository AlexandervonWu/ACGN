module alloy4fun_augmented_trash_ltl_inv8
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv8_oracle[] {
always (all f:link.File | eventually f in Trash)
}

pred inv8_correct_0[] {
always (all f : File | some f.link implies eventually f in Trash)
}

pred inv8_correct_1[] {
always all f1,f2 : File | f1 -> f2 in link implies eventually f1 in Trash
}

pred inv8_correct_2[] {
always all f, g : File | f->g in link implies eventually f in Trash
}

pred inv8_correct_3[] {
always all a,b:File | a->b in link implies eventually a in Trash
}

pred inv8_correct_4[] {
always all l : link.File | eventually l in Trash
}

pred inv8_correct_5[] {
always all f:File| f in link.File implies eventually f in Trash
}

