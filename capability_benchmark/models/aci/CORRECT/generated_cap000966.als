sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv4 {
all p : Protected | p  not in Trash
}

pred inv4c {
  	no Protected & Trash
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000966 { (some ((CapBenchA.capBenchR).capBenchR) and (inv4 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000966c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv4 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000966 { cap000966 iff cap000966c }
check CapBenchEquivalent_cap000966 for 4
