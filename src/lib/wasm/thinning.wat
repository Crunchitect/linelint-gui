;;========================================================;;
;;     SKELETONIZATION WITH HANDWRITTEN WEBASSEMBLY       ;;
;; `thinning.wat`   Lingdong Huang 2020     Public Domain ;;
;;========================================================;;
;; Binary image thinning (skeletonization) in-place.      ;;
;; Implements Zhang-Suen algorithm.                       ;;
;; http://agcggs680.pbworks.com/f/Zhan-Suen_algorithm.pdf ;;
;;--------------------------------------------------------;;

;; Added Linelin-specific algos

(module
  ;; 16 pages = 16 x 64kb = max dimension 1024x1024 (pixel=1 byte)
  (memory $mem 16)

  ;; pixels are stored as 8-bit row-major array in memory
  ;; reading a pixel: mem[i=y*w+x]
  (func $get_pixel (param $w i32) (param $x i32) (param $y i32) (result i32)
    (i32.load8_u (i32.add
      (i32.mul (local.get $w) (local.get $y))
      (local.get $x)
    ))
  )

  ;; writing a pixel: mem[i=y*w+x]=v
  (func $set_pixel (param $w i32) (param $x i32) (param $y i32) (param $v i32)
    (i32.store8 (i32.add
      (i32.mul (local.get $w) (local.get $y))
      (local.get $x)
    ) (local.get $v))
  )

  ;; one iteration of the thinning algorithm
  ;; w: width, h: height, iter: 0=even-subiteration, 1=odd-subiteration
  ;; returns 0 if no further thinning possible (finished), 1 otherwise
  (func $thinning_zs_iteration (param $w i32) (param $h i32) (param $iter i32) (result i32)
    ;; local variable declarations
    ;; iterators
    (local $i  i32) (local $j  i32)
    ;; pixel Moore neighborhood
    (local $p2 i32) (local $p3 i32) (local $p4 i32) (local $p5 i32) 
    (local $p6 i32) (local $p7 i32) (local $p8 i32) (local $p9 i32)
    ;; temporary computation results
    (local $A  i32) (local $B  i32)
    (local $m1 i32) (local $m2 i32)
    ;; bools for updating image and determining stop condition
    (local $diff  i32)
    (local $mark  i32)
    (local $neu   i32)
    (local $old   i32)

    (local.set $diff (i32.const 0))
    
    ;; raster scan the image (loop over every pixel)

    ;; for (i = 1; i < h-1; i++)
    (local.set $i (i32.const 1))
    loop $loop_i

      ;; for (j = 1; j < w-1; j++)
      (local.set $j (i32.const 1))
      loop $loop_j
      
        ;; pixel's Moore (8-connected) neighborhood:

        ;; p9 p2 p3
        ;; p8    p4
        ;; p7 p6 p5

        (local.set $p2 (i32.and (call $get_pixel (local.get $w)
                   (local.get $j)
          (i32.sub (local.get $i) (i32.const 1))
        ) (i32.const 1) ))
        
        (local.set $p3 (i32.and (call $get_pixel (local.get $w)
          (i32.add (local.get $j) (i32.const 1))
          (i32.sub (local.get $i) (i32.const 1))
        ) (i32.const 1) ))

        (local.set $p4 (i32.and (call $get_pixel (local.get $w)
          (i32.add (local.get $j) (i32.const 1))
                   (local.get $i)
        ) (i32.const 1) ))

        (local.set $p5 (i32.and (call $get_pixel (local.get $w)
          (i32.add (local.get $j) (i32.const 1))
          (i32.add (local.get $i) (i32.const 1))
        ) (i32.const 1) ))

        (local.set $p6 (i32.and (call $get_pixel (local.get $w)
                   (local.get $j)
          (i32.add (local.get $i) (i32.const 1))
        ) (i32.const 1) ))

        (local.set $p7 (i32.and (call $get_pixel (local.get $w)
          (i32.sub (local.get $j) (i32.const 1))
          (i32.add (local.get $i) (i32.const 1))
        ) (i32.const 1) ))

        (local.set $p8 (i32.and (call $get_pixel (local.get $w)
          (i32.sub (local.get $j) (i32.const 1))
                   (local.get $i)
        ) (i32.const 1) ))

        (local.set $p9 (i32.and (call $get_pixel (local.get $w)
          (i32.sub (local.get $j) (i32.const 1))
          (i32.sub (local.get $i) (i32.const 1))
        ) (i32.const 1) ))

        ;; A is the number of 01 patterns in the ordered set p2,p3,p4,...p8,p9
        (local.set $A (i32.add (i32.add( i32.add (i32.add( i32.add( i32.add( i32.add
          (i32.and (i32.eqz (local.get $p2)) (i32.eq (local.get $p3) (i32.const 1)))
          (i32.and (i32.eqz (local.get $p3)) (i32.eq (local.get $p4) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p4)) (i32.eq (local.get $p5) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p5)) (i32.eq (local.get $p6) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p6)) (i32.eq (local.get $p7) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p7)) (i32.eq (local.get $p8) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p8)) (i32.eq (local.get $p9) (i32.const 1))))
          (i32.and (i32.eqz (local.get $p9)) (i32.eq (local.get $p2) (i32.const 1))))
        )
        ;; B = p2 + p3 + p4 + ... + p8 + p9
        (local.set $B (i32.add (i32.add( i32.add
          (i32.add (local.get $p2) (local.get $p3))
          (i32.add (local.get $p4) (local.get $p5)))
          (i32.add (local.get $p6) (local.get $p7)))
          (i32.add (local.get $p8) (local.get $p9)))
        )

        (if (i32.eqz (local.get $iter)) (then
          ;; first subiteration,  m1 = p2*p4*p6, m2 = p4*p6*p8
          (local.set $m1 (i32.mul(i32.mul (local.get $p2) (local.get $p4)) (local.get $p6)))
          (local.set $m2 (i32.mul(i32.mul (local.get $p4) (local.get $p6)) (local.get $p8)))
        )(else
          ;; second subiteration, m1 = p2*p4*p8, m2 = p2*p6*p8
          (local.set $m1 (i32.mul(i32.mul (local.get $p2) (local.get $p4)) (local.get $p8)))
          (local.set $m2 (i32.mul(i32.mul (local.get $p2) (local.get $p6)) (local.get $p8)))
        ))

        ;; the contour point is deleted if it satisfies the following conditions:
        ;; A == 1 && 2 <= B <= 6 && m1 == 0 && m2 == 0
        (if (i32.and(i32.and(i32.and(i32.and
          (i32.eq   (local.get $A) (i32.const  1))
          (i32.lt_u (i32.const  1) (local.get $B)))
          (i32.lt_u (local.get $B) (i32.const  7)))
          (i32.eqz  (local.get $m1)))
          (i32.eqz  (local.get $m2)))
        (then
          ;; we cannot erase the pixel directly because computation for neighboring pixels
          ;; depends on the current state of this pixel. And instead of using 2 matrices,
          ;; we do a |= 2 to set the second LSB to denote a to-be-erased pixel
          (call $set_pixel (local.get $w) (local.get $j) (local.get $i)
            (i32.or
              (call $get_pixel (local.get $w) (local.get $j) (local.get $i))
              (i32.const 2)
            )
          )
        )(else))
        
        ;; increment loopers
        (local.set $j (i32.add (local.get $j) (i32.const 1)))
        (br_if $loop_j (i32.lt_u (local.get $j) (i32.sub (local.get $w) (i32.const 1))) )
      end
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $loop_i (i32.lt_u (local.get $i) (i32.sub (local.get $h) (i32.const 1))))
    end

    ;; for (i = 1; i < h; i++)
    (local.set $i (i32.const 0))
    loop $loop_i2

      ;; for (j = 0; j < w; j++)
      (local.set $j (i32.const 0))
      loop $loop_j2
        ;; bit-twiddling to retrive the new image stored in the second LSB
        ;; and check if the image has changed
        ;; mark = mem[i,j] >> 1
        ;; old  = mem[i,j] &  1
        ;; mem[i,j] = old & (!marker)
        (local.set $neu (call $get_pixel (local.get $w) (local.get $j) (local.get $i)))
        (local.set $mark (i32.shr_u (local.get $neu) (i32.const 1)))
        (local.set $old  (i32.and   (local.get $neu) (i32.const 1)))
        (local.set $neu  (i32.and   (local.get $old) (i32.eqz (local.get $mark))))

        (call $set_pixel (local.get $w) (local.get $j) (local.get $i) (local.get $neu))

        ;; image has changed, tell caller function that we will need more iterations
        (if (i32.ne (local.get $neu) (local.get $old)) (then
          (local.set $diff (i32.const 1))
        ))

        (local.set $j (i32.add (local.get $j) (i32.const 1)))
        (br_if $loop_j2 (i32.lt_u (local.get $j) (local.get $w)))
      end
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $loop_i2 (i32.lt_u (local.get $i) (local.get $h)))
    end

    ;; return
    (local.get $diff)
  )

  ;; main thinning routine
  ;; run thinning iteration until done
  ;; w: width, h:height
  (func $thinning_zs (param $w i32) (param $h i32)
    (local $diff i32)
    (local.set $diff (i32.const 1))
    loop $l0
      ;; even subiteration
      (local.set $diff (i32.and 
        (local.get $diff) 
        (call $thinning_zs_iteration (local.get $w) (local.get $h) (i32.const 0))
      ))
      ;; odd subiteration
      (local.set $diff (i32.and 
        (local.get $diff) 
        (call $thinning_zs_iteration (local.get $w) (local.get $h) (i32.const 1))
      ))
      ;; no change -> done!
      (br_if $l0 (i32.eq (local.get $diff) (i32.const 1)))
    end
  )

  ;; w: width, h: height
  (func $corner_fixing (param $w i32) (param $h i32)
    ;; x and y, i and j (offset)
    (local $x i32) (local $y i32)
    (local $i i32) (local $j i32)
    ;; direction
    (local $dir i32)
    ;; pixels 0 +i +j +2i +2j
    (local $p i32) (local $p1 i32) (local $p2 i32) (local $p3 i32) (local $p4 i32)
    ;; pixel condition
    (local $ap i32)

    ;; for (x = 2; x < w-2; x++)
    (local.set $x (i32.const 2))
    loop $loop_x
      ;; for (y = 2; y < h-2; y++)
      (local.set $y (i32.const 2))
      loop $loop_y
        (local.set $p (call $get_pixel
          (local.get $w)
          (local.get $x)
          (local.get $y)
        ))
        (
          if (i32.eqz (local.get $p) (i32.const 0))
          (then 
            (local.set $dir (i32.const 0))
            ;; for (d = 0; d < 4; d++)
            loop $loop_dir
              ;; i = d & 2 ? -1 : 1, j = d & 1 ? -1 : 1
              (local.set $i (i32.and (local.get $dir) (i32.const 2)))
              (
                if (local.get $i)
                (then
                  (local.set $i (i32.const -1))
                )
                (else
                  (local.set $i (i32.const 1))
                )
              )

              (local.set $j (i32.and (local.get $dir) (i32.const 1)))
              (
                if (local.get $j)
                (then
                  (local.set $j (i32.const -1))
                )
                (else
                  (local.set $j (i32.const 1))
                )
              )

              ;; Boyer-Moore extended neighbours
              ;; p2
              ;; p1
              ;; p  p3 p4

              (local.set $p1 (call $get_pixel
                (local.get $w)
                (local.get $x)
                (i32.add (local.get $y) (local.get $i))
              ))
 
              (local.set $p2 (call $get_pixel
                (local.get $w)
                (local.get $x)
                (i32.add (local.get $y) (i32.mul (local.get $i) (i32.const 2)))
              ))
              
              (local.set $p3 (call $get_pixel
                (local.get $w)
                (i32.add (local.get $x) (local.get $j))
                (local.get $y)
              ))
 
              (local.set $p4 (call $get_pixel
                (local.get $w)
                (i32.add (local.get $x) (i32.mul (local.get $j) (i32.const 2)))
                (local.get $y)
              ))

              (local.set $ap (i32.and (local.get $p1) (local.get $p2)))
              (local.set $ap (i32.and (local.get $ap) (local.get $p3)))
              (local.set $ap (i32.and (local.get $ap) (local.get $p4)))
              (if (local.get $ap)
                (then
                  (call $set_pixel
                    (local.get $w)
                    (local.get $x)
                    (local.get $y)
                    (i32.const 1)
                  )
                  (call $set_pixel
                    (local.get $w)
                    (i32.add (local.get $x) (local.get $j))
                    (i32.add (local.get $y) (local.get $i))
                    (i32.const 0)
                  )
                )
              )

              (local.set $dir (i32.add (local.get $dir) (i32.const 1)))
              (br_if $loop_dir (i32.lt_s (local.get $dir) (i32.const 4)))
            end
          )
        )
        (local.set $y (i32.add (local.get $y) (i32.const 1)))
        (br_if $loop_y (i32.lt_u (local.get $y) (i32.sub (local.get $h) (i32.const 2))))
        drop
      end
      (local.set $x (i32.add (local.get $x) (i32.const 1)))
      (br_if $loop_x (i32.lt_u (local.get $x) (i32.sub (local.get $w) (i32.const 2))))
    end
  )

  ;; x is high 2 bytes, y is low 2 bytes
  (func $closest_black_pixel (param $x i32) (param $y i32) (param $w i32) (param $h i32) (result i64)
    (local $sum i32) (local $dx i32) (local $dy i32) (local $p i32) (local $ret i64)
    ;; while (1)
    (local.set $sum (i32.const 0))
    (local.set $p (i32.const 0))
    loop $l 
      (br_if $l (i32.sub (i32.const 1) (local.get $p)))
      ;; sum++
      (local.set $sum (i32.add (local.get $sum) (i32.const 1)))
      ;; for(dx = 0; dx <= sum; dx++)
      (local.set $dx (i32.const 0))
      loop $loop_dx
        ;; dy = sum - dx
        (local.set $dy (i32.sub (local.get $sum) (local.get $dx)))

        ;; iterate through all signs
        ;; + +
        (local.set $p (call $get_pixel
          (local.get $w)
          (i32.add (local.get $x) (local.get $dx))
          (i32.add (local.get $y) (local.get $dy))
        ))
        (local.set $ret
          (i64.add 
            (i64.shl (i64.extend_i32_s (i32.add (local.get $x) (local.get $dx))) (i64.const 32))
            (i64.extend_i32_s (i32.add (local.get $y) (local.get $dy)))
          )
        )
        (br_if $l (i32.sub (i32.const 1) (local.get $p)))

        ;; + -
        (local.set $p (call $get_pixel
          (local.get $w)
          (i32.add (local.get $x) (local.get $dx))
          (i32.sub (local.get $y) (local.get $dy))
        ))
        (local.set $ret
          (i64.add 
            (i64.shl (i64.extend_i32_s (i32.add (local.get $x) (local.get $dx))) (i64.const 32))
            (i64.extend_i32_s (i32.sub (local.get $y) (local.get $dy)))
          )
        )
        (br_if $l (i32.sub (i32.const 1) (local.get $p)))

        ;; - +
        (local.set $p (call $get_pixel
          (local.get $w)
          (i32.sub (local.get $x) (local.get $dx))
          (i32.add (local.get $y) (local.get $dy))
        ))
        (local.set $ret
          (i64.add 
            (i64.shl (i64.extend_i32_s (i32.sub (local.get $x) (local.get $dx))) (i64.const 32))
            (i64.extend_i32_s (i32.add (local.get $y) (local.get $dy)))
          )
        )
        (br_if $l (i32.sub (i32.const 1) (local.get $p)))
        
        ;; - -
        (local.set $p (call $get_pixel
          (local.get $w)
          (i32.sub (local.get $x) (local.get $dx))
          (i32.sub (local.get $y) (local.get $dy))
        ))
        (local.set $ret
          (i64.add 
            (i64.shl (i64.extend_i32_s (i32.sub (local.get $x) (local.get $dx))) (i64.const 32))
            (i64.extend_i32_s (i32.sub (local.get $y) (local.get $dy)))
          )
        )
        (br_if $l (i32.sub (i32.const 1) (local.get $p)))

        (local.set $dx (i32.add (local.get $dx) (i32.const 1)))
        (br_if $loop_dx (i32.le_u (local.get $dx) (local.get $sum)))
      end
    end
    (local.get $ret)
  )

  ;; exported API's
  (export "thinning_zs_iteration" (func $thinning_zs_iteration))
  (export "thinning_zs" (func $thinning_zs))
  (export "get_pixel"   (func $get_pixel))
  (export "set_pixel"   (func $set_pixel))
  (export "corner_fixing" (func $corner_fixing))
  (export "closest_black_pixel" (func $closest_black_pixel))
  (export "mem"         (memory $mem))
)
