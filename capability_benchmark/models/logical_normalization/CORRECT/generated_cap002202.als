sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap002202 { not (all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and some CapBenchB) and no CapBenchB)))) }
pred cap002202c { some x: CapBenchA | not (x->x in capBenchR and (inv3 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002202 { cap002202 iff cap002202c }
check CapBenchEquivalent_cap002202 for 4
