sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
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

pred cap000099 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap000099c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv8 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap000099 { cap000099 iff cap000099c }
check CapBenchEquivalent_cap000099 for 4
