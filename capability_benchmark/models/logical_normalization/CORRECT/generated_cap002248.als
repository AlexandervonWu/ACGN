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

pred cap002248 { ((inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) implies ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002248c { ((not (inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) or ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002248 { cap002248 iff cap002248c }
check CapBenchEquivalent_cap002248 for 4
