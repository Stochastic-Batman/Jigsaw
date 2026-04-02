let table_file  = "gf256_tables.bin"
let generator   = 0x03
let irreducible = 0x11b  (* x^8 + x^4 + x^3 + x + 1, same as AES *)

(* Exp table is doubled (512 entries) so we never need `mod 255` when indexing: exp[(log[a] + log[b])] always lands in range. *)
let exp_table : int array = Array.make 512 0
let log_table : int array = Array.make 256 0


let compute_tables () =
    let x = ref 1 in
    for i = 0 to 254 do
        exp_table.(i) <- !x;
        log_table.(!x) <- i;
        x := !x lsl 1;  (* Multiply x by the generator in GF(256): left-shift logical, then XOR with irreducible poly if we overflow 8 bits *)
        if !x land 0x100 <> 0 then 
            x := !x lxor irreducible
    done;
    for i = 255 to 511 do  (* Duplicate the first 255 entries so indices 255–509 wrap correctly *)
        exp_table.(i) <- exp_table.(i - 255)
    done;
    log_table.(0) <- 0  (* as log(0) undefined, I set to 0 as a guardrail *)


let save_tables () =
    let oc = open_out_bin table_file in
    Array.iter (fun v -> output_byte oc v) exp_table;
    Array.iter (fun v -> output_byte oc v) log_table;
    close_out oc


let load_tables () =
    let ic = open_in_bin table_file in
    for i = 0 to 511 do exp_table.(i) <- input_byte ic done;
    for i = 0 to 255 do log_table.(i) <- input_byte ic done;
    close_in ic


let ensure_tables () =
    if Sys.file_exists table_file
    then load_tables ()
    else begin
        compute_tables ();
        save_tables ()
    end
