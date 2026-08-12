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

pred cap005238 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005238c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005238 { cap005238 iff cap005238c }
check CapBenchEquivalent_cap005238 for 4
