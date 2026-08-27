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

pred cap000918 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv3 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000918c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv3 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000918 { cap000918 iff cap000918c }
check CapBenchEquivalent_cap000918 for 4
