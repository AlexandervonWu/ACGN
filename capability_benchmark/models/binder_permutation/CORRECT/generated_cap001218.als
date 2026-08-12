sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001218 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
pred cap001218c { all a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap001218 { cap001218 iff cap001218c }
check CapBenchEquivalent_cap001218 for 4
