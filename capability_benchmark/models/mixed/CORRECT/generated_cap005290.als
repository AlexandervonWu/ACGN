sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv10 {
all f1, f2 : File | (f1->f2 in link and f1 in Trash) => f2 in Trash
}

pred inv10c {
	all f : File | f in Trash implies f.link in Trash
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005290 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv10 and ((no CapBenchA and some capBenchR) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005290c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv10 and ((no CapBenchA and some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap005290 { cap005290 iff cap005290c }
check CapBenchEquivalent_cap005290 for 4
