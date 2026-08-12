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

pred cap002282 { not not ((inv4 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap002282c { (inv4 and ((no CapBenchA and no CapBenchB) and some capBenchR)) }
assert CapBenchEquivalent_cap002282 { cap002282 iff cap002282c }
check CapBenchEquivalent_cap002282 for 4
