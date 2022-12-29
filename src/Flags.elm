module Flags exposing (Flags, decode, default)

import Card exposing (Card)
import Html.Attributes exposing (selected)
import Json.Decode as Decode exposing (Decoder)


type alias Flags =
    { cards : List Card
    , selected : Maybe Card
    }


default : Flags
default =
    { cards = []
    , selected = Nothing
    }


decode : Decoder Flags
decode =
    Decode.map2 Flags
        (Decode.field "cards" (Decode.list Card.decode))
        (Decode.field "selected" (Decode.maybe Card.decode))
