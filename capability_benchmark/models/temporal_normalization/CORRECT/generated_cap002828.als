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

pred cap002828 { not (((inv8 and ((some CapBenchA and some CapBenchB) or some capBenchS))) until (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002828c { ((not (inv8 and ((some CapBenchA and some CapBenchB) or some capBenchS))) releases (not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002828 { cap002828 iff cap002828c }
check CapBenchEquivalent_cap002828 for 4
