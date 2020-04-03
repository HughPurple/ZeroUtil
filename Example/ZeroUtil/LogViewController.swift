//
//  LogViewController.swift
//  ZeroUtil
//
//  Created by lyp on 2020/3/19.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import UIKit
import ZeroUtil

class LogViewController: BaseViewController {
    private var isSingleLineMode = true
    private let lineChangeBtn = UIButton()
    private let addBtn = UIButton()
    private let listBtn = UIButton()
    private let contentLabel = UILabel()
    private let scrollView = UIScrollView()
    private lazy var logFileHandler: ZLogFileHandler = {
        let logFileHandler = ZLogFileHandler()
        logFileHandler.clearLogFile(afterExpiredTimeInterval: 7 * 24 * 60 * 60)
        ZLogger.shared.handler.append(logFileHandler)
        return logFileHandler
    }()
    private let tableView = UITableView()
    private var fileUrls = [URL]()
    private(set) var currentUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(addBtn)
        view.addSubview(lineChangeBtn)
        view.addSubview(listBtn)
        view.addSubview(scrollView)
        view.addSubview(tableView)
        
        scrollView.addSubview(contentLabel)
        
        addBtn.addTarget(self, action: #selector(clickAddBtn), for: .touchUpInside)
        addBtn.setTitleColor(.black, for: .normal)
        addBtn.setTitle("Add", for: .normal)
        
        lineChangeBtn.addTarget(self, action: #selector(clickLineChangeBtn), for: .touchUpInside)
        lineChangeBtn.setTitleColor(.black, for: .normal)
        lineChangeBtn.setTitle("Multi Line Mode", for: .normal)
        
        listBtn.addTarget(self, action: #selector(clickListBtn), for: .touchUpInside)
        listBtn.setTitleColor(.black, for: .normal)
        listBtn.setTitle("Show List", for: .normal)
        listBtn.isHidden = true
        
        scrollView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.separatorInset = .zero

        contentLabel.numberOfLines = 0
        
        resetUI()
        fetchFile()
    }
    
    private func resetUI() {
        addBtn.frame.origin.x = 0
        addBtn.frame.origin.y = z.navBarFrame.maxY
        addBtn.sizeToFit()
        
        lineChangeBtn.frame.origin.x = addBtn.frame.maxX + 16
        lineChangeBtn.frame.origin.y = addBtn.frame.minY
        lineChangeBtn.sizeToFit()
        
        listBtn.frame.origin.x = lineChangeBtn.frame.maxX + 16
        listBtn.frame.origin.y = lineChangeBtn.frame.minY
        listBtn.sizeToFit()
        
        scrollView.frame = CGRect(x: 0, y: addBtn.frame.maxY, width: view.frame.width, height: view.frame.height - addBtn.frame.maxY)
        
        tableView.frame = scrollView.frame
        
        contentLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
    }
    
    @objc private func clickListBtn() {
        tableView.isHidden = false
        scrollView.isHidden = true
        listBtn.isHidden = true
        currentUrl = nil
    }
    
    @objc private func clickLineChangeBtn() {
        isSingleLineMode = lineChangeBtn.title(for: .normal) != "Multi Line Mode"
        var contentSize = CGSize.zero
        if isSingleLineMode {
            contentSize = contentLabel.sizeThatFits(.zero)
            lineChangeBtn.setTitle("Multi Line Mode", for: .normal)
        } else {
            contentSize.width = view.frame.width
            contentSize.height = contentLabel.sizeThatFits(contentSize).height
            lineChangeBtn.setTitle("Single Line Mode", for: .normal)
        }
        resetUI()
        contentLabel.frame.size = contentSize
        scrollView.contentSize = contentSize
    }
    
    @objc private func clickAddBtn() {
        didClickAddBtn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchFile()
            if self.isNeedUpdateContent() {
                self.contentNeedUpdate()
            }
        }
    }
    
    public func isNeedUpdateContent() -> Bool {
        return currentUrl == logFileHandler.currentLogUrl
    }
    
    public func didClickAddBtn() {
        zlog("\(#function)")
    }
    
    private func contentNeedUpdate() {
        guard let currentUrl = currentUrl else { return }
        do {
            let filHandle = try FileHandle(forReadingFrom: currentUrl)
            contentLabel.text = String(data: filHandle.readDataToEndOfFile(), encoding: .utf8)
        } catch let error as NSError {
            NSLog("failed to read: \(#function) \(error)")
        }
        if isSingleLineMode {
            contentLabel.frame.size = contentLabel.sizeThatFits(.zero)
        } else {
            contentLabel.frame.size.height = contentLabel.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude)).height
        }
        scrollView.contentSize = contentLabel.frame.size
    }
    
    public func fetchFile() {
        fileUrls = FileManager.default.z.sortedRegularFileUrl(inDirUrl: getBaseUrl())
        tableView.reloadData()
    }
    
    public func getBaseUrl() -> URL {
        return logFileHandler.getDirUrl()
    }
    
    deinit {
        ZLogger.shared.handler.removeAll(where: { $0 === logFileHandler })
    }
}

extension LogViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        
        if let fileUrl = fileUrls.z[safe: indexPath.row] {
            let fileUrl = fileUrl.standardizedFileURL
            cell.textLabel?.text = String(describing: fileUrl.path.suffix(from: getBaseUrl().path.endIndex))
        }
        
        return cell
    }
}

extension LogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let fileUrl = fileUrls.z[safe: indexPath.row] {
            currentUrl = fileUrl.standardizedFileURL
            tableView.isHidden = true
            scrollView.isHidden = false
            listBtn.isHidden = false
            contentNeedUpdate()
        } else {
            currentUrl = nil
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
