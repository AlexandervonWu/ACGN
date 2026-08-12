sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005267 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((no CapBenchB or some CapBenchB) and some capBenchR)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005267c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((no CapBenchB or some CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap005267 { cap005267 iff cap005267c }
check CapBenchEquivalent_cap005267 for 4
