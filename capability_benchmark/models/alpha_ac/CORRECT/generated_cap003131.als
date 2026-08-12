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

pred cap003131 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchA)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap003131c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003131 { cap003131 iff cap003131c }
check CapBenchEquivalent_cap003131 for 4
