sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f,t : File |f->t not in link
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

pred cap002593 { not once ((inv8 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
pred cap002593c { historically (not (inv8 and ((some capBenchS or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002593 { cap002593 iff cap002593c }
check CapBenchEquivalent_cap002593 for 4
