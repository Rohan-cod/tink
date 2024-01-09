import SwiftUI

/// https://github.com/dkk/WrappingHStack
/// WrappingHStack is a UI Element that works in a very similar way to HStack,
///  but automatically positions overflowing elements on next lines.
///  It can be customized by using alignment (controls the alignment of the
///  items, it may get ignored when combined with `dynamicIncludingBorders`
///  or `.dynamic` spacing), spacing (use `.constant` for fixed spacing,
///  `.dynamic` to have the items fill the width of the WrappingHSTack and
///  `.dynamicIncludingBorders` to fill the full width with equal spacing
///  between items and from the items to the border.) and lineSpacing (which
///  adds a vertical separation between lines)
///
public struct WrappingHStack: View {
    private struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    public enum Spacing {
        case constant(CGFloat)
        case dynamic(minSpacing: CGFloat)
        case dynamicIncludingBorders(minSpacing: CGFloat)

        internal var minSpacing: CGFloat {
            switch self {
            case .constant(let constantSpacing):
                return constantSpacing
            case .dynamic(minSpacing: let minSpacing), .dynamicIncludingBorders(minSpacing: let minSpacing):
                return minSpacing
            }
        }
    }

    let alignment: HorizontalAlignment
    let spacing: Spacing
    let lineSpacing: CGFloat
    let lineManager = LineManager()
    let contentManager: ContentManager
    @State private var height: CGFloat = 0

    public var body: some View {
        GeometryReader { geo in
            InternalWrappingHStack(
                width: geo.size.width,
                alignment: alignment,
                spacing: spacing,
                lineSpacing: lineSpacing,
                lineManager: lineManager,
                contentManager: contentManager
            )
            .anchorPreference(
                key: HeightPreferenceKey.self,
                value: .bounds,
                transform: {
                    geo[$0].size.height
                }
            )
        }
        .frame(height: height)
        .onPreferenceChange(HeightPreferenceKey.self, perform: {
            if abs(height - $0) > 1 {
                height = $0
            }
        })
    }
}

// Convenience inits that allows 10 Elements (just like HStack).
// Based on https://alejandromp.com/blog/implementing-a-equally-spaced-stack-in-swiftui-thanks-to-tupleview/
public extension WrappingHStack {
    @inline(__always) private static func getWidth<V: View>(of view: V) -> Double {
        if view is NewLine {
            return .infinity
        }

#if os(iOS)
        let hostingController = UIHostingController(rootView: view)
#else
        let hostingController = NSHostingController(rootView: view)
#endif
        return hostingController.sizeThatFits(in: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
    }

    /// Instatiates a WrappingHStack
    /// - Parameters:
    ///   - data: The items to show
    ///   - id: The `KeyPath` to use as id for the items
    ///   - alignment: Controls the alignment of the items. This may get
    ///    ignored when combined with `.dynamicIncludingBorders` or
    ///    `.dynamic` spacing.
    ///   - spacing: Use `.constant` for fixed spacing, `.dynamic` to have
    ///    the items fill the width of the WrappingHSTack and
    ///    `.dynamicIncludingBorders` to fill the full width with equal spacing
    ///    between items and from the items to the border.
    ///   - lineSpacing: The distance in points between the bottom of one line
    ///    fragment and the top of the next
    ///   - content: The content and behavior of the view.
    ///
    
    init<Data: RandomAccessCollection, Content: View>(_ data: Data,
                                                      id: KeyPath<Data.Element, Data.Element> = \.self,
                                                      alignment: HorizontalAlignment = .leading,
                                                      spacing: Spacing = .constant(8),
                                                      lineSpacing: CGFloat = 8,
                                                      @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.alignment = alignment
        self.contentManager = ContentManager(
            items: data.map { ViewType(rawView: content($0[keyPath: id])) },
            getWidths: {
                data.map {
                    Self.getWidth(of: content($0[keyPath: id]))
                }
            })
    }

    init<A: View>(alignment: HorizontalAlignment = .leading, spacing: Spacing = .constant(8), lineSpacing: CGFloat = 0, @ViewBuilder content: @escaping () -> A) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.alignment = alignment
        self.contentManager = ContentManager(
            items: [ViewType(rawView: content())],
            getWidths: {
                [Self.getWidth(of: content())]
            })
    }
}

struct InternalWrappingHStack: View {
    let alignment: HorizontalAlignment
    let spacing: WrappingHStack.Spacing
    let lineSpacing: CGFloat
    let lineManager: LineManager
    let contentManager: ContentManager

