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

pred cap000257 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap000257c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv8 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000257 { cap000257 iff cap000257c }
check CapBenchEquivalent_cap000257 for 4
