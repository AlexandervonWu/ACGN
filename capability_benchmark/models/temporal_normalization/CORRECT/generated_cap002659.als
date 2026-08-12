sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
File = Protected + Trash
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

pred cap002659 { not once ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap002659c { historically (not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002659 { cap002659 iff cap002659c }
check CapBenchEquivalent_cap002659 for 4
