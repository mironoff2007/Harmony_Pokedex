import { router } from '@kit.ArkUI';
import { RouteConstants } from './RouteConstants';

@Entry
@Component
struct Index {
  @State message: string = 'PokeDex';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Pokedex')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          router.pushUrl({
            url: RouteConstants.POKE_LIST,
          }, router.RouterMode.Standard, (err) => {
            if (err) {
              console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            console.info('Invoke pushUrl succeeded.');
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}