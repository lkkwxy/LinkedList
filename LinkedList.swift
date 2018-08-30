//
//  LinkedList.swift
//  TEST
//
//  Created by ios on 2018/8/29.
//  Copyright © 2018年 ios. All rights reserved.
//

import Foundation
final public class LinkedList<E>  {
    private var size = 0
    private var firstNode:Node<E>?
    private var lastNode:Node<E>?
    
    /// 初始化一个空list
    public init() { }
    
    /// 通过序列初始化一个list
    public init<S>(_ s: S) where E == S.Element, S : Sequence {
        for (index,item) in s.enumerated() {
            let newNode = Node(element: item)
            if index == 0 {
                firstNode = newNode
                lastNode = newNode
            }else {
                newNode.prev = lastNode
                lastNode?.next = newNode
                lastNode = newNode
            }
            size += 1
        }
    }
}

// MARK: - 实现Collection协议
extension LinkedList : Collection {
    /// 开始位置
    public var startIndex: Int {  return 0 }
    /// 结束位置
    public var endIndex: Int { return size }
    /// 给定位置后面的索引值
    public func index(after i: Int) -> Int {
        return i + 1
    }
    /// 返回指定的迭代器
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
    /// 通过下标存取元素
    public subscript(position: Int) -> E {
        get {
            return node(at: position).item
        }
        set {
            node(at: position).item = newValue
        }
    }
}

// MARK: - 迭代器
extension LinkedList {
    public struct Iterator: IteratorProtocol {
        let list: LinkedList
        var index: Int
        private var nextNode:Node<E>?
        init(_ list: LinkedList) {
            self.list = list
            self.index = 0
            self.nextNode = list.firstNode
        }
        /// 获取下一个元素，在for in里若返回nil，则停止循环
        public mutating func next() -> E? {
            let item = nextNode?.item
            nextNode = nextNode?.next
            return item
        }
    }
}

// MARK: - private
extension LinkedList {
    /// 通过下标找到对应的节点
    private func node(at index:Int) -> Node<E> {
        //如果下标位置无效，则直接报错
        if !indexIsVaild(index) {
            fatalError("Index out of range:\(index) not belong 0..<\(size)")
        }
        //如果节点在前一半顺序查找，否则逆序查找
        if index < (size >> 1) {
            var node = firstNode
            for _ in 0..<index {
                node = node?.next
            }
            return node!
        }else {
            var node = lastNode
            for _ in stride(from: size - 1, to: index, by: -1) {
                node = node?.prev
            }
            return node!
        }
    }
    /// 下标是否是有效的
    private func indexIsVaild(_ index:Int) -> Bool {
        return index >= 0 && index < size
    }
}

// MARK: - 添加元素
extension LinkedList {
    /// 追加单个元素
    public func append(_ newElement: E) {
        let newNode = Node(element: newElement, next: nil, prev: lastNode)
        if lastNode == nil {
            firstNode = newNode
        }
        lastNode?.next = newNode
        lastNode = newNode
        size += 1
    }
    
    /// 追加多个元素
    public func append<S>(contentsOf newElements: S) where S : Sequence, E == S.Element {
        for item in newElements {
            append(item)
        }
    }
    
    /// 插入单个元素
    public func insert(_ newElement: E, at i: Int){
        let newNode = Node(element: newElement, next: nil, prev: nil)
        if i == 0 && size == 0{
            firstNode = newNode
            lastNode = newNode
        }else {
            let insertNode = node(at: i)
            newNode.next = insertNode
            insertNode.prev = newNode
            newNode.prev = insertNode.prev
            insertNode.prev?.next = newNode
            if i == 0 {
                firstNode = newNode
            }
        }
        size += 1
    }
    
