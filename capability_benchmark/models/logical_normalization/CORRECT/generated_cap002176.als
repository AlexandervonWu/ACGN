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

pred cap002176 { ((inv5 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) implies ((some capBenchS or no CapBenchB) or some capBenchS)) }
pred cap002176c { ((not (inv5 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) or ((some capBenchS or no CapBenchB) or some capBenchS)) }
assert CapBenchEquivalent_cap002176 { cap002176 iff cap002176c }
check CapBenchEquivalent_cap002176 for 4
