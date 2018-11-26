import Identicon
import Color
import Browser
import Html exposing (Html, text, div, span)
import Html.Attributes exposing (style)
import Http
import Task
import Time
import Json.Decode as Decode


main =
  Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }

type alias Row =
    { id : String
    , timestamp : Time.Posix
    , sender : String
    , channel : String
    , message : String
    }

type Model
  = Loading
  | Failure
  | Success Row

sampleId = "911d7fbb2d7a7d10070fd92ea36d4b01"


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading, getRow sampleId )

-- UPDATE


type Msg
  = GotRow (Result Http.Error Row)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotRow result ->
      case result of
        Ok row ->
          (Success row, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


-- VIEW


view : Model -> Html Msg
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


getRow id =
    Http.task
        { method = "GET"
        , url = "https://irc.softver.org.mk/api/" ++ id
        , headers = [Http.header "Accept" "application/json"]
        , body = Http.emptyBody
        , timeout = Just 10000 -- miliseconds
        , resolver = Http.stringResolver resolver
        }
    |> Task.attempt GotRow

resolver response =
    case response of
        Http.BadUrl_ url ->
          Err (Http.BadUrl url)

        Http.Timeout_ ->
          Err Http.Timeout

        Http.NetworkError_ ->
          Err Http.NetworkError

        Http.BadStatus_ metadata body ->
          Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ meta body ->
          Decode.decodeString rowDecoder body
          |> Result.mapError (\e -> Decode.errorToString e |> Http.BadBody )

rowDecoder : Decode.Decoder (Row)
rowDecoder =
    let
        secondsToPosix: Float -> Time.Posix
        secondsToPosix s =
            -- we loose some precision here, since the timestamp field keeps microseconds
            s * 1000 |> round |> Time.millisToPosix
    in Decode.map5 Row
        (Decode.field "_id" Decode.string)
        (Decode.field "timestamp" Decode.float |> Decode.map secondsToPosix)
        (Decode.field "sender" Decode.string)
        (Decode.field "channel" Decode.string)
        (Decode.field "message" Decode.string)
