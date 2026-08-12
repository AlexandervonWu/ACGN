sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f : File | f in Trash
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

pred cap002144 { not not ((inv3 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
pred cap002144c { (inv3 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) }
assert CapBenchEquivalent_cap002144 { cap002144 iff cap002144c }
check CapBenchEquivalent_cap002144 for 4
