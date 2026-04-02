let read_file path =
	let ic = open_in_bin path in
	let len = in_channel_length ic in
	let buf = Bytes.create len in
	really_input ic buf 0 len;
	close_in ic;
	buf

let write_file path data =
	let oc = open_out_bin path in
	output_bytes oc data;
	close_out oc

let split_file path ~n ~k =
	let data   = read_file path in
	let shares = Slicer.split data ~n ~k in
	Array.iteri (fun i share ->
		let out_path = Printf.sprintf "%s.share_%d" path (i + 1) in
		write_file out_path share;
		Printf.printf "  wrote %s\n" out_path
	) shares

let join_files share_paths ~out_path =
	let shares = Array.of_list (List.map read_file share_paths) in
	let data   = Slicer.join shares in
	write_file out_path data
