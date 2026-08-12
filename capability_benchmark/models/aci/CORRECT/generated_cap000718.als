sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
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

pred cap000718 { (inv3 and ((no CapBenchA and no CapBenchB) and no CapBenchB)) }
pred cap000718c { ((inv3 and ((no CapBenchA and no CapBenchB) and no CapBenchB)) and (inv3 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000718 { cap000718 iff cap000718c }
check CapBenchEquivalent_cap000718 for 4
