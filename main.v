module main

import huffman

const (
	file_path  = './test.jpg'
	compress   = './test.zz'
	file1_path = './test1.jpg'
)

fn main() {
	// folder := os.dir(os.args[0])
	huffman.encode_file(file_path, compress) ?
	huffman.decode_file(compress, file1_path) ?
}
