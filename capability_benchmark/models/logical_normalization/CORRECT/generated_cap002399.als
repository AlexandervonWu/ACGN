sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
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

pred cap002399 { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) iff ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap002399c { (((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002399 { cap002399 iff cap002399c }
check CapBenchEquivalent_cap002399 for 4
