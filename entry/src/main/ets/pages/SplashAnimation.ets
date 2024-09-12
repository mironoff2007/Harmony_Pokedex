import { router } from '@kit.ArkUI';
import { RouteConstants } from './RouteConstants';
import SplashViewModel from '../viewmodel/SplashViewModel';

@Entry
@Component
struct SplashIndex {
  build() {
    RelativeContainer() {
      Text("Pokedex")
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      console.log('on appear')
      animateTo({
        duration: 3000,
        delay: 100,
        onFinish: () => {
          setTimeout(() => {
            router.replaceUrl({ url: RouteConstants.POKE_LIST })
          }, 1000);
        }
      }, () => {
        //not used
      })
    })
  }
}
