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

pred cap000529 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
pred cap000529c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000529 { cap000529 iff cap000529c }
check CapBenchEquivalent_cap000529 for 4
