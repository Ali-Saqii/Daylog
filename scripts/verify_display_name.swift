import Foundation

@main
struct VerifyDisplayName {
    static func main() {
        struct Case {
            let input: String?
            let expected: String?
            let label: String
        }

        let cases: [Case] = [
            Case(input: "Sadaqat", expected: "Sadaqat", label: "signup name is kept"),
            Case(input: "  Sadaqat  ", expected: "Sadaqat", label: "whitespace is trimmed"),
            Case(input: "", expected: nil, label: "empty string becomes nil"),
            Case(input: "   ", expected: nil, label: "whitespace-only becomes nil"),
            Case(input: nil, expected: nil, label: "missing name stays nil"),
        ]

        var failed = 0
        for test in cases {
            let actual = DisplayNameNormalization.normalized(test.input)
            if actual != test.expected {
                fputs("FAIL \(test.label): expected \(String(describing: test.expected)), got \(String(describing: actual))\n", stderr)
                failed += 1
            } else {
                print("PASS \(test.label)")
            }
        }

        if failed > 0 {
            fputs("\(failed) test(s) failed\n", stderr)
            exit(1)
        }

        print("All display-name mapping checks passed")
    }
}
