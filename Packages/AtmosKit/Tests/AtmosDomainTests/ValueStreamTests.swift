import AtmosDomain
import Testing

@Suite("ValueStream")
struct ValueStreamTests {
    @Test("a new observer receives the current value first")
    func currentValueFirst() async {
        let stream = ValueStream(1)
        await stream.send(2)
        var iterator = await stream.values().makeAsyncIterator()
        #expect(await iterator.next() == 2)
    }

    @Test("every observer receives each change")
    func broadcast() async {
        let stream = ValueStream("a")
        var first = await stream.values().makeAsyncIterator()
        var second = await stream.values().makeAsyncIterator()
        _ = await first.next()
        _ = await second.next()

        await stream.send("b")

        #expect(await first.next() == "b")
        #expect(await second.next() == "b")
    }

    @Test("sending the same value again notifies nobody")
    func noDuplicateEvents() async {
        let stream = ValueStream(1)
        var iterator = await stream.values().makeAsyncIterator()
        _ = await iterator.next()

        await stream.send(1)
        await stream.send(2)

        #expect(await iterator.next() == 2)
    }
}
