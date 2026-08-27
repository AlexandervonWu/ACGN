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

pred cap000636 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv3 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
pred cap000636c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv3 and ((some CapBenchA and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000636 { cap000636 iff cap000636c }
check CapBenchEquivalent_cap000636 for 4