    /// 插入多个元素
    public func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, E == S.Element {
        if i == 0 && size == 0 {
            append(contentsOf: newElements)
        }else {
            let insertNode = node(at: i)
            var firstNode:Node<E>?
            var lastNode:Node<E>?
            for (index,item) in newElements.enumerated() {
                let newNode = Node(element: item, next: nil, prev: nil)
                if index == 0 {
                    firstNode = newNode
                    lastNode = newNode
                }else {
                    newNode.prev = lastNode
                    lastNode?.next = newNode
                    lastNode = newNode
                }
                size += 1
            }
            firstNode?.prev = insertNode.prev
            lastNode?.next = insertNode
            insertNode.prev?.next = firstNode
            insertNode.prev = lastNode
            if i == 0 {
                self.firstNode = firstNode
            }
        }
    }
}
// MARK: - 删除元素
extension LinkedList {
    /// 删除指定位置的元素
    @discardableResult
    public func remove(at position: Int) -> E {
        let removeNode = node(at: position)
        removeNode.prev?.next = removeNode.next
        removeNode.next?.prev = removeNode.prev
        size -= 1
        return removeNode.item
    }
    /// 删除第一个元素
    @discardableResult
    public func removefirstNode() -> E? {
        return firstNode == nil ? nil : remove(at: 0)
    }
    /// 删除最后一个元素
    @discardableResult
    public func removelastNode() -> E? {
        return lastNode == nil ? nil : remove(at: size - 1)
    }
    /// 删除所有元素
    public func removeAll() {
        var next = firstNode
        while next != nil {
            let tmp = next
            next?.next = nil
            next?.prev = nil
            next = tmp
        }
        firstNode = nil
        lastNode = nil
        size = 0
    }
}

// MARK: - 通过条件查找位置
extension LinkedList {
    /// 顺序查找
    public func firstIndex(where predicate: (E) throws -> Bool) rethrows -> Int? {
        for (index,item) in self.enumerated() {
            if try predicate(item) {
                return index
            }
        }
        return nil
    }
    
    /// 倒序查找
    public func lastIndex(where predicate: (E) throws -> Bool) rethrows -> Int? {
        var prev = lastNode
        var currentIndex = size - 1
        while prev != nil {
            if try predicate(prev!.item) {
                return currentIndex
            }
            currentIndex -= 1
            prev = prev?.prev
        }
        return nil
    }
    
    /// 是否包含
    public func contains(where predicate: (E) throws -> Bool) rethrows -> Bool {
        for item in self{
            if try predicate(item) {
                return true
            }
        }
        return false
    }
}

// MARK: - 通过元素查找位置
extension LinkedList where E : Equatable {
    public func firstIndex(of element: E) -> Int? {
        return firstIndex { (item) -> Bool in
            return item == element
        }
    }
    public func lastIndex(of element: E) -> Int? {
        return lastIndex(where: { (item) -> Bool in
            return item == element
        })
    }
    
    public func contains(_ element: E) -> Bool {
        return contains(where: { (item) -> Bool in
            return item == element
        })
    }
}

// MARK: - 把LinkedList转成Array
extension LinkedList {
    public func toArray() -> [E] {
        return self.map({ (item) -> E in
            return item
        })
    }
}

// MARK: - ExpressibleByArrayLiteral，通过实现该协议，来实现字面量赋值
extension LinkedList : ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: E...) {
        self.init(elements)
    }
}

// MARK: - CustomDebugStringConvertible协议，通过实现该协议，实现自定义打印
extension LinkedList : CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = ""
        if size > 0 {
            for item in self.dropLast() {
                desc += "\(item)-->"
            }
            desc += "\(lastNode!.item)"
        }
        return desc
    }
}

// MARK: - Copy
extension LinkedList {
    public func copy() -> LinkedList {
        let copyList = LinkedList()
        copyList.size = self.size
        if let firstNode = firstNode {
            copyList.firstNode = Node(element: firstNode.item, next: nil, prev: nil)
            copyList.lastNode = copyList.firstNode
        }
        var nextNode = firstNode?.next
        while nextNode != nil {
            let newNode = Node(element: nextNode!.item)
            copyList.lastNode?.next = newNode
            newNode.prev = copyList.lastNode
            copyList.lastNode = newNode
            nextNode = nextNode?.next
        }
        return copyList
    }
}


/// 节点
fileprivate class Node<Element> {
    /// 节点元素的值
    var item:Element
    /// 下一个节点
    var next:Node<Element>?
    /// 上一个节点
    var prev:Node<Element>?
    init(element:Element, next:Node<Element>? = nil, prev:Node<Element>? = nil) {
        self.item = element
        self.next = next
        self.prev = prev
    }
}
