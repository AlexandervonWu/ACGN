sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap002870 { not (((inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) until (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap002870c { ((not (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) releases (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002870 { cap002870 iff cap002870c }
check CapBenchEquivalent_cap002870 for 4
