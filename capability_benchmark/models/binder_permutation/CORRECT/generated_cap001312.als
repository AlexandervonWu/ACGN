sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001312 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap001312c { all a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap001312 { cap001312 iff cap001312c }
check CapBenchEquivalent_cap001312 for 4
