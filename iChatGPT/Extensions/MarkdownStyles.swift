import SwiftUI
import MarkdownText

struct CustomHeading: HeadingMarkdownStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
    }
}

extension HeadingMarkdownStyle where Self == CustomHeading {
    static var custom: Self { .init() }
}

struct Underline: StrikethroughMarkdownStyle {
    func makeBody(configuration: Configuration) -> Text {
        configuration.content.underline()
    }
}

extension StrikethroughMarkdownStyle where Self == Underline {
    static var custom: Self { .init() }
}

struct CustomInlineCode: InlineCodeMarkdownStyle {
    func makeBody(configuration: Configuration) -> Text {
        configuration.label
            .foregroundColor(.pink)
    }
}

extension InlineCodeMarkdownStyle where Self == CustomInlineCode {
    static var custom: Self { .init() }
}

struct CustomQuote: QuoteMarkdownStyle {
    struct Content: View {
        @ScaledMetric(wrappedValue: 20) private var padding
        @ScaledMetric(wrappedValue: 3) private var thickness
        @Environment(\.markdownParagraphStyle) private var style

        let paragraph: ParagraphMarkdownConfiguration

        var body: some View {
            style
                .makeBody(configuration: paragraph)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, padding)
                .overlay(
                    RoundedRectangle(cornerRadius: thickness)
                        .frame(width: thickness)
                        #if os(iOS)
                        .foregroundColor(Color(.systemFill))
                        #endif
                        .offset(x: thickness),
                    alignment: .leading
                )
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        Content(paragraph: configuration.content)
    }
}

extension QuoteMarkdownStyle where Self == CustomQuote {
    static var custom: Self { .init() }
}

public struct CustomCode: CodeMarkdownStyle {
    struct Label: View {
        @ScaledMetric(wrappedValue: 15) private var padding

        let configuration: Configuration

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                configuration.label
                    .padding(padding)
            }
            #if os(iOS)
            .background(Color(.quaternarySystemFill).cornerRadius(8))
            #endif
            .overlay(
                configuration.language.flatMap { Text($0) }?
                    .padding(5)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    #if os(iOS)
                    .background(Color(.systemBackground))
                    #endif
                    .cornerRadius(6)
                    .padding(5),
                alignment: .topTrailing
            )
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        Label(configuration: configuration)
    }
}

extension CodeMarkdownStyle where Self == CustomCode {
    static var custom: Self { .init() }
}

struct CustomUnorderedBullet: UnorderedListBulletMarkdownStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .font(.footnote)
    }
}

extension UnorderedListBulletMarkdownStyle where Self == CustomUnorderedBullet {
    static var custom: Self { .init() }
}

struct CustomOrderedBullet: OrderedListBulletMarkdownStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.secondary)
    }
}

extension OrderedListBulletMarkdownStyle where Self == CustomOrderedBullet {
    static var custom: Self { .init() }
}

struct CustomImage: ImageMarkdownStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

extension ImageMarkdownStyle where Self == CustomImage {
    static var custom: Self { .init() }
}
