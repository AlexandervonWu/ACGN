sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv6 {
~link . link in iden
}

pred inv6c {
	link in File -> lone File
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000727 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv6 and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap000727c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv6 and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap000727 { cap000727 iff cap000727c }
check CapBenchEquivalent_cap000727 for 4
