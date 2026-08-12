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

pred cap000091 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap000091c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000091 { cap000091 iff cap000091c }
check CapBenchEquivalent_cap000091 for 4
