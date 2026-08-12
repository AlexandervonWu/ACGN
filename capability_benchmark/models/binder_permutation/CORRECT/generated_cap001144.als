sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001144 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
pred cap001144c { all a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001144 { cap001144 iff cap001144c }
check CapBenchEquivalent_cap001144 for 4
