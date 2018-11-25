import Identicon
import Color
import Browser
import Html exposing (Html, text, div, span)
import Html.Attributes exposing (style)
import Http
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
            div [] [
                div [] [ text <| "#" ++ row.channel ],
                timestamp row.timestamp,
                Html.br [] [],
                nickname row.sender,
                span [] [ text row.message ]
            ]


timestamp: Time.Posix -> Html.Html msg
timestamp t =
    (Time.posixToMillis t |> toFloat) / 1000
    |> String.fromFloat
    |> text


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
    Http.get
        { url = "https://irc.softver.org.mk/api/" ++ id
        , expect = Http.expectJson GotRow rowDecoder
        }

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
