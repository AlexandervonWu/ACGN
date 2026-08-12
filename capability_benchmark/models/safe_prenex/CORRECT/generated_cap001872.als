sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
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

pred cap001872 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap001872c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap001872 { cap001872 iff cap001872c }
check CapBenchEquivalent_cap001872 for 4
