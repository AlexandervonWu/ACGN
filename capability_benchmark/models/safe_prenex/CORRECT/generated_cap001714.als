sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001714 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
pred cap001714c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001714 { cap001714 iff cap001714c }
check CapBenchEquivalent_cap001714 for 4
