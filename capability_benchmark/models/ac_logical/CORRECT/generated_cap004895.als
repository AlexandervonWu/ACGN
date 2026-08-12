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

pred cap004895 { not ((inv3 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap004895c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (not (inv3 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004895 { cap004895 iff cap004895c }
check CapBenchEquivalent_cap004895 for 4
