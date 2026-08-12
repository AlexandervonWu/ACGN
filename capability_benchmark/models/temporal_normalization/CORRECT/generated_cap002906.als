sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
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

pred cap002906 { not (((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) until (((no CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap002906c { ((not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) releases (not ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002906 { cap002906 iff cap002906c }
check CapBenchEquivalent_cap002906 for 4
