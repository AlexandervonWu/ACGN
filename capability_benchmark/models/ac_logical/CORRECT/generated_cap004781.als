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

pred cap004781 { not ((inv3 and ((some CapBenchB or no CapBenchB) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004781c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004781 { cap004781 iff cap004781c }
check CapBenchEquivalent_cap004781 for 4
