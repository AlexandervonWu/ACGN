sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003052 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some CapBenchB or some capBenchR) or no CapBenchB)) }
pred cap003052c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap003052 { cap003052 iff cap003052c }
check CapBenchEquivalent_cap003052 for 4
