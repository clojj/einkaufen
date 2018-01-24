port module Main exposing (main)

import Debug
import Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Svg as Svg
import Svg.Attributes as SvgA
import String exposing (toList, toUpper, fromChar)
import Touch
import List


type alias Flags =
    Bool


main : Program Flags Model Msg
main =
    programWithFlags
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
    , letter : Maybe String
    }


initialModel : Model
initialModel =
    { gesture = Touch.blanco, touchType = Nothing, posY = -1.0, letter = Nothing }


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
        NoOp ->
            ( model, Cmd.none )

        AbcTouched l ->
            ( { model | letter = Just l }, Cmd.none )

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


abcLetters : List Char
abcLetters =
    toList "ABCDEFGHIJKLMNOPQRSTUVWXYZ"



-- ÄÖÜ ?


link : String -> String -> Html Msg
link name url =
    a [ href url ] [ text name ]


menu : Html Msg
menu =
    let
        menuStyle =
            style [ ( "list-style-type", "none" ) ]

        menuElementStyle =
            style [ ( "display", "inline" ), ( "margin-left", "10px" ) ]
    in
        div [ class "menu" ]
            [ ul [ menuStyle ]
                [ li [ menuElementStyle ] [ link "list" "#/list" ]
                , li [ menuElementStyle ] [ link "admin" "#/admin" ]
                ]
            ]


tspanLetters dx =
    (List.map
        (\ch ->
            let
                letter =
                    (fromChar ch)
            in
                Svg.tspan
                    [ SvgA.x dx
                    , SvgA.dy "20"
                    ]
                    [ Svg.text letter ]
        )
        abcLetters
    )


view : Model -> Html Msg
view model =
    let
        letterDisplay =
            case model.letter of
                Nothing ->
                    div [] []

                Just l ->
                    div
                        [ class "letteroverlay" ]
                        [ text l ]
    in
        div []
            [ letterDisplay
            , div
                [ class "container" ]
                [ div []
                    (List.map (\n -> div [ class "items" ] [ text ("item" ++ toString n) ]) (List.range 1 100))
                , div
                    [ class "settings" ]
                    [ img [ src "images/ic_settings_black_24dp_2x.png", alt "Settings" ] [] ]
                ]
            , div
                [ id "abcId"
                , style [ ( "height", "100%" ) ]
                ]
                [ Svg.svg [ SvgA.id "svgABC", SvgA.class "abc", SvgA.viewBox "0 0 30 530" ]
                    [ Svg.text_
                        [ SvgA.x "0", SvgA.y "0", SvgA.fontSize "16", SvgA.fontFamily "monospace", SvgA.visibility "hidden", SvgA.pointerEvents "all" ]
                        (tspanLetters "0")
                    , Svg.text_
                        [ SvgA.x "0", SvgA.y "0", SvgA.fontSize "16", SvgA.fontFamily "monospace" ]
                        (tspanLetters "10")
                    , Svg.text_
                        [ SvgA.x "0", SvgA.y "0", SvgA.fontSize "16", SvgA.fontFamily "monospace", SvgA.visibility "hidden", SvgA.pointerEvents "all" ]
                        (tspanLetters "20")
                    ]
                ]

            {-
               , div
                   [ id "menuId"
                   , style [ ( "height", "10%" ) ]
                   ]
                   [ Svg.svg [ SvgA.id "svgMenu", SvgA.width "100%", SvgA.height "100%", SvgA.viewBox "0 0 50 50" ]
                       [ Svg.circle [ SvgA.cx "25", SvgA.cy "50", SvgA.r "10", SvgA.stroke "black", SvgA.strokeWidth "3", SvgA.fill "grey" ] []
                       ]
                   ]
            -}
            ]
