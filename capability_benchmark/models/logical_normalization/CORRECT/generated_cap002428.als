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

pred cap002428 { ((inv2 and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) implies ((some CapBenchB or no CapBenchB) or some CapBenchB)) }
pred cap002428c { ((not (inv2 and ((some capBenchR and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) or ((some CapBenchB or no CapBenchB) or some CapBenchB)) }
assert CapBenchEquivalent_cap002428 { cap002428 iff cap002428c }
check CapBenchEquivalent_cap002428 for 4
