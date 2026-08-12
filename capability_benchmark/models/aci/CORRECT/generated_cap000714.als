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

pred cap000714 { (some ((CapBenchA.capBenchR).capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
pred cap000714c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000714 { cap000714 iff cap000714c }
check CapBenchEquivalent_cap000714 for 4
