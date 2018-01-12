module Main exposing (main)

import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import String exposing (toList, toUpper, fromChar)
import Touch


type alias Flags =
    Bool


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type TouchType
    = Tap
    | SwipeRight
    | SwipeLeft
    | SwipeDown
    | SwipeUp


type alias Model =
    { gesture : Touch.Gesture
    , touchType : Maybe TouchType
    , posY : Float
    }


initialModel : Model
initialModel =
    { gesture = Touch.blanco, touchType = Nothing, posY = -1.0 }


init : Flags -> ( Model, Cmd Msg )
init flags =
    Debug.log ("flags: " ++ toString flags) ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | Swipe Touch.Event
    | SwipeEnd Touch.Event


swipeSensitivity : Float
swipeSensitivity =
    30


gestureType : Touch.Gesture -> Maybe TouchType
gestureType gesture =
    if Touch.isTap gesture then
        Just Tap
    else if Touch.isLeftSwipe swipeSensitivity gesture then
        Just SwipeLeft
    else if Touch.isRightSwipe swipeSensitivity gesture then
        Just SwipeRight
    else if Touch.isDownSwipe swipeSensitivity gesture then
        Just SwipeDown
    else if Touch.isUpSwipe swipeSensitivity gesture then
        Just SwipeUp
    else
        Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Swipe touch ->
            let
                newY : Float
                newY =
                    Debug.log "Y=" (Touch.locate touch |> .y)

                newGesture : Touch.Gesture
                newGesture =
                    Touch.record touch model.gesture
            in
                ( { model | gesture = newGesture, posY = newY }, Cmd.none )

        SwipeEnd touch ->
            let
                newGesture : Touch.Gesture
                newGesture =
                    Touch.record touch model.gesture

                tt : Maybe TouchType
                tt =
                    Debug.log "touch-type: " (gestureType newGesture)
            in
                ( { model | gesture = newGesture, touchType = tt }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


abc : List Char
abc =
    toList "AÄBCDEFGHIJKLMNOÖPQRSTUÜVWXYZ"


view : Model -> Html Msg
view _ =
    div [ class "container" ]
        [ div []
            (List.map (\n -> div [ class "items" ] [ text ("item" ++ toString n) ]) (List.range 1 100))
        , div
            [ class "settings"
            , Touch.onStart Swipe
            , Touch.onEnd SwipeEnd
            ]
            [ img [ src "images/ic_settings_black_24dp_2x.png", alt "Settings" ] [] ]
        , div
            [ id "abcColumn"
            , class "abc"
            , Touch.onStart Swipe
            , Touch.onMove Swipe
            , Touch.onEnd SwipeEnd
            ]
            (List.map (\ch -> div [ class "letter" ] [ text (ch |> fromChar |> toUpper) ]) abc)
        ]
