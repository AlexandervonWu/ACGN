sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004930 { not ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or no CapBenchB) and some CapBenchB)) }
pred cap004930c { ((not ((no CapBenchB or no CapBenchB) and some CapBenchB)) or (not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004930 { cap004930 iff cap004930c }
check CapBenchEquivalent_cap004930 for 4
