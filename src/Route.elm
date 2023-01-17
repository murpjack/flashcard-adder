module Route exposing (Route(..), parseUrl, pushUrl, toString)

import Browser.Navigation as Nav
import Card
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>))


type Route
    = CardList
    | CardEdit Card.Id
    | NotFound


parseUrl : Url -> Route
parseUrl url =
    case UrlParser.parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


matchRoute : UrlParser.Parser (Route -> a) a
matchRoute =
    -- TODO Is it best practice to have 2 routes going to the same page
    UrlParser.oneOf
        [ UrlParser.map CardList (UrlParser.s "card")
        , UrlParser.map CardEdit (UrlParser.s "card" </> cardIdParser)
        ]


cardIdParser : UrlParser.Parser (Card.Id -> a) a
cardIdParser =
    UrlParser.custom "CARDID" <|
        (Card.idFromString >> Just)


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    toString route
        |> Nav.pushUrl navKey


toString : Route -> String
toString route =
    case route of
        NotFound ->
            "/not-found"

        CardList ->
            "/card/"

        CardEdit cardId ->
            "/card/" ++ Card.idToString cardId
