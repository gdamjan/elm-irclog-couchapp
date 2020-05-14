module Main exposing (..)

import Browser

import Model
import View
import Couch.Row

sampleId = "911d7fbb2d7a7d10070fd92ea36d4b01"


init : () -> (Model.Model, Cmd Model.Msg)
init _ =
  ( Model.Loading, Couch.Row.getRow sampleId )


update : Model.Msg -> Model.Model -> (Model.Model, Cmd Model.Msg)
update msg model =
  case msg of
    Model.GotRow result ->
      case result of
        Ok row ->
          (Model.Success row, Cmd.none)

        Err _ ->
          (Model.Failure, Cmd.none)


main =
  Browser.element
    { init = init
    , update = update
    , view = View.view
    , subscriptions = \_ -> Sub.none
    }
