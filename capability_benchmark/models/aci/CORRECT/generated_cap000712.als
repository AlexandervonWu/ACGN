sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap000712 { (inv8 and ((some capBenchR and no CapBenchA) or no CapBenchB)) }
pred cap000712c { ((inv8 and ((some capBenchR and no CapBenchA) or no CapBenchB)) and (inv8 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000712 { cap000712 iff cap000712c }
check CapBenchEquivalent_cap000712 for 4
