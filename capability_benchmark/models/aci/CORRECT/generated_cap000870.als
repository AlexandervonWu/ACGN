sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000870 { (some ((CapBenchA.capBenchR).capBenchR) and (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap000870c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap000870 { cap000870 iff cap000870c }
check CapBenchEquivalent_cap000870 for 4
