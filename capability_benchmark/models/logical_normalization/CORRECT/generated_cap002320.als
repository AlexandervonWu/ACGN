sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File| f not in Protected => f in Trash
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

pred cap002320 { ((inv5 and ((some CapBenchA and some CapBenchA) or some capBenchS)) implies ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002320c { ((not (inv5 and ((some CapBenchA and some CapBenchA) or some capBenchS))) or ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002320 { cap002320 iff cap002320c }
check CapBenchEquivalent_cap002320 for 4
