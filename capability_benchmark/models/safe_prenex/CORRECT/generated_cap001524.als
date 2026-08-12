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

pred cap001524 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((some CapBenchA and no CapBenchB) or some CapBenchA))) }
pred cap001524c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchA and no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001524 { cap001524 iff cap001524c }
check CapBenchEquivalent_cap001524 for 4
