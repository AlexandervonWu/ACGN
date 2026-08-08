module alloy4fun_augmented_trash_ltl_inv17
var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv17_oracle[] {
always (no Trash&File')
}

pred inv17_correct_0[] {
always ( all f : (File & Trash) | after (f not in File))
}

pred inv17_correct_1[] {
always all t : Trash | t not in File'
}

pred inv17_correct_2[] {
always no File' & File & Trash
}

pred inv17_correct_3[] {
always (all f:File | f in Trash implies after f not in File)
}

pred inv17_correct_4[] {
always all f : Trash | after f not in File
}

pred inv17_correct_5[] {
always all f : File | f in Trash => f not in File'
}

pred inv17_correct_6[] {
always all f:Trash | f not in File'
}

pred inv17_correct_7[] {
always (all f:Trash | after no File&f)
}

pred inv17_correct_8[] {
always all t: Trash | after t not in File
}

pred inv17_correct_9[] {
always (all f : File | before f in Trash implies File = File - f)
}

pred inv17_correct_10[] {
always (all f : File | f in Trash implies after File = File - f)
}

