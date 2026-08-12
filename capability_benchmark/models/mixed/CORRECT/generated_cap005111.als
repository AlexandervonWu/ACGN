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

pred cap005111 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) and ((some capBenchR and no CapBenchB) or some capBenchR))) }
pred cap005111c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchB) or some capBenchR)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005111 { cap005111 iff cap005111c }
check CapBenchEquivalent_cap005111 for 4
