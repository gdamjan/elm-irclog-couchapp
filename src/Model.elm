module Model exposing (..)


import Time
import Http

type Model
  = Loading
  | Failure
  | Success Row

type Msg
  = GotRow (Result Http.Error Row)

type alias Row =
    { id : String
    , timestamp : Time.Posix
    , sender : String
    , channel : String
    , message : String
    }
