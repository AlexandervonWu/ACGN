sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002635 { not once ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap002635c { historically (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002635 { cap002635 iff cap002635c }
check CapBenchEquivalent_cap002635 for 4
