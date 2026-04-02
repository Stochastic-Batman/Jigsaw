type t = int

let initialised = ref false

let init () =
    if not !initialised then begin
        Precompute.ensure_tables ();
        initialised := true
    end

let log_ () = Precompute.log_table
let exp_ () = Precompute.exp_table

let add a b = a lxor b
let sub a b = a lxor b   

let mul a b =
    if a = 0 || b = 0 then 0
    else (exp_ ()).((log_ ()).(a) + (log_ ()).(b))

let inv a =
    if a = 0 then raise Division_by_zero
    else (exp_ ()).(255 - (log_ ()).(a)) (* a^{-1} = g^{255 - log(a)}, because g^255 = 1 in GF(2^8)* *)

let div a b =
    if b = 0 then raise Division_by_zero
    else if a = 0 then 0
    else mul a (inv b)

let pow a n =
    assert (n >= 0);
    if a = 0 then (if n = 0 then 1 else 0)
    else if n = 0 then 1
    else let e = ((log_ ()).(a) * n) mod 255 in (exp_ ()).(e) (* The multiplicative group has order 255, so reduce the exponent. *)
