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

pred cap000692 { ((inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchB)) and ((some capBenchS or some capBenchS) or some capBenchS) and ((no CapBenchB or no CapBenchB) and some CapBenchA)) }
pred cap000692c { (((no CapBenchB or no CapBenchB) and some CapBenchA) and (inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchB)) and ((some capBenchS or some capBenchS) or some capBenchS)) }
assert CapBenchEquivalent_cap000692 { cap000692 iff cap000692c }
check CapBenchEquivalent_cap000692 for 4
