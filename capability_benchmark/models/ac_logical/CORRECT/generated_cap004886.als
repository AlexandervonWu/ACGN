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

pred cap004886 { not ((inv3 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) }
pred cap004886c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) or (not (inv3 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004886 { cap004886 iff cap004886c }
check CapBenchEquivalent_cap004886 for 4
