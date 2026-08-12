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

pred cap002049 { not ((inv7 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) }
pred cap002049c { ((not (inv7 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002049 { cap002049 iff cap002049c }
check CapBenchEquivalent_cap002049 for 4
