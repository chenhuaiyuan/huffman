// @title Huffman
// @description Huffman算法
// @author chy
// @created 2021-04-16 08:26:00
// @updated 2021-04-27 21:26:57

module huffman

import os
import math
import strings

enum NodeType {
	leaf
	mid
}

// Node huffman节点
[heap]
pub struct Node {
pub mut:
	typ  NodeType
	key  u32
	leaf byte
	l    voidptr
	r    voidptr
}

// @description 生成一个叶节点
// @param {byte} b 需要压缩的字符
// @param {u32} k 需要压缩的字符个数
// @return {&Node} 返回Huffman节点
fn new_leaf(b byte, k u32) &Node {
	return &Node{
		typ: .leaf
		key: k
		leaf: b
	}
}

// @description 通过两个叶节点生成一个中间节点
// @param {&Node} a Huffman叶节点
// @param {&Node} b huffman叶节点
// @return {&Node} 返回新的Huffman节点
fn new_node(a &Node, b &Node) &Node {
	mut l := &Node{}
	mut r := &Node{}
	if a.key < b.key {
		l = a
		r = b
	} else {
		l = b
		r = a
	}
	n := &Node{
		typ: .mid
		key: u32(a.key) + u32(b.key)
		l: l
		r: r
	}
	return n
}

// @description 通过内容生成叶节点
// @param {map[byte]u32} values 压缩字符 [字符]字符个数
// @return {[]&Node} 返回一个节点
fn leafs_from_values(values map[byte]u32) []&Node {
	mut nodes := []&Node{}
	for k, v in values {
		n := new_leaf(k, v)
		nodes << n
	}
	return nodes
}

// @description 快速排序算法，用于对node数组进行排序
// @param {[]&Node} src node数组
// @param {int} begin 左起始位置
// @param {int} end 右起始位置
fn qsort(mut src []&Node, begin int, end int) {
	if begin < end {
		key := src[begin]
		mut i := begin
		mut j := end
		for i < j {
			for i < j && src[j].key > key.key {
				j--
			}
			if i < j {
				src[i] = src[j]
				i++
			}
			for i < j && src[i].key < key.key {
				i++
			}
			if i < j {
				src[j] = src[i]
				j--
			}
		}
		src[i] = key
		qsort(mut src, begin, i - 1)
		qsort(mut src, i + 1, end)
	}
}

// @description 将nodes进行排序
// @param {[]&Node} nodes node数组
// @return {[]&Node} 排序好的node数组
fn sort_nodes(mut nodes []&Node) []&Node {
	qsort(mut nodes, 0, nodes.len - 1)
	return nodes
}

// @description 生成Huffman树
// @param {[]&Node} nodes 排序好的node数组
// @return {&Node} 返回第一个node
fn build_tree(mut nodes []&Node) &Node {
	for nodes.len > 1 {
		nodes = sort_nodes(mut nodes)
		n := new_node(nodes[0], nodes[1])
		nodes.delete(0)
		nodes.delete(0)
		nodes << n
	}
	return nodes[0]
}

// @description 将Huffman树生成map
// @param {&Node} n 相应节点
// @param {string} path 节点与节点之间连接的对应值，左节点为0，右节点为1
// @param {map[byte]string} table 用于递归
// @return {map[byte]string}
fn descend_table(n &Node, path string, mut table map[byte]string) map[byte]string {
	if n.typ == .mid {
		table = descend_table(n.l, path + '0', mut table)
		table = descend_table(n.r, path + '1', mut table)
	} else if n.typ == .leaf {
		table[n.leaf] = path
	}
	return table
}

// @description 将Huffman树生成相应的对照表
// @param {&Node} n Huffman树
// @return {map[byte]string}
fn generate_table(n &Node) map[byte]string {
	mut table := map[byte]string{}
	table = descend_table(n, '', mut table)
	return table
}

