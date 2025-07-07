import { forwardRef, useRef, type Ref } from 'react'
import { FlatList, Modal, ScrollView, Text, View, type ViewStyle } from 'react-native'
import { TrueSheet, type TrueSheetProps } from '@lodev09/react-native-true-sheet'

import { DARK, DARK_GRAY, INPUT_HEIGHT, SPACING, times } from '../../utils'
import { Input } from '../Input'
import { DemoContent } from '../DemoContent'
import { Footer } from '../Footer'
import { TrueSheetHeader } from '../../../../src/TrueSheetHeader'
import { TrueSheetFooter } from '../../../../src/TrueSheetFooter'
import { FooterComponent } from 'react-native-screens/lib/typescript/components/ScreenFooter'

interface FlatListSheetProps extends TrueSheetProps {}

const sampleText = Array(1).fill(
  'Hello world, test test test test test test test test test test \n\n'
)

export const FlatListSheet = forwardRef((props: FlatListSheetProps, ref: Ref<TrueSheet>) => {
  //const flatListRef = useRef<FlatList>(null)
  const scrollRef = useRef<ScrollView>(null)

  // return (
  //   <Modal presentationStyle={"pageSheet"}>
  //     <View
  //       style={{
  //         backgroundColor: 'red',
  //       }}
  //       nativeID="header-view"
  //       collapsable={false}
  //     >
  //       <TrueSheetHeader Component={<View>
  //         <Input />
  //       </View>} />
  //     </View>
  //     <View
  //       nativeID="content-view"
  //       collapsable={false}
  //       style={{
  //         flexGrow: 1,
  //         flexShrink: 1,
  //         backgroundColor: 'yellow',
  //         borderWidth: 2,
  //         borderColor: "cyan",
  //       }}
  //     >
  //       <ScrollView ref={scrollRef} nestedScrollEnabled={true} bounces={false}>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //         <Text>{sampleText}</Text>
  //       </ScrollView>
  //     </View>
  //     <View
  //       style={{
  //         backgroundColor: 'green',
  //       }}
  //       nativeID="footer-view"
  //       collapsable={false}
  //     >
  //       <TrueSheetFooter Component={<Footer />} />
  //     </View>
  //
  //   </Modal>
  // )

  return (
    <TrueSheet
      ref={ref}
      scrollRef={scrollRef}
      cornerRadius={12}
      sizes={['medium', 'large', '90%']}
      blurTint="dark"
      backgroundColor={DARK}
      keyboardMode="pan"
      FooterComponent={<Footer />}
      HeaderComponent={
        <View>
          <Input />
        </View>
      }
      edgeToEdge
      onDismiss={() => console.log('Sheet FlatList dismissed!')}
      onPresent={() => console.log(`Sheet FlatList presented!`)}
      {...props}
    >
      <ScrollView ref={scrollRef} bounces={false}>
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
        <Text>{sampleText}</Text>
        <Input />
      </ScrollView>
      {/*<FlatList<number>*/}
      {/*  ref={flatListRef}*/}
      {/*  // nestedScrollEnabled*/}
      {/*  data={times(10, (i) => i)}*/}
      {/*  // contentContainerStyle={$content}*/}
      {/*  indicatorStyle="black"*/}
      {/*  renderItem={() => (*/}
      {/*    <View>*/}
      {/*      <DemoContent color={DARK_GRAY} />*/}
      {/*      <Input />*/}
      {/*    </View>*/}
      {/*  )}*/}
      {/*/>*/}
    </TrueSheet>
  )
})

FlatListSheet.displayName = 'FlatListSheet'

const $content: ViewStyle = {
  padding: SPACING,
  paddingTop: INPUT_HEIGHT + SPACING * 4,
}

const $header: ViewStyle = {
  position: 'absolute',
  left: 0,
  right: 0,
  top: 0,
  backgroundColor: DARK,
  paddingTop: SPACING * 2,
  paddingHorizontal: SPACING,
  zIndex: 1,
}
