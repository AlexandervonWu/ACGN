sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000583 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap000583c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000583 { cap000583 iff cap000583c }
check CapBenchEquivalent_cap000583 for 4