// @description 将Huffman中字符对应的值从左写入一个byte中
// @param {byte} bit 需要写入值的byte
// @param {byte} b 在Huffman中字符对应的值 0 or 1
// @return {byte} 返回已经处理好的byte
fn move_left(bit byte, b byte) byte {
	mut temp := bit << 1
	match b {
		`0` { temp |= 0x00 }
		`1` { temp |= 0x01 }
		else { temp |= 0x00 }
	}
	return temp
}

// @description 将Huffman中字符对应的值从右写入一个byte中，暂时未使用
// @param {byte} bit 需要写入值的byte
// @param {byte} b 在Huffman中字符对应的值 0 or 1
// @return {byte} 返回已经处理好的byte
fn move_right(bit byte, b byte) byte {
	mut temp := bit >> 1
	match b {
		`0` { temp |= 0x00 }
		`1` { temp |= 0x80 }
		else { temp |= 0x00 }
	}
	return temp
}

// @description 将head生成byte数组
// @param {map[byte]u32} head 需要压缩的字符个数
// @return {[]byte}
fn build_header(head map[byte]u32) []byte {
	mut header := []byte{}
	for key, val in head {
		header << key
		header << u32_to_bytes(val)
	}
	return header
}

// @description 将[]byte 转成 head
// @param {[]byte} head []byte
// @return {map[byte]u32}
fn analysis_header(head []byte) map[byte]u32 {
	mut header := map[byte]u32{}
	for i := 0; i < head.len; i += 5 {
		header[head[i]] = bytes_to_u32(head[i + 1..i + 5])
	}
	return header
}

// @description u32转[]byte
// @param {u32} n u32变量
// @return {[]byte} 返回一个byte数组
fn u32_to_bytes(n u32) []byte {
	mut b := []byte{len: 4}
	b[0] = byte(n)
	b[1] = byte(n >> 8)
	b[2] = byte(n >> 16)
	b[3] = byte(n >> 24)
	return b
}

// @description []byte转u32
// @param {[]byte} b
// @return {u32} 返回一个u32
fn bytes_to_u32(b []byte) u32 {
	mut i := 3
	mut n := u32(0)
	for i >= 0 {
		n |= b[i]
		if i > 0 {
			n <<= 8
		}
		i--
	}
	return n
}

// @description int转[]byte
// @param {int} n int值
// @return {[]byte}
fn int_to_bytes(n int) []byte {
	mut b := []byte{len: 5}
	b[4] = byte(n >> 31) & 0x01
	// == 1表示是负数，== 0表示是正数
	if b[4] == 1 {
		mut s := n
		s = ~s
		s += 1
		b[0] = byte(s)
		b[1] = byte(s >> 8)
		b[2] = byte(s >> 16)
		b[3] = byte(s >> 24)
	} else {
		b[0] = byte(n)
		b[1] = byte(n >> 8)
		b[2] = byte(n >> 16)
		b[3] = byte(n >> 24)
	}
	return b
}

// @description []byte 转 int
// @param {[]byte} b []byte值
// @return {int} 返回int值
fn bytes_to_int(b []byte) int {
	mut i := 3
	mut n := 0
	for i >= 0 {
		n ^= b[i]
		if i > 0 {
			n <<= 8
		}
		i--
	}
	if b[4] == 0 {
		return n
	} else {
		n = ~n
		n += 1
		return n
	}
}

// @description 从byte中读取header信息，每次只会读取5个字符
// @param {[]byte} content 文本内容
// @param {int} start 开始位置
// @return {[]byte} 返回换行符之前的内容
// @return {int} 返回读取到的内容个数，这个个数是固定的5
fn read_head(content []byte, start ...int) ([]byte, int) {
	mut block := []byte{}
	mut n := 0
	t := if start.len > 0 { content[start[0]..] } else { content }
	for i in 0 .. 5 {
		block << t[i]
		n++
	}
	return block, n
}

