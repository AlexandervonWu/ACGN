sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002158 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) implies ((no CapBenchB or some CapBenchB) and some capBenchS)) }
pred cap002158c { ((not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) or ((no CapBenchB or some CapBenchB) and some capBenchS)) }
assert CapBenchEquivalent_cap002158 { cap002158 iff cap002158c }
check CapBenchEquivalent_cap002158 for 4
