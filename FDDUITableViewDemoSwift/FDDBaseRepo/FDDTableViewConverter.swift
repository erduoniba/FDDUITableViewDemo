//
//  FDDTableViewConverter.swift
//  FDDUITableViewDemoSwift
//
//  Created by denglibing on 2017/2/10.
//  Copyright © 2017年 denglibing. All rights reserved.
//  Demo: https://github.com/erduoniba/FDDUITableViewDemoSwift
//

import UIKit

extension UITableView {
    func cellForIndexPath(_ indexPath: IndexPath, cellClass: AnyClass?) -> FDDBaseTableViewCell? {
        return self.cellForIndexPath(indexPath, cellClass: cellClass, cellReuseIdentifier: nil)
    }

    func cellForIndexPath(_ indexPath: IndexPath, cellClass: AnyClass?, cellReuseIdentifier: String?) -> FDDBaseTableViewCell? {
        if (cellClass?.isSubclass(of: FDDBaseTableViewCell.self))! {

            var identifier = NSStringFromClass(cellClass!) + "ID"
            if cellReuseIdentifier != nil {
                identifier = cellReuseIdentifier!
            }

            var cell = self.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                self.register(cellClass, forCellReuseIdentifier: identifier)
                cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            }

            return cell as? FDDBaseTableViewCell
        }
        return nil
    }
}

// 通过重载来实现特殊的cell
extension FDDBaseTableViewController {

    @objc(tableView:numberOfRowsInSection:) open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }

    @objc(tableView:cellForRowAtIndexPath:) open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel: FDDBaseCellModel = (self.dataArr.object(at: indexPath.row) as? FDDBaseCellModel)!
        let cell: FDDBaseTableViewCell
        if cellModel.cellReuseIdentifier != nil {
            cell = tableView.cellForIndexPath(indexPath, cellClass: cellModel.cellClass, cellReuseIdentifier: cellModel.cellReuseIdentifier)!
        }
        else {
            cell = tableView.cellForIndexPath(indexPath, cellClass: cellModel.cellClass)!
        }
        cell.setCellData(cellModel.cellData, delegate: self)
        cell.setSeperatorAtIndexPath(indexPath, numberOfRowsInSection: self.dataArr.count)
        return cell
    }

    @objc(tableView:heightForRowAtIndexPath:) open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel: FDDBaseCellModel = (self.dataArr.object(at: indexPath.row) as? FDDBaseCellModel)!
        return CGFloat(cellModel.cellHeight)
    }

    // MARK: - FDDBaseTableViewCellDelegate
    open func fddTableViewCell(cell: FDDBaseTableViewCell, object: AnyObject?) {
        if cell.isMember(of: FDDBaseTableViewCell.self) {
            print("FDDBaseTableViewCell的代理")
        }
    }
}

public typealias FddTableViewConterterBlock = (_ params: [Any]) -> AnyObject?

// 通过转换类来处理通用的tableView方法，特殊需要自己处理的使用 registerTableViewMethod 方式处理
public class FDDTableViewConverter: NSObject, UITableViewDataSource, UITableViewDelegate {

    deinit {
        print(NSStringFromClass(FDDTableViewConverter.self) + " dealloc")
    }

    private var selectorBlocks = NSMutableDictionary()
    open var dataArr = NSMutableArray()
    open weak var tableViewCarrier: AnyObject?

    convenience public init(withTableViewCarrier tableViewCarrier: AnyObject, dataSources: NSMutableArray) {
        self.init()
        self.tableViewCarrier = tableViewCarrier
        self.dataArr = dataSources
    }

    open func registerTableViewMethod(selector: Selector, handleParams params: FddTableViewConterterBlock) {
        selectorBlocks.setObject(params, forKey: NSStringFromSelector(selector) as NSCopying)
    }

    private func converterFunction(_ function: String, params: [Any]) -> AnyObject? {

        let result: Bool = self.selectorBlocks.allKeys.contains { ele in
            if String(describing: ele) == function {
                return true
            }
            else {
                return false
            }
        }

        if result {
            let block: FddTableViewConterterBlock = (self.selectorBlocks.object(forKey: function) as? FddTableViewConterterBlock)!
            return block(params) as AnyObject?
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let selector = #selector(tableView(_:heightForRowAt:))
        let cellHeight = self.converterFunction(NSStringFromSelector(selector), params: [tableView, indexPath])
        if cellHeight != nil {
            return (cellHeight as? CGFloat)!
        }

        let cellModel: FDDBaseCellModel = (self.dataArr.object(at: indexPath.row) as? FDDBaseCellModel)!
        return CGFloat(cellModel.cellHeight)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selector = #selector(tableView(_:cellForRowAt:))
        let closureCell = self.converterFunction(NSStringFromSelector(selector), params: [tableView, indexPath])
        if closureCell != nil {
            return (closureCell as? UITableViewCell)!
        }

        let cellModel: FDDBaseCellModel = (self.dataArr.object(at: indexPath.row) as? FDDBaseCellModel)!
        let cell: FDDBaseTableViewCell
        if cellModel.cellReuseIdentifier != nil {
            cell = tableView.cellForIndexPath(indexPath, cellClass: cellModel.cellClass, cellReuseIdentifier: cellModel.cellReuseIdentifier)!
        }
        else {
            cell = tableView.cellForIndexPath(indexPath, cellClass: cellModel.cellClass)!
        }
        cell.setCellData(cellModel.cellData, delegate: (self.tableViewCarrier as? FDDBaseTableViewCellDelegate)!)
        cell.setSeperatorAtIndexPath(indexPath, numberOfRowsInSection: self.dataArr.count)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = #selector(tableView(_:didSelectRowAt:))
        _ = self.converterFunction(NSStringFromSelector(selector), params: [tableView, indexPath])
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let selector = #selector(scrollViewDidScroll(_:))
        _ = self.converterFunction(NSStringFromSelector(selector), params: [scrollView])
    }
}
