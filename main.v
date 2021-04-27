module main

import huffman

const (
	file_path  = './test.jpg'
	file1_path = './test.zz'
	file2_path = './test1.jpg'
)

fn main() {
	huffman.encode_file(file_path, file1_path) ?
	huffman.decode_file(file1_path, file2_path) ?
}
