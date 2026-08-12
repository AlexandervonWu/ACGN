sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
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

pred cap000597 { ((inv4 and ((some CapBenchB or some capBenchR) or some CapBenchB)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000597c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or (inv4 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap000597 { cap000597 iff cap000597c }
check CapBenchEquivalent_cap000597 for 4
