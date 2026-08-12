sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File | f not in Protected implies f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000194 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
pred cap000194c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000194 { cap000194 iff cap000194c }
check CapBenchEquivalent_cap000194 for 4
