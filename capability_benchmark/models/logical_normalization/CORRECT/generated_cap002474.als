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

pred cap002474 { not not ((inv1 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002474c { (inv1 and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002474 { cap002474 iff cap002474c }
check CapBenchEquivalent_cap002474 for 4
