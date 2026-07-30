sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
all f,g:File | isLink[f] and isLink[g] implies f->g not in link
}

pred isLink (f:File){
some g:File | f->g in link
}

/* If a link is deleted, so is the file it links to. */

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

