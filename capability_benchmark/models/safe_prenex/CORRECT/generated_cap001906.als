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

pred cap001906 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001906c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001906 { cap001906 iff cap001906c }
check CapBenchEquivalent_cap001906 for 4
