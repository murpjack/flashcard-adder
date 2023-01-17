module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Card exposing (Card)
import CardEdit
import CardList
import Flags exposing (Flags)
import Html exposing (Html)
import Html.Attributes as Attrs exposing (selected)
import Json.Decode as Decode
import Maybe.Extra as Maybe
import Ports
import Route exposing (Route)
import Url exposing (Url)



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.getDataFromOutside OnIncomingData ]



---- MODEL ----


type alias Model =
    { cards : List Card
    , route : Route
    , selected : Maybe Card
    , navKey : Nav.Key
    , page : Page
    }


type Page
    = NotFoundPage
    | CardListPage CardList.Model
    | CardEditPage CardEdit.Model


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        f =
            Decode.decodeValue Flags.decode flags
                |> Result.withDefault Flags.default

        model =
            { cards =
                f.selected
                    |> Maybe.andThen
                        (\selected ->
                            Card.byId selected.id f.cards
                        )
                    |> Maybe.map
                        (\selected ->
                            case selected.progress of
                                Card.InProgress original ->
                                    Card.notStarted original
                                        |> Card.toList f.cards

                                _ ->
                                    selected
                                        |> Card.toList f.cards
                        )
                    |> Maybe.withDefault f.cards
            , selected = f.selected
            , route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage
        ( model
        , Cmd.none
        )


initCurrentPage :
    ( Model, Cmd Msg )
    -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( page, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.CardEdit id ->
                    let
                        ( pageModel, pageCmds ) =
                            CardEdit.init
                                (model.selected
                                    |> Maybe.orElse (Card.byId id model.cards)
                                    |> Maybe.withDefault (Card.create "err")
                                )
                                model.cards
                                model.navKey
                    in
                    ( CardEditPage pageModel
                    , Cmd.map CardEditPageMsg pageCmds
                    )

                Route.CardList ->
                    let
                        ( pageModel, pageCmds ) =
                            CardList.init model.selected model.cards model.navKey
                    in
                    ( CardListPage pageModel
                    , Cmd.map CardListPageMsg pageCmds
                    )
    in
    ( { model | page = page }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



---- UPDATE ----


type Msg
    = OnIncomingData (Result String Ports.DataForElm)
    | CardEditPageMsg CardEdit.Msg
    | CardListPageMsg CardList.Msg
    | UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( CardListPageMsg subMsg, CardListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    CardList.update subMsg pageModel

                selected =
                    model.selected
                        |> Maybe.andThen
                            (\card ->
                                Card.byId card.id updatedPageModel.cards
                            )
            in
            ( { model
                | cards = updatedPageModel.cards
                , selected = selected
                , page = CardListPage updatedPageModel
              }
            , Cmd.batch
                ((case selected of
                    Just _ ->
                        []

                    Nothing ->
                        [ Ports.sendDataOutside Ports.ClearSelectedInStorage ]
                 )
                    ++ [ Cmd.map CardListPageMsg updatedCmd
                       ]
                )
            )

        ( CardEditPageMsg subMsg, CardEditPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    CardEdit.update subMsg pageModel
            in
            ( { model
                | cards = updatedPageModel.cards
                , selected = Just updatedPageModel.selected
                , page = CardEditPage updatedPageModel
              }
            , Cmd.map CardEditPageMsg updatedCmd
            )

        ( OnIncomingData (Ok (Ports.GetRandomId id)), _ ) ->
            let
                url =
                    "/card/" ++ id ++ "/"
            in
            ( { model
                | selected = Just (Card.create id)
                , cards =
                    Card.create id
                        |> Card.toList model.cards
              }
            , Nav.pushUrl model.navKey url
            )

        ( OnIncomingData _, _ ) ->
            ( model, Cmd.none )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }
            , Cmd.none
            )
                |> initCurrentPage

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Flashcard app"
    , body =
        [ Html.div [ Attrs.id "app" ]
            [ currentPage model ]
        ]
    }


currentPage : Model -> Html Msg
currentPage model =
    case model.page of
        CardListPage pageModel ->
            CardList.view pageModel
                |> Html.map CardListPageMsg

        CardEditPage pageModel ->
            CardEdit.view pageModel
                |> Html.map CardEditPageMsg

        NotFoundPage ->
            Html.text "There is a problem."
