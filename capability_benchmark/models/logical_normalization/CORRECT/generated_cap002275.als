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

pred cap002275 { no x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap002275c { all x: CapBenchA | not (x->x in capBenchR and (inv5 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002275 { cap002275 iff cap002275c }
check CapBenchEquivalent_cap002275 for 4
