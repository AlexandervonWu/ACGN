module alloy4fun_augmented_trash_fol_inv10
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
all f, g : File | (f->g in link and f in Trash) implies g in Trash
}

pred inv10_correct_1[] {
all f1, f2 : File | f1 -> f2 in link and f1 in Trash => f2 in Trash
}

pred inv10_correct_2[] {
all f:File, t:Trash | t->f in link implies f in Trash
}

pred inv10_correct_3[] {
Trash.link in Trash
}

pred inv10_correct_4[] {
all f : File | (all l : f.link | f in Trash implies l in Trash)
}

pred inv10_correct_5[] {
all f1, f2 : File | f1 in Trash and f1 -> f2 in link implies f2 in Trash
}

pred inv10_correct_6[] {
all f, l : File | (f->l in link and f in Trash) implies l in Trash
}

pred inv10_correct_7[] {
all f:Trash,g:File | f->g in link implies g in Trash
}

pred inv10_correct_8[] {
all x, y : File | x->y in link and x in Trash implies y in Trash
}

pred inv10_correct_9[] {
all f : File, l : f.link | f in Trash implies l in Trash
}

pred inv10_correct_10[] {
all l, f : File | (l->f in link) and (l in Trash) => (f in Trash)
}

pred inv10_correct_11[] {
all x : Trash, y : File | x->y in link implies y in Trash
}

pred inv10_correct_12[] {
all f1,f2 : File | isLink[f1] and f1->f2 in link and f1 in Trash implies f2 in Trash
}

pred inv10_correct_13[] {
all f:Trash | f.link in Trash
}

pred inv10_correct_14[] {
all f,x:File | f in Trash and f->x  in link implies x in Trash
}

pred inv10_correct_15[] {
all f,b : File | (f->b in link and f in Trash) implies b in Trash
}

pred inv10_correct_16[] {
all t:Trash | all f:File | t->f in link implies f in Trash
}

pred inv10_correct_17[] {
not some f1,f2 : File | f1->f2 in link and f1 in Trash and not f2 in Trash
}

pred inv10_correct_18[] {
all f: link.File | (f in Trash) implies (f.link in Trash)
}

pred inv10_correct_19[] {
all l1, l2 : File | (l1->l2 in link && l1 in Trash) => l2 in Trash
}

pred inv10_correct_20[] {
all f,lkd : File | (f in Trash and f->lkd in link) implies lkd in Trash
}

pred inv10_correct_21[] {
(all t,u : File | t->u in link and t in Trash implies u in Trash)
}

pred inv10_correct_22[] {
all x : Trash | all y : File | x->y in link implies y in Trash
}

pred inv10_correct_23[] {
all x : File, y : File | x -> y in link and x in Trash implies y in Trash
}

pred inv10_correct_24[] {
all t:Trash,f:File | t->f in link implies f in Trash
}

pred inv10_correct_25[] {
all f,l : File | (l in f.link and f in Trash) implies l in Trash
}

