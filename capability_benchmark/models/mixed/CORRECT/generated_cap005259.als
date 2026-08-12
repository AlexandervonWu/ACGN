sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
no link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005259 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchB or some CapBenchA) and some capBenchR)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005259c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((no CapBenchB or some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap005259 { cap005259 iff cap005259c }
check CapBenchEquivalent_cap005259 for 4
