sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
all f1,f2:File | is_link[f1] and is_link[f2] implies f1->f2 not in link
}

pred is_link[f : File]{
some g : File | f->g in link
}

/* There are no links. */

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

