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

pred cap004631 { not ((inv3 and ((no CapBenchB or some CapBenchA) and no CapBenchA)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap004631c { ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv3 and ((no CapBenchB or some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004631 { cap004631 iff cap004631c }
check CapBenchEquivalent_cap004631 for 4