    init(width: CGFloat, alignment: HorizontalAlignment, spacing: WrappingHStack.Spacing, lineSpacing: CGFloat, lineManager: LineManager, contentManager: ContentManager) {
        self.alignment = alignment
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.contentManager = contentManager
        self.lineManager = lineManager

        if !lineManager.isSetUp {
            lineManager.setup(contentManager: contentManager, width: width, spacing: spacing)
        }
    }

    func shouldHaveSideSpacers(line: Int) -> Bool {
        if case .constant = spacing {
            return true
        }
        if case .dynamic = spacing, lineManager.hasExactlyOneElement(line: line) {
            return true
        }
        return false
    }

    var body: some View {
        VStack(alignment: alignment, spacing: lineSpacing) {
            ForEach(0 ..< lineManager.totalLines, id: \.self) { lineIndex in
                HStack(spacing: 0) {
                    if alignment == .center || alignment == .trailing, shouldHaveSideSpacers(line: lineIndex) {
                        Spacer(minLength: 0)
                    }

                    ForEach(lineManager.startOf(line: lineIndex) ... lineManager.endOf(line: lineIndex), id: \.self) {
                        if case .dynamicIncludingBorders = spacing,
                           lineManager.startOf(line: lineIndex) == $0 {
                            Spacer(minLength: spacing.minSpacing)
                        }

                        if case .any(let anyView) = contentManager.items[$0], contentManager.isVisible(viewIndex: $0) {
                            anyView
                        }

                        if lineManager.endOf(line: lineIndex) != $0 {
                            if case .any = contentManager.items[$0], !contentManager.isVisible(viewIndex: $0) { } else {
                                if case .constant(let exactSpacing) = spacing {
                                    Spacer(minLength: 0)
                                        .frame(width: exactSpacing)
                                } else {
                                    Spacer(minLength: spacing.minSpacing)
                                }
                            }
                        } else if case .dynamicIncludingBorders = spacing {
                            Spacer(minLength: spacing.minSpacing)
                        }
                    }

                    if alignment == .center || alignment == .leading, shouldHaveSideSpacers(line: lineIndex) {
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

class LineManager {
    private var contentManager: ContentManager!
    private var spacing: WrappingHStack.Spacing!
    private var width: Double!

    lazy var firstItemOfEachLine: [Int] = {
        var firstOfEach = [Int]()
        var currentWidth: Double = width
        for (index, element) in contentManager.items.enumerated() {
            switch element {
            case .newLine:
                firstOfEach += [index]
                currentWidth = width
            case .any where contentManager.isVisible(viewIndex: index):
                let itemWidth = contentManager.widths[index]
                if currentWidth + itemWidth + spacing.minSpacing > width {
                    currentWidth = itemWidth
                    firstOfEach.append(index)
                } else {
                    currentWidth += itemWidth + spacing.minSpacing
                }
            default:
                break
            }
        }

        return firstOfEach
    }()

    var isSetUp: Bool {
        width != nil
    }

    func setup(contentManager: ContentManager, width: Double, spacing: WrappingHStack.Spacing) {
        self.contentManager = contentManager
        self.width = width
        self.spacing = spacing
    }

    var totalLines: Int {
        firstItemOfEachLine.count
    }

    func startOf(line: Int) -> Int {
        firstItemOfEachLine[line]
    }

    func endOf(line: Int) -> Int {
        line == totalLines - 1 ? contentManager.items.count - 1 : firstItemOfEachLine[line + 1] - 1
    }

    func hasExactlyOneElement(line: Int) -> Bool {
        startOf(line: line) == endOf(line: line)
    }
}

public struct NewLine: View {
    public init() { }
    public let body = Spacer(minLength: .infinity)
}

enum ViewType {
    case any(AnyView)
    case newLine

    init<V: View>(rawView: V) {
        switch rawView {
        case is NewLine: self = .newLine
        default: self = .any(AnyView(rawView))
        }
    }
}

class ContentManager {
    let items: [ViewType]
    let getWidths: () -> [Double]
    lazy var widths: [Double] = {
        getWidths()
    }()

    init(items: [ViewType], getWidths: @escaping () -> [Double]) {
        self.items = items
        self.getWidths = getWidths
    }

    func isVisible(viewIndex: Int) -> Bool {
        widths[viewIndex] > 0
    }
}
