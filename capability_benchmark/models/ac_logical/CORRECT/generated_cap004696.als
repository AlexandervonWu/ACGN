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

pred cap004696 { not ((inv3 and ((some capBenchR and some CapBenchA) or no CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap004696c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) or (not (inv3 and ((some capBenchR and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004696 { cap004696 iff cap004696c }
check CapBenchEquivalent_cap004696 for 4
