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

pred cap002453 { ((inv5 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) iff ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap002453c { (((not (inv5 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) or (inv5 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002453 { cap002453 iff cap002453c }
check CapBenchEquivalent_cap002453 for 4
