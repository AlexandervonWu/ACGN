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

pred cap003379 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((some CapBenchA and some capBenchS) or some CapBenchA)) }
pred cap003379c { all renamed: CapBenchA | (((some CapBenchA and some capBenchS) or some CapBenchA) and renamed->renamed in capBenchR and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003379 { cap003379 iff cap003379c }
check CapBenchEquivalent_cap003379 for 4
