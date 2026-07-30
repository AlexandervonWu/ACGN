sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
all e1,e2 : univ, f : File | e1->f in link and e2->f in link implies e1 = e2
all f1,f2 : File, l : univ | f1->l in link and f2->l in link implies f1 = f2
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 

