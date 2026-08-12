sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
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

pred cap000552 { (some ((CapBenchA.capBenchR).capBenchR) and (inv8 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap000552c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv8 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap000552 { cap000552 iff cap000552c }
check CapBenchEquivalent_cap000552 for 4
