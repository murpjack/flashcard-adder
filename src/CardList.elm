module CardList exposing (view)

import Card exposing (Card)
import Card.Data as Card
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [ Attrs.class "header" ]
            [ Html.h1 []
                [ Html.text "Card list"
                ]
            ]
        , if List.isEmpty model.cards then
            Html.div [ Attrs.class "no-list" ]
                [ Html.p [ Attrs.class "item__title" ]
                    [ Html.text "No cards have been created."
                    ]
                ]

          else
            Html.div [ Attrs.class "list" ]
                (List.map cardItemView model.cards)
        , Html.div [ Attrs.class "footer" ]
            [ Html.div
                [ Attrs.class "button-group"
                ]
                [ Html.button
                    [ Events.onClick CreateCardStart
                    , Attrs.class "button"
                    , Attrs.attribute "data-module" "button"
                    ]
                    [ Html.text "Create card"
                    ]
                , Html.button
                    [ Attrs.class "button button--secondary"
                    , Events.onClick ExportCsvFile
                    , Attrs.disabled (List.length model.cards == 0)
                    ]
                    [ Html.text "Export .csv file" ]
                ]
            ]
        ]


cardItemView : Card -> Html Msg
cardItemView card =
    let
        originalCard =
            case card.progress of
                Card.InProgress original ->
                    original

                _ ->
                    card

        textWithPlaceholder part =
            if part == "" then
                "!! No previous view !!"

            else
                part
    in
    Html.div [ Attrs.class "list__item" ]
        [ Html.div
            [ Attrs.class "item__title" ]
            [ Html.label [] [ Html.text "front:" ]
            , Html.p [] [ Html.text (textWithPlaceholder originalCard.front) ]
            ]
        , Html.div
            [ Attrs.class "item__title" ]
            [ Html.label [] [ Html.text "back:" ]
            , Html.p [] [ Html.text (textWithPlaceholder originalCard.back) ]
            ]
        , Html.div
            [ Attrs.classList
                [ ( "warning", True )
                , ( "warning-hidden", not (Card.isInProgress card) )
                ]
            ]
            [ Html.span [ Attrs.attribute "aria-hidden" "true" ] []
            , Html.strong [] [ Html.text "Draft" ]
            ]
        , Html.div [ Attrs.class "button-group" ]
            [ Html.button
                [ Attrs.class "button"
                , Events.onClick (GoToEditPage card.id)
                ]
                [ Html.text "Edit" ]
            , Html.button
                [ Attrs.class "button button--warning"
                , Events.onClick (DeleteCard card)
                ]
                [ Html.text "Delete" ]
            ]
        ]
