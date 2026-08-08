module alloy4fun_augmented_trash_fol_inv7
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7_oracle[] {
no File.link & Trash
}

pred inv7_correct_0[] {
all f,l : File | f->l in link implies l not in Trash
}

pred inv7_correct_1[] {
all f1,f2 : File | f1->f2 in link implies f2 not in Trash
}

pred inv7_correct_2[] {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
}

pred inv7_correct_3[] {
all f:File | isLink[f] implies f not in Trash
}

pred inv7_correct_4[] {
all f:File | isLinked[f] implies f not in Trash
}

pred inv7_correct_5[] {
(all t,u : File | t->u in link implies u not in Trash)
}

pred inv7_correct_6[] {
all f1 : File, f2 : File | f1->f2 in link implies f2 not in Trash
}

pred inv7_correct_7[] {
no link.Trash
}

pred inv7_correct_8[] {
all f : File | no (f.link & Trash)
}

pred inv7_correct_9[] {
all x : File, y : File | x -> y in link implies y not in Trash
}

pred inv7_correct_10[] {
all l : File.link | l not in Trash
}

pred inv7_correct_11[] {
all f : File | is_linked[f] implies f not in Trash
}

pred inv7_correct_12[] {
all f : File, l : f.link | l not in Trash
}

pred inv7_correct_13[] {
all f,g : File | f->g in link implies g not in Trash
}

pred inv7_correct_14[] {
all f : File  | (all l : f.link | l not in Trash)
}

pred inv7_correct_15[] {
all f,x : File | f->x in link implies x not in Trash
}

pred inv7_correct_16[] {
all x, y : File | x -> y in link implies y not in Trash
}

pred inv7_correct_17[] {
no (File & File.link & Trash)
}

pred inv7_correct_18[] {
all f,t : File | f->t in link implies t not in Trash
}

pred inv7_correct_19[] {
not some f1,f2: File | f1->f2 in link and f2 in Trash
}

pred inv7_correct_20[] {
all f1,f2:File | f1->f2 in link => not f2 in Trash
}

pred inv7_correct_21[] {
all x : File | isLinked[x] implies x not in Trash
}

pred inv7_correct_22[] {
all x : File | all y : File | x->y in link implies y not in Trash
}

pred inv7_correct_23[] {
all f:File | some link.f implies f not in Trash
}

pred inv7_correct_24[] {
all f:File | f.link & Trash = none
}

pred inv7_correct_25[] {
all f1,f2:File | f1 in f2.link implies f1 not in Trash
}

pred inv7_correct_26[] {
no f:File | f in File.link and f in Trash
}

pred inv7_correct_27[] {
all f : File.link | f not in Trash
}

pred inv7_correct_28[] {
all f:File | f in Trash implies no f2:File | f2->f in link
}

pred inv7_correct_29[] {
all f, f1: File | f->f1 in link implies f1 not in Trash
}

pred inv7_correct_30[] {
not some l, f : File | (l->f in link) and (f in Trash)
}

pred inv7_correct_31[] {
all f,l:File | (l in f.link) implies l not in Trash
}

