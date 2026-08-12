sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all f : File | f in Protected implies f not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004979 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and some CapBenchB) or no CapBenchA)) }
pred cap004979c { ((not ((some capBenchR and some CapBenchB) or no CapBenchA)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004979 { cap004979 iff cap004979c }
check CapBenchEquivalent_cap004979 for 4
