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

pred cap003412 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some CapBenchB) or some CapBenchB)) }
pred cap003412c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003412 { cap003412 iff cap003412c }
check CapBenchEquivalent_cap003412 for 4
