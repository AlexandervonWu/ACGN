sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
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

pred cap005009 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap005009c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv5 and ((some CapBenchB or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005009 { cap005009 iff cap005009c }
check CapBenchEquivalent_cap005009 for 4
