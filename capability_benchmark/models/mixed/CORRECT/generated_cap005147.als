sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File | f not in Protected implies f in Trash
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

pred cap005147 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((no CapBenchB or no CapBenchA) and no CapBenchA)) and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
pred cap005147c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchA) or some capBenchS)) or (not (inv5 and ((no CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005147 { cap005147 iff cap005147c }
check CapBenchEquivalent_cap005147 for 4
