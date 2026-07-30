sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
all f1,f2 : File | (isLink[f1] and f1->f2 in link) implies not isLink[f2]
}

pred isLink[f1:File]{
some f2 : File | f1->f2 in link
}


pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

