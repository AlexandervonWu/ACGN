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

pred cap005093 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB)) and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
pred cap005093c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchB) and some capBenchR)) or (not (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005093 { cap005093 iff cap005093c }
check CapBenchEquivalent_cap005093 for 4
