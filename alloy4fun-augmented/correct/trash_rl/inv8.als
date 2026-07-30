module alloy4fun_augmented_trash_rl_inv8
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8_oracle[] {
no link
}

pred inv8_correct_0[] {
all f: File | no f.link
}

pred inv8_correct_1[] {
no link.File
}

pred inv8_correct_2[] {
no File.link
}

pred inv8_correct_3[] {
link = none -> none
}

pred inv8_correct_4[] {
not some f1, f2:File | (f1->f2 in link)
}

pred inv8_correct_5[] {
all f:File | f.link = none
}

pred inv8_correct_6[] {
all f : File | all f1 : f.link | no f1





no File.link
}

pred inv8_correct_7[] {
all file: File | file.link = none
}

pred inv8_correct_8[] {
all x : File | no x.link
}

pred inv8_correct_9[] {
all f : File | no f->link
}

pred inv8_correct_10[] {
File.link = none
}

pred inv8_correct_11[] {
all f1,f2 : univ | f1->f2 not in link
}

pred inv8_correct_12[] {
all f:File | no f.link & File
}

pred inv8_correct_13[] {
all f1,f2:File | not f1->f2 in link
}

