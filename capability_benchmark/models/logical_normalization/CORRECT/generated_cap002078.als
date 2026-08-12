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

pred cap002078 { not not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB))) }
pred cap002078c { (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) }
assert CapBenchEquivalent_cap002078 { cap002078 iff cap002078c }
check CapBenchEquivalent_cap002078 for 4
