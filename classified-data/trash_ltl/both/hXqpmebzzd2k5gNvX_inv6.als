var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv6 {
once File in Trash implies (always File in Trash)
}

pred inv6c {
	always Trash in Trash'
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 


