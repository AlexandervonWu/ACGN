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

pred cap002660 { not (((inv3 and ((some CapBenchA and some capBenchR) or no CapBenchA))) until (((some capBenchS or some CapBenchB) or some capBenchS))) }
pred cap002660c { ((not (inv3 and ((some CapBenchA and some capBenchR) or no CapBenchA))) releases (not ((some capBenchS or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002660 { cap002660 iff cap002660c }
check CapBenchEquivalent_cap002660 for 4
