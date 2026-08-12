sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
all f,lk1 : File | f->lk1 in link implies lk1 not in Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002361 { not ((inv7 and ((some CapBenchB or some capBenchS) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) }
pred cap002361c { ((not (inv7 and ((some CapBenchB or some capBenchS) or some capBenchS))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002361 { cap002361 iff cap002361c }
check CapBenchEquivalent_cap002361 for 4
