sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004117 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap004117c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap004117 { cap004117 iff cap004117c }
check CapBenchEquivalent_cap004117 for 4
