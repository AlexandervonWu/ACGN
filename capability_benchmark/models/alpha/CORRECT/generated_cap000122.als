sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all p : Protected | p  not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000122 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap000122c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000122 { cap000122 iff cap000122c }
check CapBenchEquivalent_cap000122 for 4