// @description 加密
// @param {[]byte} b 需要加密的byte数组
// @return {[]byte} 返回已经加密的byte数组
// @return {[]byte} Huffman树
pub fn encode(b []byte) ([]byte, []byte) {
	mut values := map[byte]u32{}
	// 计算需要压缩的byte的个数
	for v in b {
		values[v]++
	}
	mut leafs := leafs_from_values(values)
	tree := build_tree(mut leafs) // 创建Huffman树

	table := generate_table(tree) // 生成一个压缩对应表

	mut content := strings.new_builder(b.len)
	defer {
		unsafe { content.free() }
	}
	for v in b {
		content.write_string(table[v])
	}
	bits := content.str() // 压缩后的编码
	len := bits.len
	number := int(math.ceil(f64(len) / 8.0)) // 计算出需要几个byte
	mut code := []byte{len: number, init: 0}
	for i in 0 .. number {
		if len < 8 {
			for j in 0 .. len {
				code[i] = move_left(code[i], bits[j])
			}
			for _ in 0 .. 8 - len {
				code[i] = move_left(code[i], byte(0x30))
			}
		} else if i + 1 == number {
			for j in i * 8 .. i * 8 + len - i * 8 {
				code[i] = move_left(code[i], bits[j])
			}
			for _ in 0 .. len - i * 8 {
				code[i] = move_left(code[i], byte(0x30))
			}
		} else {
			for j in i * 8 .. i * 8 + 8 {
				code[i] = move_left(code[i], bits[j])
			}
		}
	}
	header := build_header(values)
	return code, header
}

// @description 解密
// @param {[]byte} b 需要解密的byte数组
// @param {int} num 字符数
// @param {&Node} tree Huffman树
// @param {int} content_len 内容长度
// @return {[]byte} 返回解密后的byte数组
pub fn decode(b []byte, tree &Node, content_len int) []byte {
	mut bytes := []byte{}
	mut node := tree
	arr := [128, 64, 32, 16, 8, 4, 2, 1]
	for v in b {
		for val in arr {
			if bytes.len >= content_len {
				break
			}
			bit := v & val
			if bit == 0 {
				node = node.l
			} else {
				node = node.r
			}
			if node.typ == .mid {
				continue
			} else {
				bytes << node.leaf
				node = tree
			}
		}
	}
	return bytes
}

// @description 压缩文件
// @param {string} path 需要压缩的文件路径
// @param {string} r_path 压缩后的文件路径
pub fn encode_file(path string, r_path string) ? {
	content := os.read_bytes(path) or { panic('读取文件失败') }
	code, header := encode(content)
	content_len := int_to_bytes(content.len)
	separator := '-----'
	mut file := os.open_file(r_path, 'wb+') or { panic('创建或打开压缩文件失败') }
	defer {
		file.close()
	}
	unsafe {
		first_len := file.write_ptr(content_len.data, content_len.len)
		header_len := file.write_to(u64(first_len), header) ?
		separator_len := file.write_to(u64(first_len + header_len), separator.bytes()) ?
		file.write_to(u64(first_len + header_len + separator_len), code) ?
	}
}

// @description 解压文件
// @param {string} path 解压后的文件路径
// @param {string} r_path 需要解压的文件路径
pub fn decode_file(r_path string, path string) ? {
	content := os.read_bytes(r_path) or { panic('读取文件失败') }
	content_len, n := read_head(content)
	len := bytes_to_int(content_len)
	mut values := []byte{}
	mut num := n
	for {
		value, i := read_head(content, num)
		num += i
		if value.bytestr() == '-----' {
			break
		}

		values << value
		if num >= len {
			break
		}
	}
	header := analysis_header(values)
	mut leafs := leafs_from_values(header)
	tree := build_tree(mut leafs) // 创建Huffman树
	body := decode(content[num..], tree, len)
	mut file := os.open_file(path, 'wb+') or { panic('创建或打开文件失败') }
	defer {
		file.close()
	}
	unsafe {
		file.write_ptr(body.data, body.len)
	}
}
