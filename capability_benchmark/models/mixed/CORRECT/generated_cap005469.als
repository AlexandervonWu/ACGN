sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005469 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
pred cap005469c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and no CapBenchA)) or (not (inv7 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005469 { cap005469 iff cap005469c }
check CapBenchEquivalent_cap005469 for 4
