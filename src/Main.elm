port module Main exposing (main)

import Debug
import Html as H
import Html.Attributes as HA
import Svg exposing (..)
import Svg.Attributes exposing (..)
import String exposing (toList, toUpper, fromChar)
import Touch


type alias Flags =
    Bool


main : Program Flags Model Msg
main =
    H.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


port input : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    input AbcTouched


type Msg
    = NoOp
    | Swipe String Touch.Event
    | SwipeEnd Touch.Event
    | AbcTouched String


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
        AbcTouched val ->
            Debug.log ("AbcTouched " ++ val) ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        Swipe s touch ->
            let
                newY : Float
                newY =
                    Debug.log s (Touch.locate touch |> .y)

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




-- VIEW


theABC : List Char
theABC =
    toList "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- ÄÖÜ ?


view : Model -> H.Html Msg
view _ =
    H.div [ HA.class "container" ]
        [ H.div []
            (List.map (\n -> H.div [ HA.class "items" ] [ H.text ("item" ++ toString n) ]) (List.range 1 100))
        , H.div
            [ HA.class "settings"

            --            , Touch.onStart Swipe
            --            , Touch.onEnd SwipeEnd
            ]
            [ H.img [ HA.src "images/ic_settings_black_24dp_2x.png", HA.alt "Settings" ] [] ]
        , H.div
            [ HA.id "abcId"
            , HA.class "abc"
            , HA.style [ ( "height", "100%" ) ]
            ]
            [ svg [ width "100%", height "100%", viewBox "0 0 50 530" ]
                [ text_
                    [ x "0", y "15", fontSize "16", writingMode "tb", rotate "-90" ]
                    (List.map
                        (\ch ->
                            let
                                letter =
                                    (fromChar ch)
                            in
                                tspan
                                    [ x "0"
                                    , dy "10"
                                    , fontFamily "monospace"
                                    ]
                                    [ text letter ]
                        )
                        theABC
                    )
                ]
            ]
        ]
