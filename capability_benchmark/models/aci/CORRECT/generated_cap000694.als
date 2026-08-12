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

pred cap000694 { (inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB)) }
pred cap000694c { ((inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB)) and (inv1 and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000694 { cap000694 iff cap000694c }
check CapBenchEquivalent_cap000694 for 4
