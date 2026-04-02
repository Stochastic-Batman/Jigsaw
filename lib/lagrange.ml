let interpolate_at_zero points =
    let k = Array.length points in
    if k < 1 then invalid_arg "Lagrange.interpolate_at_zero: need at least 1 point";
    let result = ref 0 in
    for j = 0 to k - 1 do
        let (x_j, y_j) = points.(j) in
        let basis = ref 1 in
        for m = 0 to k - 1 do
            if m <> j then begin
                let (x_m, _) = points.(m) in
                basis := Gf256.mul !basis (Gf256.div x_m (Gf256.add x_j x_m))
            end
        done;
        result := Gf256.add !result (Gf256.mul y_j !basis)
    done;
    !result
