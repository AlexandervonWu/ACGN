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

pred cap004678 { not ((inv5 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) }
pred cap004678c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) or (not (inv5 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004678 { cap004678 iff cap004678c }
check CapBenchEquivalent_cap004678 for 4
