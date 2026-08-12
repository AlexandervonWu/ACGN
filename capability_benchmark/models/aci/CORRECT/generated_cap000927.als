sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File = Trash
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

pred cap000927 { ((inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) or ((some CapBenchA and no CapBenchB) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)) }
pred cap000927c { (((some CapBenchA and no CapBenchB) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR) or (inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000927 { cap000927 iff cap000927c }
check CapBenchEquivalent_cap000927 for 4
