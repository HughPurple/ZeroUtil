//
//  ThemeViewController.swift
//  ZeroUtil
//
//  Created by lyp on 2020/4/16.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import Foundation
import ZeroUtil
import SnapKit

class ThemeViewController: BaseViewController {
    private let assertThemeStatus = UILabel()
    private let assertThemeSwitch = UISwitch()
    private let adjustFontStatus = UILabel()
    private let adjustFontSwitch = UISwitch()
    private let themeStepper = UIStepper()
    private let tableView = UITableView()
    private var fontMap: [String: [String]] { return ThemeManager.shared.fontTheme.itemMap }
    private var colorMap: [String: [String]] { return ThemeManager.shared.colorTheme.itemMap }
    private var dataSource: [Int: [(bgColor: UIColor?, font: UIFont?, content: String)]] = [:]
    private var keys = Set<String>()
    
    private lazy var outOfCount: Int = { return max(outOfFont.count, outOfColor.count) }()
    private lazy var outOfFont: [UIFont] = {
        var fonts =  [UIFont.font_10001_12P5_PingFangSC_Regular, .font_10002_12_PingFangSC_Regular]
        for `func` in [UIFont.font_10001_12P5(fontName:weight:), UIFont.font_10003_16(fontName:weight:)] {
            for fontName in CustomFontName.allCases {
                for weight in CustomFontWeight.allCases {
                    fonts.append(`func`(fontName, weight))
                }
            }
        }
        return fonts
    }()
    private lazy var outOfColor: [UIColor] = {
        return [.color_10001_8E5AF7_142_90_247]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        layoutUI()
        configTheme(isNew: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(themeStepper)
        view.addSubview(assertThemeStatus)
        view.addSubview(assertThemeSwitch)
        view.addSubview(adjustFontStatus)
        view.addSubview(adjustFontSwitch)
        view.addSubview(tableView)
        
        themeStepper.addTarget(self, action: #selector(themeDidChanged), for: .valueChanged)
        
        assertThemeStatus.text = "assert status "
        assertThemeStatus.baselineAdjustment = .alignCenters
        assertThemeStatus.adjustsFontSizeToFitWidth = true
        
        assertThemeSwitch.addTarget(self, action: #selector(themeDidChanged), for: .valueChanged)
        
        adjustFontStatus.text = "adjust font status "
        adjustFontStatus.baselineAdjustment = .alignCenters
        adjustFontStatus.adjustsFontSizeToFitWidth = true
        
        adjustFontSwitch.addTarget(self, action: #selector(themeDidChanged), for: .valueChanged)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
    }

    private func layoutUI() {
        themeStepper.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(z.navBarFrame.maxY)
            make.left.equalToSuperview()
            make.height.equalTo(max(themeStepper.frame.height, assertThemeStatus.frame.height))
        }
        assertThemeStatus.snp.makeConstraints { (make) in
            make.left.equalTo(themeStepper.snp.right)
            make.top.size.equalTo(themeStepper)
        }
        assertThemeSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(assertThemeStatus.snp.right)
            make.top.height.equalTo(themeStepper)
        }
        adjustFontStatus.snp.makeConstraints { (make) in
            make.left.equalTo(assertThemeSwitch.snp.right)
            make.top.size.equalTo(themeStepper)
        }
        adjustFontSwitch.snp.makeConstraints { (make) in
            make.left.equalTo(adjustFontStatus.snp.right)
            make.right.equalToSuperview()
            make.top.height.equalTo(themeStepper)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(themeStepper.snp.bottom)
            make.left.width.bottom.equalToSuperview()
        }
    }
    
    private func configTheme(isNew: Bool) {
        if let jsonObject = ThemeManager.getJSONObject(from: Bundle.main, file: "theme", fileType: "json") {
            themeStepper.stepValue = 1
            themeStepper.minimumValue = 0
            themeStepper.maximumValue = Double(max(jsonObject.filter({ $0.key.hasPrefix("color_") }).count, jsonObject.filter({ $0.key.hasPrefix("font_") }).count) - 1)
            
            let colorKey = "color_\(Int(themeStepper.value))"
            if let colorJSONObject = jsonObject[colorKey] as? [String: Any] {
                ThemeManager.parserTheme(from: colorJSONObject, for: ThemeManager.shared.colorTheme)
                assertTheme(ThemeManager.shared.colorTheme)
            }
            
            ThemeManager.shared.fontTheme.autoAssertEnabled = adjustFontSwitch.isOn
            let fontKey = "font_\(Int(themeStepper.value))"
            if let fontJSONObject = jsonObject[fontKey] as? [String: Any] {
                ThemeManager.parserTheme(from: fontJSONObject, for: ThemeManager.shared.fontTheme)
                assertTheme(ThemeManager.shared.fontTheme)
                adjustFontWeightIfNeeds()
            }
            if isNew {
                keys = Set(fontMap.keys).union(colorMap.keys)
            }
            resetDataSource()
        }
    }
    
    private func assertTheme<K: Hashable, R: ZThemeParser>(_ manager: ZThemeManager<K, R>) {
        guard assertThemeSwitch.isOn else { return }
        
        manager.itemMap.forEach { (data) in
            for (index, value) in data.value.enumerated() {
                if let item = value.split(separator: "_").z[safe: manager.indexInItem] {
                    if item.isEmpty {
                        assert(false, "empty rawValue in: \(index), for (\(data.key), \(value))")
                    } else if manager.item(for: data.key, rawValue: String(item)) == manager.defaultValue {
                        assert(false, "failed to parser rawValue in: \(index), for (\(data.key), \(value))")
                    }
                } else {
                    assert(false, "nil rawValue in: \(index), for (\(data.key), \(value))")
                }
            }
        }
    }
    
    private func adjustFontWeightIfNeeds() {
        guard adjustFontSwitch.isOn else { return }
        
        let oldItemMap = ThemeManager.shared.fontTheme.itemMap
        let defaultValue = ThemeManager.shared.fontTheme.defaultValue
        let indexInItem = ThemeManager.shared.fontTheme.indexInItem
        let baseItems = Array(repeating: "", count: indexInItem)
        for (key, values) in oldItemMap {
            for (index, value) in values.enumerated() {
                let data = ThemeManager.shared.fontTheme.parser(value, indexInItem, defaultValue)
                let parserFont = UIFont.create(from: data, default: defaultValue)
                if parserFont === defaultValue {
                    var items = baseItems + data.items + Array(repeating: "", count: max(0, max(indexInItem + 3, data.items.count) - data.items.count))
                    var font = defaultValue
                    for fontWeight in CustomFontWeight.allCases {
                        items[indexInItem + 2] = String(describing: fontWeight)
                        ThemeManager.shared.fontTheme.itemMap[key]?[index] = items.joined(separator: "_")
                        font = ThemeManager.shared.fontTheme.item(for: key, rawValue: items.joined(separator: "_"))
                        if font != defaultValue {
                            break
                        }
                    }
                    if font === defaultValue {
                        ThemeManager.shared.fontTheme.itemMap[key]?[index] = value
                        NSLog(["failed to adjust font weight for: (\(key), \(value))", "parser font: (\(parserFont.pointSize), \(parserFont.fontName))"].description)
                    } else {
                        NSLog(["adjust font weight for: (\(key), \(value))", "parser font: (\(parserFont.pointSize), \(parserFont.fontName))", "adjust font: (\(font.pointSize), \(font.fontName))"].description)
                    }
                }
            }
        }
    }
    
    private func resetDataSource() {
        dataSource.removeAll()
        for (section, key) in keys.enumerated() {
            var rows = [(UIColor?, UIFont?, String)]()
            for row in 0..<max((colorMap[key] ?? []).count, (fontMap[key] ?? []).count) {
                var content = "[\(section), \(rows.count)]", bgColor: UIColor?, font: UIFont?
                if let rawValue = colorMap[key]?.z[safe: row] {
                    bgColor = ThemeManager.shared.colorTheme.item(for: key, rawValue: rawValue)
                    content.append(" rawColor: \(rawValue)")
                }
                if let rawValue = fontMap[key]?.z[safe: row] {
                    font = ThemeManager.shared.fontTheme.item(for: key, rawValue: rawValue)
                    content.append(" rawFont: \(rawValue)")
                }
                rows.append((bgColor, font, content))
            }
            dataSource[section] = rows
        }
        for section in 0..<outOfCount {
            dataSource[dataSource.count] = [(outOfColor.z[safe: section], outOfFont.z[safe: section], "[\(dataSource.count), 0]")]
        }
    }
    
    @objc private func themeDidChanged(_ sender: UIView) {
        configTheme(isNew: sender === themeStepper)
        tableView.reloadData()
    }
}

extension ThemeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        var content = ""

        if let data = dataSource[indexPath.section]?.z[safe: indexPath.row] {
            content.append(data.content)
            if let font = data.font {
                cell.textLabel?.font = font
            } else {
                content.append(" rawFont: nil")
                cell.textLabel?.font = ThemeManager.shared.fontTheme.defaultValue
            }
            if let bgColor = data.bgColor {
                cell.textLabel?.backgroundColor = bgColor
            } else {
                content.append(" rawColor: nil")
                cell.textLabel?.backgroundColor = ThemeManager.shared.colorTheme.defaultValue
            }
        } else {
            content.append("error")
        }

        if let font = cell.textLabel?.font {
            content.append(" font: \(font.fontName) \(font.pointSize)")
        }

        if let rgba = cell.textLabel?.backgroundColor?.z.rgba {
            content.append(" color: ".appending([Int(0xFF * rgba.red), Int(0xFF * rgba.green), Int(0xFF * rgba.blue), rgba.alpha].description))
        }

        cell.textLabel?.text = content
        cell.textLabel?.textColor = .red
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
}

extension ThemeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let data = dataSource[indexPath.section]?.z[safe: indexPath.row] {
            if let bgColor = data.bgColor {
                cell.textLabel?.backgroundColor = bgColor
            } else {
                cell.textLabel?.backgroundColor = ThemeManager.shared.colorTheme.defaultValue
            }
        }
    }
}

