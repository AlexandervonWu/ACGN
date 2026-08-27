sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv9 {
no File.link.link
}

pred inv9c {
	no link.link
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000534 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv9 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap000534c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv9 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap000534 { cap000534 iff cap000534c }
check CapBenchEquivalent_cap000534 for 4
