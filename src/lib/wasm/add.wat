(module 
    (func $add (param $a i32) (param $b i32) (result i32)
        (i32.add (local.get $a) (local.get $b))
    )

    (call $add (i32.const 1) (i32.const 1)) ;; 2

    (export "add" (func $add))
)