public class ThemeManager: AutoThemeManager {
    static let shared = ThemeManager()
    
    let colorTheme = ZThemeManager<String, UIColor>(default: .black)
    let fontTheme = AutoFunctionThemeManager<String, UIFont>(default: .systemFont(ofSize: 16))
    
    override init() {
        super.init()
        colorTheme.parser = colorParser(content:index:default:)
        fontTheme.parser = fontParser(content:index:default:)
    }
}

public extension UIColor {
    
    class var color_10001_8E5AF7_142_90_247: UIColor {
        return ThemeManager.shared.colorTheme.item(for: String(#function.split(separator: "_").z[safe: 1] ?? ""))
    }
}

public enum CustomFontWeight: CaseIterable {
    case Black, Bold, Heavy, Light, Medium, Regular, Semibold, Thin, UltraLight
}

public enum CustomFontName: CaseIterable {
    case PingFangSC
}

public extension UIFont {
    
    class var font_10001_12P5_PingFangSC_Regular: UIFont {
        return ThemeManager.shared.fontTheme.item()
    }
    
    class var font_10002_12_PingFangSC_Regular: UIFont {
        return ThemeManager.shared.fontTheme.item()
    }
    
    class func font_10001_12P5(fontName: CustomFontName = .PingFangSC, weight: CustomFontWeight = .Regular) -> UIFont {
        return themeFont(fontName: fontName, weight: weight)
    }
    
    class func font_10003_16(fontName: CustomFontName = .PingFangSC, weight: CustomFontWeight = .Regular) -> UIFont {
        return themeFont(fontName: fontName, weight: weight)
    }
    
    class func themeFont(for rawValue: String = #function, fontName: CustomFontName = .PingFangSC, weight: CustomFontWeight = .Regular) -> UIFont {
        if let endIndex = rawValue.firstIndex(of: "(") {
            return ThemeManager.shared.fontTheme.item(rawValue: rawValue.prefix(upTo: endIndex).appending("_").appending(String(describing: fontName)).appending("_").appending(String(describing: weight)))
        } else {
            return ThemeManager.shared.fontTheme.item(rawValue: rawValue.appending("_").appending(String(describing: fontName)).appending("_").appending(String(describing: weight)))
        }
    }
}
