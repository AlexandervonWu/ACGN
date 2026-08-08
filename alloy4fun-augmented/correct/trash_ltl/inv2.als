module alloy4fun_augmented_trash_ltl_inv2
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv2_oracle[] {
no File
  	some File'
}

pred inv2_correct_0[] {
no File and after some File
}

pred inv2_correct_1[] {
historically no File
after some File
}

pred inv2_correct_2[] {
historically no File and some File'
}

