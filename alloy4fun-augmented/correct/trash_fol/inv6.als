module alloy4fun_augmented_trash_fol_inv6
/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6_oracle[] {
link in File -> lone File
}

pred inv6_correct_0[] {
all f1, f2, f3 : File | f1->f2 in link and f1->f3 in link implies f2=f3
}

pred inv6_correct_1[] {
~link.link in iden
}

pred inv6_correct_2[] {
all f, f1, f2 : File | f->f1 + f->f2 in link implies f1 = f2
}

pred inv6_correct_3[] {
all f:File, a,b:File | f->a in link and f->b in link implies a=b
}

pred inv6_correct_4[] {
all f,g,h : File | f->g in link and f->h in link implies g=h
}

pred inv6_correct_5[] {
all f:File | lone f.link
}

pred inv6_correct_6[] {
all f : File | #(f.link) < 2
}

pred inv6_correct_7[] {
all x,y,z : File | (x->y in link and x->z in link) implies y=z
}

pred inv6_correct_8[] {
all x,y,z : File | (x->y in link and x->z in link) implies z=y
}

pred inv6_correct_9[] {
all f, f1, f2 : File | f->f1 in link and f -> f2 in link => f1 = f2
}

pred inv6_correct_10[] {
all x : File, y, z : File | x->y in link and x->z in link implies y=z
}

pred inv6_correct_11[] {
all f,lk1,lk2 : File | f->lk1 in link and f->lk2 in link implies lk1=lk2
}

pred inv6_correct_12[] {
(all t,u,v : File | (t->u in link and t->v in link) implies u=v)
}

pred inv6_correct_13[] {
all f1:File,f2:File,f3:File | f1->f2 in link and f1->f3 in link implies f2=f3
}

pred inv6_correct_14[] {
all f,l,u : File | f->l in link and f->u in link implies l = u
}

pred inv6_correct_15[] {
all f : File, t,u : File  |f->t in link and f->u in link implies t=u
}

pred inv6_correct_16[] {
all f: File | all f1, f2: File | f->f1 in link and f->f2 in link implies f1=f2
}

pred inv6_correct_17[] {
all f, l, k : File | f->l in link and f->k in link implies l=k
}

pred inv6_correct_18[] {
all f: File | #f.link =< 1
}

pred inv6_correct_19[] {
all f1,f2,f3 : File | (f1->f2 in link && f1->f3 in link) => f3 = f2
}

pred inv6_correct_20[] {
all f : File, lk1,lk2 : File | f->lk1 in link and f->lk2 in link implies lk1=lk2
}

pred inv6_correct_21[] {
all f1,f2,f3:File | f2 in f1.link and f3 in f1.link implies f3=f2
}

pred inv6_correct_22[] {
all x : File | all y : File | all z : File | x->y in link and x->z in link implies y=z
}

pred inv6_correct_23[] {
all l, f1, f2 : File | (l->f1 in link) and (l->f2 in link) => f1 = f2
}

pred inv6_correct_24[] {
all f,g,z:File | f->g in link and f->z in link implies g = z
}

pred inv6_correct_25[] {
all f,x,y:File | f ->x in link and f -> y in link implies x=y
}

pred inv6_correct_26[] {
(all t,u,x : File | t->u in link and t->x in link implies u=x)
}

pred inv6_correct_27[] {
all x : File, t, u : File | x -> t in link and x -> u in link implies t = u
}

pred inv6_correct_28[] {
all f,t,u : File |f->t in link and f->u in link implies t=u
}

pred inv6_correct_29[] {
all x,y : File | x->y not in link or all z : File | x->y in link and x->z in link implies y=z
}

pred inv6_correct_30[] {
all f,a1,a2 : File |
f->a1 in link and f->a2 in link implies a1=a2
}

