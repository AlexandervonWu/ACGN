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

pred cap000989 { (inv3 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000989c { ((inv3 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) or (inv3 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000989 { cap000989 iff cap000989c }
check CapBenchEquivalent_cap000989 for 4
