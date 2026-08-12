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

pred cap003216 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB)) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003216c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003216 { cap003216 iff cap003216c }
check CapBenchEquivalent_cap003216 for 4
