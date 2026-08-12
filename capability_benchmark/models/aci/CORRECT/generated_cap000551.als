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

pred cap000551 { (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap000551c { ((inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap000551 { cap000551 iff cap000551c }
check CapBenchEquivalent_cap000551 for 4
