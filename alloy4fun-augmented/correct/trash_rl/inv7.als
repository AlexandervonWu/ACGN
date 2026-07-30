module alloy4fun_augmented_trash_rl_inv7
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
all f : File | f.link in (File - Trash)
}

pred inv7_correct_1[] {
all f:File | no f.link & Trash
}

pred inv7_correct_2[] {
not some f1, f2:File | (f1->f2 in link) and (f2 in Trash)
}

pred inv7_correct_3[] {
no link.Trash
}

pred inv7_correct_4[] {
all f,l : univ | f->l in link implies l not in Trash
}

pred inv7_correct_5[] {
all f : File | some link.f => f not in Trash
}

pred inv7_correct_6[] {
all f : File | all f1 : f.link | f1 not in Trash


no File.link & Trash
}

pred inv7_correct_7[] {
all f,f1:File | f->f1 in link implies f1 not in Trash
}

pred inv7_correct_8[] {
all f : Trash | no link . f
}

pred inv7_correct_9[] {
all f:File, f2:f.link | not f2 in Trash
}

pred inv7_correct_10[] {
all f:File.link | f not in Trash
}

pred inv7_correct_11[] {
all t : Trash | no link.t
}

pred inv7_correct_12[] {
all f : File | no Trash & f.link
}

pred inv7_correct_13[] {
all l, f: File | l in f.link implies l not in Trash
}

pred inv7_correct_14[] {
all f : File, l : f.link | l not in Trash
}

pred inv7_correct_15[] {
no link & File->Trash
}

pred inv7_correct_16[] {
all f: File | no (f.^link & Trash)
}

pred inv7_correct_17[] {
no File.link & Trash

all f : File.link | f not in Trash
}

pred inv7_correct_18[] {
all l : File.link |
not (l in Trash)
}

pred inv7_correct_19[] {
File.link & Trash = none
}

pred inv7_correct_20[] {
all l: File.link | l not in Trash
}

pred inv7_correct_21[] {
all f: File | f in Trash => no link.f
}

pred inv7_correct_22[] {
all f : File |
all l : f.link |
l not in Trash
}

pred inv7_correct_23[] {
link.Trash = none
}

pred inv7_correct_24[] {
no f : File.link | f in Trash
}

pred inv7_correct_25[] {
all fl: File.link| fl not in Trash
}

pred inv7_correct_26[] {
Trash in Trash - File.link
}

pred inv7_correct_27[] {
all f1,f2: File | f1->f2 in link implies f2 not in Trash
}

pred inv7_correct_28[] {
all f1,f2: File | f1->f2 in link implies not f2 in Trash
}

pred inv7_correct_29[] {
all f : File, l : f.link |
not (l in Trash)
}

pred inv7_correct_30[] {
no l: File.link | l in Trash
}

pred inv7_correct_31[] {
no link :> Trash
}

pred inv7_correct_32[] {
no Trash & File.link
}

