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

pred cap003129 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) }
pred cap003129c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003129 { cap003129 iff cap003129c }
check CapBenchEquivalent_cap003129 for 4
