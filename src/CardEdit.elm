module CardEdit exposing (view)

import Card exposing (Card, Part(..))
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Types exposing (Model, Msg(..), Page(..))


view : Model -> Html Msg
view model =
    model.selected
        |> Maybe.map editCard
        |> Maybe.withDefault (Html.text "Err")


editCard : Card -> Html Msg
editCard card =
    Html.div
        []
        [ Html.h1 [] [ Html.text "Edit card" ]
        , Html.div [ Attrs.class "form" ]
            [ Html.div [ Attrs.class "form-group" ]
                [ Html.label
                    [ Attrs.for Card.frontFieldName ]
                    [ Html.text "Front:" ]
                , Html.textarea
                    [ Attrs.id Card.frontFieldName
                    , Attrs.name Card.frontFieldName
                    , Attrs.value card.front
                    , Events.onInput (EditCardPart card Card.Front)
                    ]
                    []
                ]
            , Html.div [ Attrs.class "form-group" ]
                [ Html.label
                    [ Attrs.for Card.backFieldName
                    ]
                    [ Html.text "Back:" ]
                , Html.textarea
                    [ Attrs.id Card.backFieldName
                    , Attrs.name Card.backFieldName
                    , Attrs.value card.back
                    , Events.onInput (EditCardPart card Card.Back)
                    ]
                    []
                ]
            , Html.div
                [ Attrs.class "button-group"
                ]
                [ Html.button
                    [ Events.onClick AddCardToList
                    , Attrs.class "button"
                    , Attrs.attribute "data-module" "button"
                    , Attrs.disabled (Card.isEmpty card)
                    ]
                    [ Html.text "Submit"
                    ]
                , Html.button
                    [ Attrs.class "button button--secondary"
                    , Events.onClick SaveDraft
                    , Attrs.disabled (Card.isEmpty card)
                    ]
                    [ Html.text "Save as draft" ]
                , Html.button
                    [ Attrs.class "button button--warning"
                    , Events.onClick DiscardSelected
                    ]
                    [ Html.text "Discard changes" ]
                ]
            ]
        ]
