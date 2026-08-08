module alloy4fun_augmented_productionLine_v1_inv1
sig Position {}

sig Product {}

sig Component extends Product {
    parts : set Product,
    position : one Position
}
sig Resource extends Product {}

sig Robot {
        position : one Position
}

pred inv1_oracle[] {
all c : Component | some c.parts
}

pred inv1_correct_0[] {
parts in Component -> some Product
}

pred inv1_correct_1[] {
iden & Component->Component in parts.~parts
}

pred inv1_correct_2[] {
iden & Component->Product in parts.~parts
}

pred inv1_correct_3[] {
all c:Component | #c.parts >=1
}

pred inv1_correct_4[] {
all c:Component | some p:Product | p in c.parts
}

pred inv1_correct_5[] {
Component in parts.Product
}

