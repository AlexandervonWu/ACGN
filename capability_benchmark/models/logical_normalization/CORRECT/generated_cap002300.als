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

pred cap002300 { not not ((inv8 and ((some capBenchR and some capBenchS) or some capBenchR))) }
pred cap002300c { (inv8 and ((some capBenchR and some capBenchS) or some capBenchR)) }
assert CapBenchEquivalent_cap002300 { cap002300 iff cap002300c }
check CapBenchEquivalent_cap002300 for 4
