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

pred cap003157 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA)) and ((no CapBenchA and some CapBenchB) and some capBenchS)) }
pred cap003157c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003157 { cap003157 iff cap003157c }
check CapBenchEquivalent_cap003157 for 4
