module alloy4fun_augmented_trash_fol_inv8
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
all f:File | #(f.link) = 0
}

pred inv8_correct_1[] {
all f1,f2:File | f1->f2 not in link
}

pred inv8_correct_2[] {
all x, y : File | x->y not in link
}

pred inv8_correct_3[] {
all f,t : File |f->t not in link
}

pred inv8_correct_4[] {
(all t,u : File | t->u not in link)
}

pred inv8_correct_5[] {
all f, l : File | f->l not in link
}

pred inv8_correct_6[] {
all f:File | no f.link
}

pred inv8_correct_7[] {
all f,g: File | f->g not in link
}

pred inv8_correct_8[] {
all f:File | not isLinked[f]
}

pred inv8_correct_9[] {
not some f1,f2 : File | f1->f2 in link
}

pred inv8_correct_10[] {
all x: File, y: File | x->y not in link
}

pred inv8_correct_11[] {
all f : File | all lkd : File | f->lkd not in link
}

pred inv8_correct_12[] {
all f:File | not isLink[f]
}

pred inv8_correct_13[] {
all f : File | not is_link[f]
}

pred inv8_correct_14[] {
no File.link
}

pred inv8_correct_15[] {
all f1,f2: File | not f1 -> f2 in link
}

pred inv8_correct_16[] {
all g:File | not isLink[g]
}

pred inv8_correct_17[] {
all f:File | f.link=none
}

pred inv8_correct_18[] {
no link.File
}

pred inv8_correct_19[] {
all f,x : File | f->x not in link
}

pred inv8_correct_20[] {
all f : File | all l : f.link | no l
}

pred inv8_correct_21[] {
not some l, f : File | l->f in link
}

pred inv8_correct_22[] {
all l : File.link | no l
}

pred inv8_correct_23[] {
(all t,y : File | t->y not in link)
}

pred inv8_correct_24[] {
all f, f1 : File | f->f1 not in link
}

pred inv8_correct_25[] {
all f:File | #(f.link) <= 0
}

pred inv8_correct_26[] {
all x: File | not isLink[x]
}

pred inv8_correct_27[] {
no f1,f2:File | f1->f2 in link
}

pred inv8_correct_28[] {
all x: File | not isLinked[x]
}

pred inv8_correct_29[] {
not (some f1 : File, f2 : File | f1->f2 in link)
}

pred inv8_correct_30[] {
no f:File | f in File.link
}

pred inv8_correct_31[] {
all x : File | all y : File | x->y not in link
}

pred inv8_correct_32[] {
all f,lkd : File| f->lkd not in link
}

