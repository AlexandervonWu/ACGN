module alloy4fun_augmented_trash_ltl_inv12
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv12_oracle[] {
eventually some f : File | always f in Trash
}

pred inv12_correct_0[] {
eventually (some f : Trash | always f in Trash)
}

pred inv12_correct_1[] {
eventually (some f : File | eventually always f in Trash)
}

pred inv12_correct_2[] {
eventually (some f:File | f in Trash and always f in Trash)
}

pred inv12_correct_3[] {
eventually some f:File | f in Trash releases always f in Trash
}

pred inv12_correct_4[] {
eventually some f: File |  f in Trash and after always f in Trash
}

