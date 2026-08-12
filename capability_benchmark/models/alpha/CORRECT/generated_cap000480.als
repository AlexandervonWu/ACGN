sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no File.link
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

pred cap000480 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000480c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000480 { cap000480 iff cap000480c }
check CapBenchEquivalent_cap000480 for 4
