sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap000042 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap000042c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap000042 { cap000042 iff cap000042c }
check CapBenchEquivalent_cap000042 for 4
