module alloy4fun_augmented_trash_rl_inv9
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9_oracle[] {
no link.link
}

pred inv9_correct_0[] {
not some f1, f2, f3:File | f1->f2 in link and f2->f3 in link
}

pred inv9_correct_1[] {
all f : File |
all l : f.link |
no l.link
}

pred inv9_correct_2[] {
no File.link.link
}

pred inv9_correct_3[] {
all f,g,h:File | f->g in link implies g->h not in link
}

pred inv9_correct_4[] {
all f : File | all f1 : f.link | no f1.link



no File.link.link
}

pred inv9_correct_5[] {
File.link.link = none
}

pred inv9_correct_6[] {
all f:File | no f.link.link
}

pred inv9_correct_7[] {
all f: File | f.link.link = none
}

pred inv9_correct_8[] {
all f,f1,f2:File | f->f1 in link implies f1->f2 not in link
}

pred inv9_correct_9[] {
all l1,l2,l3: File| l1->l2 in link implies l2->l3 not in link
}

pred inv9_correct_10[] {
all f : File | some link.f implies no f.link
}

pred inv9_correct_11[] {
link.link = none -> none
}

pred inv9_correct_12[] {
all l : File.link |
no l.link
}

pred inv9_correct_13[] {
all f1, f2 : File | no f1.link & f2.~link
}

pred inv9_correct_14[] {
all f:File, f2:f.link | no f2.link
}

pred inv9_correct_15[] {
all f: File.link | no f.link
}

pred inv9_correct_16[] {
all f,g: File | f->g in link implies no g.link
}

pred inv9_correct_17[] {
all f : File | some f.link implies no link.f
}

pred inv9_correct_18[] {
no link.File & File.link
}

pred inv9_correct_19[] {
all l1:File.link | l1.link = none
}

pred inv9_correct_20[] {
all f1,f2,f3: File | f1->f2 in link implies f2->f3 not in link
}

pred inv9_correct_21[] {
all f1,f2 : univ | f1->f2 in link implies no f2.link
}

pred inv9_correct_22[] {
all l: File.link, l2: l.link | l2 not in File.link
}

pred inv9_correct_23[] {
all f : File | some f.link implies no f.link.link
}

