sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File - Protected | f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002695 { not once ((inv5 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap002695c { historically (not (inv5 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002695 { cap002695 iff cap002695c }
check CapBenchEquivalent_cap002695 for 4
