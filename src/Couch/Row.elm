module Couch.Row exposing (..)

import Http
import Task
import Time
import Json.Decode as Decode
import Model exposing (Row, Msg(..))


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
