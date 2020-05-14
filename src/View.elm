module View exposing (..)

import Html exposing (Html, text, div, span)
import Html.Attributes exposing (style)
import Identicon
import Color
import Time

import Model exposing (Model(..))

view : Model -> Html msg
view model =
    case model of
        Loading ->
            text "Loading..."

        Failure ->
            text "I was unable to load your book."

        Success row ->
            let
                z = Time.utc
            in
                div [] [
                    div [] [ text <| "#" ++ row.channel ],
                    div [] [ text <| toIsoDate z row.timestamp ],
                    div [] [
                        span [] [ text <| toIsoTime z row.timestamp ],
                        nickname row.sender,
                        span [] [ text row.message ]
                    ],
                    div [] [ text <| timestamp row.timestamp ]
                ]


timestamp: Time.Posix -> String
timestamp t =
    Time.posixToMillis t
    |> toFloat
    |> (\f -> f / 1000) -- divBy
    |> String.fromFloat

toIsoDate: Time.Zone -> Time.Posix -> String
toIsoDate z t =
    [
        Time.toYear z t |> String.fromInt,
        Time.toMonth z t |> toNumMonth,
        Time.toDay z t |> String.fromInt |> String.padLeft 2 '0'
    ] |> String.join "-"

toIsoTime: Time.Zone -> Time.Posix -> String
toIsoTime z t =
    [
        Time.toHour z t |> String.fromInt |> String.padLeft 2 '0',
        Time.toMinute z t |> String.fromInt |> String.padLeft 2 '0',
        Time.toSecond z t |> String.fromInt |> String.padLeft 2 '0'
    ] |> String.join ":"

toNumMonth : Time.Month -> String
toNumMonth month =
  case month of
    Time.Jan -> "01"
    Time.Feb -> "02"
    Time.Mar -> "03"
    Time.Apr -> "04"
    Time.May -> "05"
    Time.Jun -> "06"
    Time.Jul -> "07"
    Time.Aug -> "08"
    Time.Sep -> "09"
    Time.Oct -> "10"
    Time.Nov -> "11"
    Time.Dec -> "12"

nickname : String -> Html.Html msg
nickname sender =
    let
        css = [
            style "padding" "1px 2px",
            style "margin" "0 4px",
            style "color" "black",
            style "background-color" (Identicon.defaultColor sender |> Color.toCssString)
            ]
    in
        span css [text <| sender ++ ": "]


