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

pred cap000924 { (some ((CapBenchA.capBenchR).capBenchR) and (inv3 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000924c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv3 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000924 { cap000924 iff cap000924c }
check CapBenchEquivalent_cap000924 for 4
