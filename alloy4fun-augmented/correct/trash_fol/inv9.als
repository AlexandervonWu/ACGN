module alloy4fun_augmented_trash_fol_inv9
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
all f, l, k : File | f->l in link implies l->k not in link
}

pred inv9_correct_1[] {
all f1, f2 : File | f1->f2 in link => not some f3:File | f2->f3 in link
}

pred inv9_correct_2[] {
all f,g,h:File | f->g in link implies g->h not in link
}

pred inv9_correct_3[] {
all f1, f2, f3 : File | f1->f2 in link implies f2->f3 not in link
}

pred inv9_correct_4[] {
all x : File, y, t : File | x -> y in link implies y -> t not in link
}

pred inv9_correct_5[] {
all f:File| no f.link.link
}

pred inv9_correct_6[] {
all f : File | (all l : f.link | no l.link)
}

pred inv9_correct_7[] {
all f:File | some link.f implies no f.link
}

pred inv9_correct_8[] {
all l : File.link | no l.link
}

pred inv9_correct_9[] {
not some f1,f2,f3: File | f1->f2 in link and f2->f3 in link
}

pred inv9_correct_10[] {
all f,x,y:File | f->x in link implies x->y not in link
}

pred inv9_correct_11[] {
all x,y,z : File | x->y in link implies y->z not in link
}

pred inv9_correct_12[] {
all f1,f2:File | is_link[f1] and is_link[f2] implies f1->f2 not in link
}

pred inv9_correct_13[] {
all f,g,h:File| f->g in link implies not g->h in link
}

pred inv9_correct_14[] {
all f1: File | all f2 : f1.link | no f2.link
}

pred inv9_correct_15[] {
(all t,u,x : File | t->u in link implies u->x not in link)
}

pred inv9_correct_16[] {
all f,l1,l2 : File | f->l1 in link  implies l1->l2 not in link
}

pred inv9_correct_17[] {
all f1, f2, f3 : File | not (f1 -> f2 in link && f2 -> f3 in link)
}

pred inv9_correct_18[] {
all f,lkdf1,lkdf2 : File | f->lkdf1 in link implies lkdf1->lkdf2 not in link
}

pred inv9_correct_19[] {
all f,g : File | isLinked[f] and isLinked[g] implies f->g not in link
}

pred inv9_correct_20[] {
all x : File , y : File , z : File | x->y in link implies y->z not in link
}

pred inv9_correct_21[] {
all f1,f2 : File | f1->f2 in link implies not is_link[f2]
}

pred inv9_correct_22[] {
all x, y, z : File | x->y in link implies z->x not in link
}

pred inv9_correct_23[] {
all f1,f2 : File | (isLink[f1] and f1->f2 in link) implies not isLink[f2]
}

pred inv9_correct_24[] {
all l : File.link | (#l.link)=0
}

pred inv9_correct_25[] {
all f,g:File | isLink[f] and isLink[g] implies f->g not in link
}

pred inv9_correct_26[] {
all f1, f2:File | f2 in f1.link implies no f2.link
}

pred inv9_correct_27[] {
all f,u,t: File |f->t in link implies t->u not in link
}

pred inv9_correct_28[] {
all f1, f2:File | f1 -> f2 in link implies all f3:File | f2->f3 not in link
}

pred inv9_correct_29[] {
(all t,u : File| all x : File | t->u in link implies u->x not in link)
}

pred inv9_correct_30[] {
all f1,f2,f3:File | f1->f2 in link implies f3->f1 not in link
}

pred inv9_correct_31[] {
all f1, f2, f3 : File | f1->f2 in link implies f1 != f2 and f2->f3 not in link
}

pred inv9_correct_32[] {
no f,f2:File | f in File.link and f2 in f.link
}

pred inv9_correct_33[] {
all f, f1, f2 : File | (f->f1).(f1->f2) not in link.link
}

pred inv9_correct_34[] {
all f1,f2,f3:File | f1 -> f2 in link implies not f2 -> f3 in link
}

pred inv9_correct_35[] {
not some l1, l2, l3 : File | l1->l2 in link && l2->l3 in link
}

pred inv9_correct_36[] {
all f : File | all l : f.link | (#l.link)=0
}

pred inv9_correct_37[] {
all f1,f2:File | f1->f2 in link implies f2.link=none
}

pred inv9_correct_38[] {
no File.link.link
}

pred inv9_correct_39[] {
all x,y : File | x->y in link implies all z : File | y->z not in link
}

pred inv9_correct_40[] {
all f1,f2:File | isLinked[f1] implies f1->f2 not in link
}

pred inv9_correct_41[] {
all f1,f2:File | f1->f2 in link implies no f3:File | f2->f3 in link
}

pred inv9_correct_42[] {
not some l1, l2, f : File | (l1->l2 in link) and (l2->f in link)
}

pred inv9_correct_43[] {
all x : File | all y,z : File | x->y in link implies y->z not in link
}

