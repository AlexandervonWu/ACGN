module alloy4fun_augmented_trash_rl_inv10
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv10_oracle[] {
all f : File | f in Trash implies f.link in Trash
}

pred inv10_correct_0[] {
all f:Trash,g:File | f->g in link implies g in Trash
}

pred inv10_correct_1[] {
no link.(File-Trash) & Trash
}

pred inv10_correct_2[] {
(File & Trash).link in Trash
}

pred inv10_correct_3[] {
Trash.link in Trash
}

pred inv10_correct_4[] {
all f : Trash | f.link in Trash
}

pred inv10_correct_5[] {
all f : File, l : f.link | f in Trash implies l in Trash
}

pred inv10_correct_6[] {
all f: File | all fl : f.link |  (fl in Trash and f in Trash) or f not in Trash
}

pred inv10_correct_7[] {
all f : File | f in Trash implies f.link in Trash





Trash.link in Trash
}

pred inv10_correct_8[] {
all f:File | all f1:File | f->f1 in link and f in Trash implies f1 in Trash
}

pred inv10_correct_9[] {
all f : File | f in Trash implies f.^link in Trash
}

pred inv10_correct_10[] {
all f : File | all l : f.link | f in Trash implies l in Trash
}

pred inv10_correct_11[] {
all f : File | some f.link and f in Trash implies f.link in Trash
}

pred inv10_correct_12[] {
all t:Trash | t.link in Trash
}

pred inv10_correct_13[] {
let x = File & Trash | x.link in Trash
}

pred inv10_correct_14[] {
all f1,f2: File | f1->f2 in link and f1 in Trash implies f2 in Trash
}

pred inv10_correct_15[] {
all f1,f2 : univ | f1->f2 in link and f1 in Trash implies f2 in Trash
}

pred inv10_correct_16[] {
all l: Trash | l.link in Trash
}

pred inv10_correct_17[] {
all l, f : File | (l->f in link) and (l in Trash) => (f in Trash)
}

pred inv10_correct_18[] {
all f: Trash | f.^link in Trash
}

pred inv10_correct_19[] {
all f,f1:File | f->f1 in link and f in Trash implies f1 in Trash
}

pred inv10_correct_20[] {
Trash.^link in Trash
}

pred inv10_correct_21[] {
all t:Trash, f:File | t->f in link implies f in Trash
}

pred inv10_correct_22[] {
all disj f1, f2:File | f1->f2 in link and f1 in Trash => f2 in Trash
}

pred inv10_correct_23[] {
all f:File, f2:f.link | f in Trash => f2 in Trash
}

pred inv10_correct_24[] {
all x : Trash, y : File | x->y in link implies y in Trash
}

pred inv10_correct_25[] {
all w, f : File | (((w->f) in link) and (w in Trash)) implies f in Trash
}

