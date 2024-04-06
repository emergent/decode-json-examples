import gleeunit
import gleeunit/should
import gleam/json
import gleam/dynamic.{field, float, int, string}

pub fn main() {
  gleeunit.main()
}

/// simple case
///
pub fn decode_simple_test() {
  json.decode(from: "5", using: dynamic.int)
  |> should.equal(Ok(5))

  json.decode(from: "\"5\"", using: dynamic.string)
  |> should.equal(Ok("5"))

  json.decode(from: "[\"aaa\"]", using: dynamic.list(of: dynamic.string))
  |> should.equal(Ok(["aaa"]))
}

/// record case
///
type Data {
  Data(s: String, i: Int)
}

pub fn decode_record_test() {
  let s = "{\"s\":\"hoge\", \"i\":5}"
  let decoder =
    dynamic.decode2(Data, field("s", of: string), field("i", of: int))
  json.decode(from: s, using: decoder)
  |> should.equal(Ok(Data(s: "hoge", i: 5)))

  let s = "{\"sushi\":\"maguro\", \"ikura\":10}"
  let decoder =
    dynamic.decode2(Data, field("sushi", of: string), field("ikura", of: int))
  json.decode(from: s, using: decoder)
  |> should.equal(Ok(Data(s: "maguro", i: 10)))
}

/// nested record case
///
type Outer {
  Outer(i: Inner)
}

type Inner {
  Inner(s: String)
}

pub fn decode_nested_record_test() {
  let json_string =
    "{
      \"inner\": {
        \"str\": \"ramen\"
      }
    }"

  let inner_decoder = dynamic.decode1(Inner, field("str", of: string))
  let decoder = dynamic.decode1(Outer, field("inner", of: inner_decoder))

  json.decode(from: json_string, using: decoder)
  |> should.equal(Ok(Outer(i: Inner(s: "ramen"))))
}

/// complex case
///
pub type ListItems {
  ListItems(items: List(Item), limit: Int, offset: Int, total: Int)
}

pub type Item {
  Item(name: String, size: Float)
}

pub fn decode_complex_items_test() {
  let json_string =
    "{
      \"items\": [
        {
          \"name\": \"yamada\",
          \"size\": 26.0
        },
        {
          \"name\": \"tanaka\",
          \"size\": 28.0
        }
      ],
      \"limit\": 10,
      \"offset\": 0,
      \"total\": 2
    }"

  let decoder =
    dynamic.decode4(
      ListItems,
      field(
        "items",
        of: dynamic.list(of: dynamic.decode2(
          Item,
          field("name", of: string),
          field("size", of: float),
        )),
      ),
      field("limit", of: int),
      field("offset", of: int),
      field("total", of: int),
    )

  json.decode(from: json_string, using: decoder)
  |> should.equal(
    Ok(ListItems(
      items: [
        Item(name: "yamada", size: 26.0),
        Item(name: "tanaka", size: 28.0),
      ],
      limit: 10,
      offset: 0,
      total: 2,
    )),
  )
}
