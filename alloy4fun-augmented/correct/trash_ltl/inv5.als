module alloy4fun_augmented_trash_ltl_inv5
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv5_oracle[] {
eventually (some f:File | f not in File')
}

pred inv5_correct_0[] {
eventually (some f : File | after f not in File)
}

pred inv5_correct_1[] {
eventually some f : File | eventually f not in File
}

pred inv5_correct_2[] {
eventually File not in File'
}

pred inv5_correct_3[] {
eventually(some f:File | f in File implies eventually f not in File)
}

pred inv5_correct_4[] {
eventually (some f:File | eventually no f&File)
}

pred inv5_correct_5[] {
eventually some File - File'
}

pred inv5_correct_6[] {
eventually some f:File | no f & File'
}

