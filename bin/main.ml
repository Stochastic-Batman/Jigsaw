(* ============================================================
   main.ml
   Command-line interface for Jigsaw.

   Usage:
     jigsaw --split <file> <n> <k>
       Split <file> into <n> shares with threshold <k>.
       Produces: <file>.share_1  …  <file>.share_n

     jigsaw --join <out_file> <share1> [<share2> …]
       Reconstruct <out_file> from the provided share files.
   ============================================================ *)

let usage () =
	Printf.eprintf "Usage:\n";
	Printf.eprintf "  jigsaw --split <file> <n> <k>\n";
	Printf.eprintf "  jigsaw --join  <out>  <share1> [<share2> ...]\n";
	exit 1

let () =
	Random.self_init ();
	Gf256.init ();
	let argv = Sys.argv in
	let argc = Array.length argv in
	if argc < 2 then usage ();
	try
		match argv.(1) with
		| "--split" ->
			if argc <> 5 then usage ();
			let file  = argv.(2) in
			let n     = int_of_string argv.(3) in
			let k     = int_of_string argv.(4) in
			Shares.split_file file ~n ~k;
			Printf.printf "Split '%s' into %d shares (threshold %d).\n" file n k
		| "--join" ->
			if argc < 4 then usage ();
			let out_path    = argv.(2) in
			let share_paths = Array.to_list (Array.sub argv 3 (argc - 3)) in
			Shares.join_files share_paths ~out_path;
			Printf.printf "Reconstructed '%s' from %d shares.\n" out_path (argc - 3)
		| _ -> usage ()
	with
	| Arg.Bad msg ->
		Printf.eprintf "Error: %s\n" msg; exit 1
	| Failure msg ->
		Printf.eprintf "Error: %s\n" msg; exit 1
	| Sys_error msg ->
		Printf.eprintf "Error: %s\n" msg; exit 1
	| Invalid_argument msg ->
		Printf.eprintf "Error: %s\n" msg; exit 1
