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

pred cap002426 { not not ((inv5 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002426c { (inv5 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002426 { cap002426 iff cap002426c }
check CapBenchEquivalent_cap002426 for 4
