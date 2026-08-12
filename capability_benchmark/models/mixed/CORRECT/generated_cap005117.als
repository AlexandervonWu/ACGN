sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
all f:File | f in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005117 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap005117c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchR) and some capBenchR)) or (not (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005117 { cap005117 iff cap005117c }
check CapBenchEquivalent_cap005117 for 4
