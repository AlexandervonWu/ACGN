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

pred cap000088 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
pred cap000088c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv3 and ((some CapBenchA and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000088 { cap000088 iff cap000088c }
check CapBenchEquivalent_cap000088 for 4
