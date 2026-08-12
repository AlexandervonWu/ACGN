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

pred cap004614 { not ((inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) }
pred cap004614c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) or (not (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004614 { cap004614 iff cap004614c }
check CapBenchEquivalent_cap004614 for 4
