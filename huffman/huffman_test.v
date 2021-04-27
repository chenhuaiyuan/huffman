module huffman

fn test_encode() {
	content := 'test'
	code, _ := encode(content.bytes())
	println(code)
	assert code[0] == `p`
}

fn test_decode() {
	code := [byte(`p`)]
	header := map{
		byte(`s`): u32(1)
		byte(`e`): u32(1)
		byte(`t`): u32(2)
	}
	mut leafs := leafs_from_values(header)
	tree := build_tree(mut leafs)
	content := decode(code, tree, 4)
	println(content)
	assert content.bytestr() == 'test'
}
