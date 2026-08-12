sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000859 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap000859c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap000859 { cap000859 iff cap000859c }
check CapBenchEquivalent_cap000859 for 4
