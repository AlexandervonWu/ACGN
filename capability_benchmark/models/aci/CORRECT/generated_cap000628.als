sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
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

pred cap000628 { (inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchA)) }
pred cap000628c { ((inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchA)) and (inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000628 { cap000628 iff cap000628c }
check CapBenchEquivalent_cap000628 for 4
