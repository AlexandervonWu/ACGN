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

pred cap001855 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((no CapBenchB or some capBenchR) and some capBenchS))) }
pred cap001855c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((no CapBenchB or some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap001855 { cap001855 iff cap001855c }
check CapBenchEquivalent_cap001855 for 4
