let eval_poly (coeffs : int array) (x : int) : int =
    let degree = Array.length coeffs - 1 in
    let result = ref coeffs.(degree) in
    for i = degree - 1 downto 0 do
        result := Gf256.add (Gf256.mul !result x) coeffs.(i)
    done;
    !result


let split data ~n ~k =
    if k < 1 then invalid_arg "Slicer.split: k must be >= 1";
    if n < k then invalid_arg "Slicer.split: n must be >= k";
    if n > 255 then invalid_arg "Slicer.split: n must be <= 255";
    let len = Bytes.length data in

    let shares = Array.init n (fun i ->
        let s = Bytes.make (len + 1) '\x00' in
        Bytes.set s 0 (Char.chr (i + 1));
        s
    ) in
    
    for byte_idx = 0 to len - 1 do
        let secret = Char.code (Bytes.get data byte_idx) in
        let coeffs = Array.init k (fun i ->
            if i = 0 then secret else Random.int 256
        ) in
        for share_idx = 0 to n - 1 do
            let x = share_idx + 1 in
            let y = eval_poly coeffs x in
            Bytes.set shares.(share_idx) (byte_idx + 1) (Char.chr y)
        done
    done;
    shares
    
    
let join shares =
    let num_shares = Array.length shares in
    if num_shares = 0 then invalid_arg "Slicer.join: no shares provided";
    
    let len = Bytes.length shares.(0) - 1 in
    let result = Bytes.make len '\x00' in
    let xs = Array.init num_shares (fun i -> Char.code (Bytes.get shares.(i) 0)) in
    for byte_idx = 0 to len - 1 do
        let points = Array.init num_shares (fun i ->
            let y = Char.code (Bytes.get shares.(i) (byte_idx + 1)) in
            (xs.(i), y)
        ) in
        let secret = Lagrange.interpolate_at_zero points in
        Bytes.set result byte_idx (Char.chr secret)
    done;
    result
