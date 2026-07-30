module alloy4fun_augmented_trash_rl_inv6
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
~link . link in iden
}

pred inv6_correct_1[] {
all f : File | lone f.link
}

pred inv6_correct_2[] {
all f: File | #f.link<2
}

pred inv6_correct_3[] {
all x : File | lone x.link
}

pred inv6_correct_4[] {
all l,f1,f2 : File | l->f1 in link and l->f2 in link implies f1 = f2
}

pred inv6_correct_5[] {
all file: File |  lone file.link
}

pred inv6_correct_6[] {
all f1, f2, f3:File | f1->f2 in link and f1->f3 in link => f2=f3
}

pred inv6_correct_7[] {
all f, f1, f2 : File | f->f1 + f->f2 in link => f1 = f2
}

pred inv6_correct_8[] {
all f,g,h:File | f->g in link and f->h in link implies g=h
}

pred inv6_correct_9[] {
all f1: File | lone f2: File | f2 in f1.link
}

pred inv6_correct_10[] {
all f: File | #(f.link) < 2
all f1,f2,f3: File | f1->f2 in link && f1->f3 in link implies f2=f3
}

pred inv6_correct_11[] {
all f : File | lone f<:link
}

pred inv6_correct_12[] {
all f: File | lone l: File | l in f.link
}

pred inv6_correct_13[] {
all f,f1,f2 : File | f->f1 + f->f2 in link implies f1=f2



all f : File | lone f.link
}

pred inv6_correct_14[] {
all f1, f2, f3: File | f2 in f1.link and f3 in f1.link implies f2 = f3
}

pred inv6_correct_15[] {
all f,f1,f2 : univ | f->f1 in link and f->f2 in link implies f1=f2
}

pred inv6_correct_16[] {
all f,f1,f2:File | f->f2 in link and f->f1 in link implies f1=f2
}

