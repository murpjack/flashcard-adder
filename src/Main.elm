module Main exposing (..)

import Browser
import Card
import Card.Data as Card
import CardEdit
import CardList
import File.Download
import Flags
import Html exposing (Html)
import Html.Attributes as Attrs
import Json.Decode as Decode
import Maybe.Extra as Maybe
import Ports
import Types exposing (Model, Msg(..), Page(..))



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.getDataFromOutside OnIncomingData ]



---- MODEL ----


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
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
            , page = CardListPage
            }
    in
    ( model
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --  ( CardListPageMsg subMsg, CardListPage pageModel ) ->
        --      let
        --          ( updatedPageModel, updatedCmd ) =
        --              CardList.update subMsg pageModel
        --          selected =
        --              model.selected
        --                  |> Maybe.andThen
        --                      (\card ->
        --                          Card.byId card.id updatedPageModel.cards
        --                      )
        --      in
        --      ( { model
        --          | cards = updatedPageModel.cards
        --          , selected = selected
        --          , page = CardListPage updatedPageModel
        --        }
        --      , Cmd.batch
        --          ((case selected of
        --              Just _ ->
        --                  []
        --              Nothing ->
        --                  [ Ports.sendDataOutside Ports.ClearSelectedInStorage ]
        --           )
        --              ++ [ Cmd.map CardListPageMsg updatedCmd
        --                 ]
        --          )
        --      )
        --  ( CardEditPageMsg subMsg, CardEditPage pageModel ) ->
        --      let
        --          ( updatedPageModel, updatedCmd ) =
        --              CardEdit.update subMsg pageModel
        --      in
        --      ( { model
        --          | cards = updatedPageModel.cards
        --          , selected = Just updatedPageModel.selected
        --          , page = CardEditPage updatedPageModel
        --        }
        --      , Cmd.map CardEditPageMsg updatedCmd
        --      )
        OnIncomingData (Ok (Ports.GetRandomId id)) ->
            Card.create id
                |> Card.inProgress (Card.create id)
                |> (\card ->
                        ( { model
                            | cards = Card.toList model.cards card
                            , selected = Just card
                            , page = CardEditPage
                          }
                        , Cmd.none
                        )
                   )

        OnIncomingData _ ->
            ( model, Cmd.none )

        --  ( UrlChanged url, _ ) ->
        --      let
        --          newRoute =
        --              Route.parseUrl url
        --      in
        --      ( { model | route = newRoute }
        --      , Cmd.none
        --      )
        --          |> initCurrentPage
        --  ( LinkClicked urlRequest, _ ) ->
        --      case urlRequest of
        --          Browser.Internal url ->
        --              ( model
        --              , Nav.pushUrl model.navKey (Url.toString url)
        --              )
        --          Browser.External url ->
        --              ( model
        --              , Nav.load url
        --              )
        CreateCardStart ->
            ( model
            , Ports.sendDataOutside Ports.AskForRandomId
            )

        DeleteCard selected ->
            let
                updatedCards =
                    Card.delete selected model.cards
            in
            ( { model
                | cards = updatedCards
              }
            , Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
            )

        GoToEditPage cardId ->
            let
                selected =
                    Card.byId cardId model.cards
                        |> Maybe.map
                            (\card ->
                                case card.progress of
                                    Card.InProgress _ ->
                                        card

                                    _ ->
                                        Card.inProgress card card
                            )
            in
            ( { model
                | selected = selected
                , cards =
                    selected
                        |> Maybe.map (Card.toList model.cards)
                        |> Maybe.withDefault model.cards
                , page = CardEditPage
              }
            , Cmd.none
            )

        ExportCsvFile ->
            ( model
            , File.Download.string "cards.csv"
                "text/csv"
                (model.cards |> Card.asCsvString)
            )

        AddCardToList ->
            {--
                TODO Should this action work where the card is empty?
-}
            let
                updatedCards =
                    model.selected
                        |> Maybe.map (Card.finished >> Card.toList model.cards)
                        |> Maybe.withDefault model.cards
            in
            ( { model
                | cards = updatedCards
                , selected = Nothing
                , page = CardListPage
              }
            , Cmd.batch
                [ Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
                , Ports.sendDataOutside Ports.ClearSelectedInStorage
                ]
            )

        SaveDraft ->
            let
                updatedCards =
                    model.selected
                        |> Maybe.map (Card.toList model.cards)
                        |> Maybe.withDefault model.cards
            in
            ( { model
                | cards = updatedCards
                , selected = Nothing
                , page = CardListPage
              }
            , Cmd.batch
                [ Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
                , Ports.sendDataOutside Ports.ClearSelectedInStorage
                ]
            )

        DiscardSelected ->
            {--
                It should remove currently in progress card
                It should update selected in list with the InProgress original value
                
                If discarding, then selected 'MUST' (logically) be InProgress

                scenario 1 
                a new card is being edited. No changes are made 
                ** -ie. the fields are both empty
                >> On discard, the card is deleted

                scenario 2
                an existing card is being edited, no changes are made 
                >> On discard, the card is reverted to original
-}
            let
                revertSelected =
                    model.selected
                        |> Maybe.map
                            (\selected ->
                                case selected.progress of
                                    Card.InProgress original ->
                                        Card.notStarted original

                                    _ ->
                                        -- This state should be impossible to reach
                                        selected
                            )

                updatedCards =
                    model.selected
                        |> Maybe.map
                            (\card ->
                                case card.progress of
                                    Card.InProgress original ->
                                        if Card.isEmpty card || Card.noChanges card original then
                                            Card.delete card model.cards

                                        else
                                            revertSelected
                                                |> Maybe.map (Card.toList model.cards)
                                                |> Maybe.withDefault model.cards

                                    _ ->
                                        -- This should be an impossible state
                                        model.cards
                            )
                        |> Maybe.withDefault model.cards
            in
            ( { model
                | selected = Nothing
                , cards = updatedCards
                , page = CardListPage
              }
            , Cmd.batch
                [ Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
                , Ports.sendDataOutside Ports.ClearSelectedInStorage
                ]
            )

        EditCardPart selected part value ->
            let
                changed =
                    selected
                        |> Card.changePart part value

                newList =
                    Card.toList model.cards changed
            in
            ( { model
                | selected = Just changed
                , cards = newList
              }
            , Cmd.batch
                [ Ports.sendDataOutside
                    (Ports.SetSelectedInStorage changed)
                , Ports.sendDataOutside
                    (Ports.SetCardsInStorage newList)
                ]
            )



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
        CardListPage ->
            CardList.view model

        CardEditPage ->
            CardEdit.view model
