import { useRef } from 'react'
import {
  Text,
  TouchableOpacity,
  View,
  type StyleProp,
  type TextStyle,
  type ViewStyle,
  Modal,
  Pressable,
  SafeAreaView,
  StyleSheet,
  FlatList,
} from 'react-native'
import { TrueSheet, type SizeInfo } from '@lodev09/react-native-true-sheet'
import MapView from 'react-native-maps'
import { SafeAreaProvider, useSafeAreaInsets } from 'react-native-safe-area-context'
import Animated, { useSharedValue, withSpring, useAnimatedStyle } from 'react-native-reanimated'

import {
  BasicSheet,
  BlankSheet,
  FlatListSheet,
  GestureSheet,
  PromptSheet,
  ScrollViewSheet,
} from '../components/sheets'
import { Button, DemoContent, Input, Spacer } from '../components'
import { BLUE, DARK, DARK_BLUE, DARK_GRAY, GRAY, SPACING, SPRING_CONFIG, times } from '../utils'
import { useDragChangeHandler } from '../hooks'

const AnimatedButton = Animated.createAnimatedComponent(TouchableOpacity)
const AnimatedTrueSheet = Animated.createAnimatedComponent(TrueSheet)

export const MapScreen = () => {
  const sheetRef = useRef<TrueSheet>(null)

  const basicSheet = useRef<TrueSheet>(null)
  const promptSheet = useRef<TrueSheet>(null)
  const scrollViewSheet = useRef<TrueSheet>(null)
  const flatListSheet = useRef<TrueSheet>(null)
  const gestureSheet = useRef<TrueSheet>(null)
  const blankSheet = useRef<TrueSheet>(null)

  const insets = useSafeAreaInsets()
  const buttonY = useSharedValue(0)

  const dragChangeHandler = useDragChangeHandler((sizeInfo: SizeInfo) => {
    'worklet'
    buttonY.value = -sizeInfo.value
  })

  const presentBasicSheet = async (index = 0) => {
    await basicSheet.current?.present(index)
    console.log('Sheet 1 present async')
  }

  const $floatingButtonStyles: StyleProp<ViewStyle> = [
    $floatingButton,
    { bottom: insets.bottom + SPACING },
    useAnimatedStyle(() => ({
      transform: [{ translateY: buttonY.value }],
    })),
  ]

  const animateButton = (sizeInfo: SizeInfo) => {
    buttonY.value = withSpring(-sizeInfo.value, SPRING_CONFIG)
  }

  return (
    <View style={$container}>
      <MapView
        style={$map}
        initialCamera={{
          altitude: 18000,
          zoom: 14,
          center: {
            latitude: 9.306743705457553,
            longitude: 123.30474002203727,
          },
          pitch: 0,
          heading: 0,
        }}
        userInterfaceStyle="dark"
      />
      <AnimatedButton
        activeOpacity={0.6}
        style={$floatingButtonStyles}
        onPress={() => sheetRef.current?.resize(0)}
      />
      {/*<PromptSheet ref={promptSheet} initialIndex={0} />*/}
      {/*<FlatListSheet initialIndex={0} ref={flatListSheet} />*/}
      <AnimatedTrueSheet
        sizes={['15%', 'auto', 'large']}
        ref={sheetRef}
        blurTint="dark"
        backgroundColor={DARK}
        edgeToEdge
        contentContainerStyle={{ padding: SPACING, paddingBottom: SPACING * 3 }}
        dimmedIndex={2}
        dismissible={false}
        cornerRadius={12}
        initialIndex={0}
        onDragChange={dragChangeHandler}
        onPresent={(e) => animateButton(e.nativeEvent)}
        onSizeChange={(e) => animateButton(e.nativeEvent)}
        onDragEnd={(e) => animateButton(e.nativeEvent)}
        // initialIndexAnimated={false}
        onMount={() => {
          // sheetRef.current?.present(1)
          console.log('Sheet is ready!')
        }}
      >
        <View style={$heading}>
          <Text style={$title}>True Sheet 💩</Text>
          <Text style={$subtitle}>The true native bottom sheet experience.</Text>
        </View>
        <Button text="TrueSheet View" onPress={() => presentBasicSheet(0)} />
        <Button text="TrueSheet Prompt" onPress={() => promptSheet.current?.present()} />
        <Button text="TrueSheet ScrollView" onPress={() => scrollViewSheet.current?.present()} />
        <Button text="TrueSheet FlatList" onPress={() => flatListSheet.current?.present()} />
        <Button text="TrueSheet Gestures" onPress={() => gestureSheet.current?.present()} />
        <Button text="Blank Sheet" onPress={() => blankSheet.current?.present()} />

        <Spacer />
        <Button text="Expand" onPress={() => sheetRef.current?.resize(2)} />
        <Button text="Collapse" onPress={() => sheetRef.current?.resize(1)} />

        <BasicSheet ref={basicSheet} />
        <PromptSheet ref={promptSheet} />
        <ScrollViewSheet ref={scrollViewSheet} />
        <FlatListSheet ref={flatListSheet} />
        <GestureSheet ref={gestureSheet} />
        <BlankSheet ref={blankSheet} />
      </AnimatedTrueSheet>
    </View>
  )
}

const $floatingButton: ViewStyle = {
  position: 'absolute',
  right: SPACING,
  height: SPACING * 3,
  width: SPACING * 3,
  borderRadius: (SPACING * 3) / 2,
  backgroundColor: DARK_BLUE,
  shadowColor: DARK,
  shadowOffset: { width: 0, height: 2 },
  shadowOpacity: 0.3,
  shadowRadius: 2,
}

const $container: ViewStyle = {
  backgroundColor: BLUE,
  justifyContent: 'center',
  flex: 1,
}

const $map: ViewStyle = {
  flex: 1,
}

const $heading: ViewStyle = {
  marginBottom: SPACING * 2,
}

const $title: TextStyle = {
  fontSize: 24,
  lineHeight: 30,
  fontWeight: 500,
  color: 'white',
}

const $subtitle: TextStyle = {
  lineHeight: 24,
  color: GRAY,
}

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalView: {
    margin: 20,
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 35,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  button: {
    borderRadius: 20,
    padding: 10,
    elevation: 2,
  },
  buttonOpen: {
    backgroundColor: '#F194FF',
  },
  buttonClose: {
    backgroundColor: '#2196F3',
  },
  textStyle: {
    color: 'white',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  modalText: {
    marginBottom: 15,
    textAlign: 'center',
  },
})
