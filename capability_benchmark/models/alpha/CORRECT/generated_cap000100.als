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

pred cap000100 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
pred cap000100c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap000100 { cap000100 iff cap000100c }
check CapBenchEquivalent_cap000100 for 4
